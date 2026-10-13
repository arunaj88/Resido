import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/core/domain/validators.dart';

enum TenancyStatus { active, ended }

/// A tenant's occupation of one unit.
///
/// Date rules:
/// * [startDate] is the first day of the tenancy.
/// * [endDate] is the **inclusive** last day of the agreed term; null
///   means open-ended.
/// * Ending a tenancy sets [status] to ended and [endedOn] (also
///   inclusive). The effective last day is the earlier of the two.
/// Ended tenancies are kept for history; they are never deleted.
class Tenancy {
  Tenancy({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.propertyId,
    required this.startDate,
    required this.rentPaise,
    required this.depositPaise,
    required this.dueDay,
    this.endDate,
    this.graceDays = defaultGraceDays,
    this.status = TenancyStatus.active,
    this.endedOn,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id', 'is empty');
    for (final (value, field) in [
      (tenantId, 'tenantId'),
      (unitId, 'unitId'),
      (propertyId, 'propertyId'),
    ]) {
      final error = Validators.requiredId(value, field);
      if (error != null) throw ArgumentError.value(value, field, error);
    }
    Money.checkAmount(rentPaise, name: 'rentPaise');
    if (rentPaise == 0) {
      throw ArgumentError.value(rentPaise, 'rentPaise', 'must be positive');
    }
    Money.checkAmount(depositPaise, name: 'depositPaise');
    final dueError = Validators.dueDay(dueDay);
    if (dueError != null) throw ArgumentError.value(dueDay, 'dueDay', dueError);
    final graceError = Validators.graceDays(graceDays);
    if (graceError != null) {
      throw ArgumentError.value(graceDays, 'graceDays', graceError);
    }
    final rangeError = Validators.dateRange(startDate, endDate);
    if (rangeError != null) {
      throw ArgumentError.value(endDate, 'endDate', rangeError);
    }
    if ((status == TenancyStatus.ended) != (endedOn != null)) {
      throw ArgumentError.value(
        endedOn,
        'endedOn',
        'is required exactly when the tenancy has ended',
      );
    }
    if (endedOn != null && endedOn!.isBefore(startDate)) {
      throw ArgumentError.value(endedOn, 'endedOn', 'is before the start');
    }
  }

  /// Default grace period, matching the "5-Day Grace Period" in Assign
  /// Tenant.
  static const defaultGraceDays = 5;

  final String id;
  final String tenantId;
  final String unitId;
  final String propertyId;
  final CalendarDate startDate;
  final CalendarDate? endDate;
  final int rentPaise;
  final int depositPaise;

  /// Day of the month rent falls due, 1–28.
  final int dueDay;

  /// Days after the due date before rent counts as overdue.
  final int graceDays;
  final TenancyStatus status;
  final CalendarDate? endedOn;

  bool get isActive => status == TenancyStatus.active;

  /// The inclusive last day the tenancy covers, or null if open-ended.
  CalendarDate? get lastDay {
    final end = endDate;
    final ended = endedOn;
    if (end == null) return ended;
    if (ended == null) return end;
    return ended.isBefore(end) ? ended : end;
  }

  /// True when [date] is between the start and [lastDay], inclusive.
  bool covers(CalendarDate date) {
    if (date.isBefore(startDate)) return false;
    final last = lastDay;
    return last == null || !date.isAfter(last);
  }

  /// Ends the tenancy on [on] (inclusive). Dues and payments are untouched.
  Tenancy end(CalendarDate on) {
    if (!isActive) {
      throw StateError('Tenancy $id has already ended');
    }
    return Tenancy(
      id: id,
      tenantId: tenantId,
      unitId: unitId,
      propertyId: propertyId,
      startDate: startDate,
      endDate: endDate,
      rentPaise: rentPaise,
      depositPaise: depositPaise,
      dueDay: dueDay,
      graceDays: graceDays,
      status: TenancyStatus.ended,
      endedOn: on,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'tenantId': tenantId,
    'unitId': unitId,
    'propertyId': propertyId,
    'startDate': startDate.toIso(),
    'endDate': endDate?.toIso(),
    'rentPaise': rentPaise,
    'depositPaise': depositPaise,
    'dueDay': dueDay,
    'graceDays': graceDays,
    'status': status.name,
    'endedOn': endedOn?.toIso(),
  };

  factory Tenancy.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'Tenancy');
    return Tenancy(
      id: r.string('id'),
      tenantId: r.string('tenantId'),
      unitId: r.string('unitId'),
      propertyId: r.string('propertyId'),
      startDate: r.date('startDate'),
      endDate: r.optDate('endDate'),
      rentPaise: r.integer('rentPaise'),
      depositPaise: r.integer('depositPaise'),
      dueDay: r.integer('dueDay'),
      graceDays: r.integer('graceDays'),
      status: r.enumValue('status', TenancyStatus.values),
      endedOn: r.optDate('endedOn'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Tenancy &&
      other.id == id &&
      other.tenantId == tenantId &&
      other.unitId == unitId &&
      other.propertyId == propertyId &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.rentPaise == rentPaise &&
      other.depositPaise == depositPaise &&
      other.dueDay == dueDay &&
      other.graceDays == graceDays &&
      other.status == status &&
      other.endedOn == endedOn;

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    unitId,
    propertyId,
    startDate,
    endDate,
    rentPaise,
    depositPaise,
    dueDay,
    graceDays,
    status,
    endedOn,
  );
}
