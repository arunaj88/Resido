import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

/// How a payment was received (manual recording only, no gateway).
enum PaymentMode { upi, bankTransfer, cash, cheque }

/// Payments are never edited or deleted; mistakes are voided.
enum PaymentStatus { recorded, voided }

/// A manually recorded payment against one rent due.
class Payment {
  Payment({
    required this.id,
    required this.rentDueId,
    required this.tenancyId,
    required this.tenantId,
    required this.amountPaise,
    required this.paidOn,
    required this.mode,
    this.reference = '',
    this.notes = '',
    this.receiptNo = '',
    this.status = PaymentStatus.recorded,
    this.voidedOn,
    this.voidReason = '',
  }) {
    for (final (value, field) in [
      (id, 'id'),
      (rentDueId, 'rentDueId'),
      (tenancyId, 'tenancyId'),
      (tenantId, 'tenantId'),
    ]) {
      final error = Validators.requiredId(value, field);
      if (error != null) throw ArgumentError.value(value, field, error);
    }
    Money.checkAmount(amountPaise, name: 'amountPaise');
    if (amountPaise == 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'must be positive');
    }
    final notesError = Validators.optionalText(notes, 'Notes');
    if (notesError != null) {
      throw ArgumentError.value(notes, 'notes', notesError);
    }
    if (status == PaymentStatus.voided) {
      if (voidedOn == null || voidReason.trim().isEmpty) {
        throw ArgumentError('A voided payment needs voidedOn and a reason');
      }
      if (voidedOn!.isBefore(paidOn)) {
        throw ArgumentError.value(
          voidedOn,
          'voidedOn',
          'cannot be before the payment date $paidOn',
        );
      }
    } else if (voidedOn != null || voidReason.isNotEmpty) {
      throw ArgumentError('Only voided payments have void details');
    }
  }

  final String id;
  final String rentDueId;
  final String tenancyId;
  final String tenantId;
  final int amountPaise;
  final CalendarDate paidOn;
  final PaymentMode mode;
  final String reference;
  final String notes;
  final String receiptNo;
  final PaymentStatus status;
  final CalendarDate? voidedOn;
  final String voidReason;

  bool get isVoided => status == PaymentStatus.voided;

  /// A voided copy. Throws [StateError] if already voided.
  Payment voided({required CalendarDate on, required String reason}) {
    if (isVoided) throw StateError('Payment $id is already voided');
    return Payment(
      id: id,
      rentDueId: rentDueId,
      tenancyId: tenancyId,
      tenantId: tenantId,
      amountPaise: amountPaise,
      paidOn: paidOn,
      mode: mode,
      reference: reference,
      notes: notes,
      receiptNo: receiptNo,
      status: PaymentStatus.voided,
      voidedOn: on,
      voidReason: reason.trim(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'rentDueId': rentDueId,
    'tenancyId': tenancyId,
    'tenantId': tenantId,
    'amountPaise': amountPaise,
    'paidOn': paidOn.toIso(),
    'mode': mode.name,
    'reference': reference,
    'notes': notes,
    'receiptNo': receiptNo,
    'status': status.name,
    'voidedOn': voidedOn?.toIso(),
    'voidReason': voidReason,
  };

  factory Payment.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'Payment');
    return Payment(
      id: r.string('id'),
      rentDueId: r.string('rentDueId'),
      tenancyId: r.string('tenancyId'),
      tenantId: r.string('tenantId'),
      amountPaise: r.integer('amountPaise'),
      paidOn: r.date('paidOn'),
      mode: r.enumValue('mode', PaymentMode.values),
      reference: r.string('reference'),
      notes: r.string('notes'),
      receiptNo: r.string('receiptNo'),
      status: r.enumValue('status', PaymentStatus.values),
      voidedOn: r.optDate('voidedOn'),
      voidReason: r.string('voidReason'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Payment &&
      other.id == id &&
      other.rentDueId == rentDueId &&
      other.tenancyId == tenancyId &&
      other.tenantId == tenantId &&
      other.amountPaise == amountPaise &&
      other.paidOn == paidOn &&
      other.mode == mode &&
      other.reference == reference &&
      other.notes == notes &&
      other.receiptNo == receiptNo &&
      other.status == status &&
      other.voidedOn == voidedOn &&
      other.voidReason == voidReason;

  @override
  int get hashCode => Object.hash(
    id,
    rentDueId,
    tenancyId,
    tenantId,
    amountPaise,
    paidOn,
    mode,
    reference,
    notes,
    receiptNo,
    status,
    voidedOn,
    voidReason,
  );
}
