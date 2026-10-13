import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';

/// Derived state of one rent due on a given business date.
enum RentDueStatus {
  /// The due date is still ahead and nothing has been paid.
  upcoming,

  /// Due (or inside the grace period) and unpaid.
  due,

  /// Some, but not all, has been paid and the grace period has not passed.
  partiallyPaid,

  /// Not fully paid after the last grace day.
  overdue,

  /// Fully paid.
  paid,

  /// Cancelled (fell after an early tenancy end); not owed.
  cancelled,
}

/// Totals for one due on one business date. Amounts are paise.
class RentDueSummary {
  const RentDueSummary({
    required this.due,
    required this.paidPaise,
    required this.status,
    required this.graceEndsOn,
  });

  final RentDue due;

  /// Sum of recorded (non-voided) payments, each counted once.
  final int paidPaise;
  final RentDueStatus status;

  /// The last day of the grace period; overdue starts the day after.
  final CalendarDate graceEndsOn;

  int get amountPaise => due.amountPaise;
  int get outstandingPaise => due.amountPaise - paidPaise;
}

/// Totals across many dues (e.g. a whole tenancy, including after it ends).
class RentBalance {
  const RentBalance({
    required this.totalDuePaise,
    required this.totalPaidPaise,
  });

  final int totalDuePaise;
  final int totalPaidPaise;

  int get outstandingPaise => totalDuePaise - totalPaidPaise;
}

/// Pure rent rules. No clock, no I/O: every date-dependent result takes an
/// explicit business date ([CalendarDate], `Asia/Kolkata` convention).
///
/// Rules:
/// * **Periods.** A month is billed when its due date (due day 1–28) falls
///   inside the tenancy, start to [Tenancy.lastDay] inclusive. There is no
///   proration: a partial first or last month is billed in full only if
///   its due date is covered, otherwise not at all. Months after the
///   tenancy ends are never billed; past dues stay as they are.
/// * **Paid amount.** Only recorded (non-voided) payments for the same due
///   and tenancy count, each payment ID once.
/// * **Overdue.** Due on `dueDate`; still not overdue on
///   `dueDate + graceDays` (the last grace day); overdue from the next day
///   while anything is outstanding.
/// * **Overpayment.** A payment may not take the paid total above the due.
/// * **Payment date.** A payment may be dated from the first day of the
///   month before the due's period (one month in advance) with no upper
///   limit, so late payments are always accepted. A void is never dated
///   before the payment it voids.
/// * **Early end.** Dues whose due date falls after the tenancy's effective
///   last day are unearned; [unearnedDues] finds them so they can be
///   cancelled. Cancelled dues stay on record but count towards nothing.
///
/// This only calculates. Atomic updates of the stored `paidAmount` running
/// total, authorization and security belong to the future backend.
abstract final class RentCalculator {
  /// Billable periods of [tenancy] from its start (or [from]) up to and
  /// including [through].
  static List<RentPeriod> billablePeriods(
    Tenancy tenancy, {
    required RentPeriod through,
    RentPeriod? from,
  }) {
    var first = tenancy.startDate.period;
    if (from != null && from.compareTo(first) > 0) first = from;
    var last = through;
    final lastDay = tenancy.lastDay;
    if (lastDay != null && lastDay.period.compareTo(last) < 0) {
      last = lastDay.period;
    }
    return [
      for (final p in first.through(last))
        if (tenancy.covers(p.dueDate(tenancy.dueDay))) p,
    ];
  }

  /// Dues to create for [tenancy] up to [through], skipping any whose ID is
  /// already in [existing] — generating twice never duplicates a period.
  static List<RentDue> newDues(
    Tenancy tenancy, {
    required RentPeriod through,
    RentPeriod? from,
    Iterable<RentDue> existing = const [],
  }) {
    final existingIds = {for (final d in existing) d.id};
    return [
      for (final p in billablePeriods(tenancy, through: through, from: from))
        if (!existingIds.contains(RentDue.idFor(tenancy.id, p)))
          RentDue.forTenancy(tenancy, p),
    ];
  }

  /// Active dues of [tenancy] whose due date it no longer covers (e.g.
  /// generated ahead, then the tenancy ended early). Uses the same
  /// inclusive last day as billing.
  static List<RentDue> unearnedDues(Tenancy tenancy, Iterable<RentDue> dues) =>
      [
        for (final d in dues)
          if (d.tenancyId == tenancy.id &&
              !d.isCancelled &&
              !tenancy.covers(d.dueDate))
            d,
      ];

  /// The earliest accepted payment date for [due]: the first day of the
  /// month before its period.
  static CalendarDate earliestPaymentDate(RentDue due) =>
      (due.period.year == CalendarDate.minYear && due.period.month == 1)
      ? due.period.firstDay
      : due.period.previous.firstDay;

