import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/features/rent/domain/payment.dart';
import 'package:resido/features/rent/domain/rent_due.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';

/// Rent dues and payments.
///
/// A future Firestore implementation must keep a protected `paidAmount`
/// running total on each due, written atomically together with payment
/// creation and voiding and enforced by security rules. The in-memory
/// implementation derives totals from payments and gives no such
/// guarantees.
abstract interface class RentRepository {
  /// All dues, or only those of [tenancyId], ordered by period.
  Future<List<RentDue>> getDues({String? tenancyId});

  /// Null when no due has [id].
  Future<RentDue?> getDue(String id);

  /// Creates any missing dues of [tenancy] up to [through] (optionally
  /// starting at [from]). Idempotent; returns only the newly created dues.
  Future<List<RentDue>> ensureDues(
    Tenancy tenancy, {
    required RentPeriod through,
    RentPeriod? from,
  });

  /// Cancels the active dues of [tenancy] that fall after its effective
  /// last day (see RentCalculator.unearnedDues) — call this after ending a
  /// tenancy early. Earned dues and all payments are untouched. Throws
  /// DomainException (`due-has-payments`) without changing anything if an
  /// unearned due has recorded payments; those need a decision first.
  /// Returns the cancelled dues.
  Future<List<RentDue>> cancelUnearnedDues(
    Tenancy tenancy, {
    required CalendarDate on,
    String reason,
  });

  /// Payments (including voided ones) filtered by due and/or tenancy.
  Future<List<Payment>> getPayments({String? rentDueId, String? tenancyId});

  /// Null when no payment has [id].
  Future<Payment?> getPayment(String id);

  /// Records [payment]. Retrying with the identical payment returns the
  /// stored one without counting it twice. Throws DomainException for an
  /// unknown due, mismatched links, a reused ID, or overpayment.
  Future<Payment> recordPayment(Payment payment);

  /// Voids a recorded payment; it then no longer counts as paid. [on] may
  /// not be before the payment date.
  Future<Payment> voidPayment(
    String id, {
    required CalendarDate on,
    required String reason,
  });
}
