import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_calculator.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/rent/domain/rent_repository.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';

/// In-memory dues and payments. Totals are always derived from the stored
/// payments through [RentCalculator]. Each instance has its own state.
///
/// This is local/test storage only: it does not provide the atomic
/// `paidAmount` updates, authorization or security of a real backend.
class InMemoryRentRepository implements RentRepository {
  InMemoryRentRepository({
    Iterable<RentDue> dues = const [],
    Iterable<Payment> payments = const [],
  }) {
    for (final d in dues) {
      _dues[d.id] = d;
    }
    for (final p in payments) {
      _payments[p.id] = p;
    }
  }

  /// The October 2024 cycle, matching the Rent screens: one due for each
  /// seeded tenancy that bills October 2024, plus the two recorded
  /// payments that belong to seeded tenancies (Ananya's ₹13,000 part
  /// payment and Dr. Thomas K.'s full rent). Earlier months are not seeded.
  factory InMemoryRentRepository.seeded(Iterable<Tenancy> tenancies) {
    final october = RentPeriod(2024, 10);
    final dues = [
      for (final t in tenancies)
        ...RentCalculator.newDues(t, from: october, through: october),
    ];
    final repo = InMemoryRentRepository(dues: dues);
    for (final p in seedPayments) {
      final due = repo._dues[p.rentDueId];
      if (due != null &&
          RentCalculator.canRecord(due, repo._payments.values, p)) {
        repo._payments[p.id] = p;
      }
    }
    return repo;
  }

  static final seedPayments = [
    Payment(
      id: 'pay-REC-2024-102-01',
      rentDueId: 'TNC-EKM-2024-02_2024-10',
      tenancyId: 'TNC-EKM-2024-02',
      tenantId: 'ananya-nair',
      amountPaise: Money.fromRupees(13000),
      paidOn: CalendarDate(2024, 10, 18),
      mode: PaymentMode.upi,
      reference: 'UPI-9840129381',
      receiptNo: 'REC-2024-102-01',
    ),
    Payment(
      id: 'pay-REC-2024-ALV-02',
      rentDueId: 'TNC-EKM-2023-07_2024-10',
      tenancyId: 'TNC-EKM-2023-07',
      tenantId: 'thomas-k',
      amountPaise: Money.fromRupees(30000),
      paidOn: CalendarDate(2024, 10, 4),
      mode: PaymentMode.bankTransfer,
      reference: 'ICIC-NEFT-552019837',
      receiptNo: 'REC-2024-ALV-02',
    ),
  ];

  final _dues = <String, RentDue>{};
  final _payments = <String, Payment>{};

  @override
  Future<List<RentDue>> getDues({String? tenancyId}) async {
    final list =
        _dues.values
            .where((d) => tenancyId == null || d.tenancyId == tenancyId)
            .toList()
          ..sort((a, b) {
            final byPeriod = a.period.compareTo(b.period);
            return byPeriod != 0
                ? byPeriod
                : a.tenancyId.compareTo(b.tenancyId);
          });
    return List.unmodifiable(list);
  }

  @override
  Future<RentDue?> getDue(String id) async => _dues[id];

  @override
  Future<List<RentDue>> ensureDues(
    Tenancy tenancy, {
    required RentPeriod through,
    RentPeriod? from,
  }) async {
    final created = RentCalculator.newDues(
      tenancy,
      through: through,
      from: from,
      existing: _dues.values,
    );
    for (final d in created) {
      _dues[d.id] = d;
    }
    return List.unmodifiable(created);
  }

  @override
  Future<List<RentDue>> cancelUnearnedDues(
    Tenancy tenancy, {
    required CalendarDate on,
    String reason = 'Tenancy ended before this due date',
  }) async {
    final unearned = RentCalculator.unearnedDues(tenancy, _dues.values);
    for (final d in unearned) {
      final forDue = _payments.values.where((p) => p.rentDueId == d.id);
      if (RentCalculator.paidPaise(d, forDue) > 0) {
        throw DomainException(
          'due-has-payments',
          'Due ${d.id} has recorded payments; void them before cancelling',
        );
      }
    }
    final cancelled = [
      for (final d in unearned) d.cancelled(on: on, reason: reason),
    ];
    for (final d in cancelled) {
      _dues[d.id] = d;
    }
    return List.unmodifiable(cancelled);
  }

  @override
  Future<List<Payment>> getPayments({
    String? rentDueId,
    String? tenancyId,
  }) async => List.unmodifiable(
    _payments.values.where(
      (p) =>
          (rentDueId == null || p.rentDueId == rentDueId) &&
          (tenancyId == null || p.tenancyId == tenancyId),
    ),
  );

  @override
  Future<Payment?> getPayment(String id) async => _payments[id];

  @override
  Future<Payment> recordPayment(Payment payment) async {
    final due = _dues[payment.rentDueId];
    if (due == null) {
      throw RecordNotFoundException('RentDue', payment.rentDueId);
    }
    final existing = _payments[payment.id];
    if (existing != null && existing.rentDueId != payment.rentDueId) {
      throw DomainException(
        'duplicate-payment-id',
        'Payment ID ${payment.id} is already used',
      );
    }
    final forDue = _payments.values.where((p) => p.rentDueId == due.id);
    if (RentCalculator.canRecord(due, forDue, payment)) {
      _payments[payment.id] = payment;
      return payment;
    }
    return _payments[payment.id]!;
  }

  @override
  Future<Payment> voidPayment(
    String id, {
    required CalendarDate on,
    required String reason,
  }) async {
    final payment = _payments[id];
    if (payment == null) throw RecordNotFoundException('Payment', id);
    if (payment.isVoided) {
      throw DomainException('payment-voided', 'Payment $id is already voided');
    }
    if (reason.trim().isEmpty) {
      throw const DomainException('void-reason', 'A reason is required');
    }
    if (on.isBefore(payment.paidOn)) {
      throw DomainException(
        'void-date',
        'A void cannot be dated before the payment (${payment.paidOn})',
      );
    }
    return _payments[id] = payment.voided(on: on, reason: reason);
  }
}