  /// Recorded payments for [due], each ID once.
  ///
  /// [payments] must be the **current state** of each payment: one version
  /// per ID. Identical copies are counted once. Two different versions of
  /// one ID — including a recorded and a voided copy of the same payment —
  /// are rejected rather than picking one. Throws DomainException for that
  /// (`duplicate-payment-id`) or when a payment for this due names another
  /// tenancy or tenant (`payment-tenancy-mismatch`).
  static List<Payment> validPayments(RentDue due, Iterable<Payment> payments) {
    final byId = <String, Payment>{};
    for (final p in payments) {
      if (p.rentDueId != due.id) continue;
      if (p.tenancyId != due.tenancyId || p.tenantId != due.tenantId) {
        throw DomainException(
          'payment-tenancy-mismatch',
          'Payment ${p.id} does not belong to tenancy ${due.tenancyId}',
        );
      }
      final seen = byId[p.id];
      if (seen != null && seen != p) {
        throw DomainException(
          'duplicate-payment-id',
          'Conflicting versions of payment ${p.id}; pass current state only',
        );
      }
      byId[p.id] = p;
    }
    return [
      for (final p in byId.values)
        if (!p.isVoided) p,
    ];
  }

  static int paidPaise(RentDue due, Iterable<Payment> payments) =>
      Money.sum(validPayments(due, payments).map((p) => p.amountPaise));

  /// The state of [due] on [asOf].
  static RentDueSummary summarize(
    RentDue due,
    Iterable<Payment> payments, {
    required CalendarDate asOf,
    required int graceDays,
  }) {
    if (graceDays < 0) {
      throw ArgumentError.value(graceDays, 'graceDays', 'must not be negative');
    }
    final paid = paidPaise(due, payments);
    final graceEnds = due.dueDate.addDays(graceDays);
    final RentDueStatus status;
    if (due.isCancelled) {
      status = RentDueStatus.cancelled;
    } else if (paid >= due.amountPaise) {
      status = RentDueStatus.paid;
    } else if (asOf.isAfter(graceEnds)) {
      status = RentDueStatus.overdue;
    } else if (paid > 0) {
      status = RentDueStatus.partiallyPaid;
    } else if (asOf.isBefore(due.dueDate)) {
      status = RentDueStatus.upcoming;
    } else {
      status = RentDueStatus.due;
    }
    return RentDueSummary(
      due: due,
      paidPaise: paid,
      status: status,
      graceEndsOn: graceEnds,
    );
  }

  /// Totals for [dues] (any tenancies), counting only each due's own
  /// payments. Cancelled dues are excluded. Ended tenancies keep their
  /// earned historical dues and payments.
  ///
  /// Each due ID counts once: identical copies are collapsed, and different
  /// records sharing an ID throw DomainException (`duplicate-due-id`).
  static RentBalance balance(
    Iterable<RentDue> dues,
    Iterable<Payment> payments,
  ) {
    final list = payments.toList();
    final byId = <String, RentDue>{};
    for (final d in dues) {
      final seen = byId[d.id];
      if (seen != null && seen != d) {
        throw DomainException(
          'duplicate-due-id',
          'Conflicting records for due ${d.id}',
        );
      }
      byId[d.id] = d;
    }
    final counted = [
      for (final d in byId.values)
        if (!d.isCancelled) d,
    ];
    return RentBalance(
      totalDuePaise: Money.sum(counted.map((d) => d.amountPaise)),
      totalPaidPaise: Money.sum(counted.map((d) => paidPaise(d, list))),
    );
  }

  /// Checks that [payment] may be recorded against [due] given the
  /// [existing] payments. Returns false when the exact same payment is
  /// already recorded (a safe retry), true when it should be added.
  ///
  /// Throws DomainException for: a different due/tenancy/tenant, a voided
  /// payment, a cancelled due, a payment dated before
  /// [earliestPaymentDate], reuse of an ID with different details, or
  /// overpayment.
  static bool canRecord(
    RentDue due,
    Iterable<Payment> existing,
    Payment payment,
  ) {
    if (payment.rentDueId != due.id ||
        payment.tenancyId != due.tenancyId ||
        payment.tenantId != due.tenantId) {
      throw DomainException(
        'payment-tenancy-mismatch',
        'Payment ${payment.id} does not belong to due ${due.id}',
      );
    }
    if (payment.isVoided) {
      throw const DomainException(
        'payment-voided',
        'A voided payment cannot be recorded',
      );
    }
    if (due.isCancelled) {
      throw DomainException(
        'due-cancelled',
        'Due ${due.id} is cancelled and cannot take payments',
      );
    }
    final earliest = earliestPaymentDate(due);
    if (payment.paidOn.isBefore(earliest)) {
      throw DomainException(
        'payment-date',
        'A payment for ${due.period} cannot be dated before $earliest',
      );
    }
    for (final p in existing) {
      if (p.id == payment.id) {
        if (p == payment) return false;
        throw DomainException(
          'duplicate-payment-id',
          'Payment ID ${payment.id} is already used',
        );
      }
    }
    final outstanding = due.amountPaise - paidPaise(due, existing);
    if (payment.amountPaise > outstanding) {
      throw DomainException(
        'overpayment',
        'Payment of ${Money.format(payment.amountPaise)} exceeds the '
            'outstanding ${Money.format(outstanding)}',
      );
    }
    return true;
  }
}
