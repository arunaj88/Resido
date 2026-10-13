import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/serialization.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';

/// Whether a due still counts. Dues are never deleted: a due that was
/// generated in advance and then fell after an early tenancy end is
/// cancelled, which removes it from balances but keeps the record.
enum RentDueState { active, cancelled }

/// Rent owed by one tenancy for one period.
///
/// Its [id] is `<tenancyId>_<YYYY-MM>`, so a period can only ever have one
/// due per tenancy. The amount is the full monthly rent at creation time
/// (no proration).
class RentDue {
  RentDue({
    required this.tenancyId,
    required this.tenantId,
    required this.unitId,
    required this.propertyId,
    required this.period,
    required this.dueDate,
    required this.amountPaise,
    this.state = RentDueState.active,
    this.cancelledOn,
    this.cancelReason = '',
  }) {
    Money.checkAmount(amountPaise, name: 'amountPaise');
    if (amountPaise == 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'must be positive');
    }
    if (dueDate.period != period) {
      throw ArgumentError.value(dueDate, 'dueDate', 'is not in $period');
    }
    if (state == RentDueState.cancelled) {
      if (cancelledOn == null || cancelReason.trim().isEmpty) {
        throw ArgumentError('A cancelled due needs cancelledOn and a reason');
      }
    } else if (cancelledOn != null || cancelReason.isNotEmpty) {
      throw ArgumentError('Only cancelled dues have cancellation details');
    }
  }

  /// The due for [tenancy] in [period], using its rent and due day.
  factory RentDue.forTenancy(Tenancy tenancy, RentPeriod period) => RentDue(
    tenancyId: tenancy.id,
    tenantId: tenancy.tenantId,
    unitId: tenancy.unitId,
    propertyId: tenancy.propertyId,
    period: period,
    dueDate: period.dueDate(tenancy.dueDay),
    amountPaise: tenancy.rentPaise,
  );

  static String idFor(String tenancyId, RentPeriod period) =>
      '${tenancyId}_${period.key}';

  final String tenancyId;
  final String tenantId;
  final String unitId;
  final String propertyId;
  final RentPeriod period;
  final CalendarDate dueDate;
  final int amountPaise;

  final RentDueState state;
  final CalendarDate? cancelledOn;
  final String cancelReason;

  String get id => idFor(tenancyId, period);

  bool get isCancelled => state == RentDueState.cancelled;

  /// A cancelled copy. Throws [StateError] if already cancelled.
  RentDue cancelled({required CalendarDate on, required String reason}) {
    if (isCancelled) throw StateError('Due $id is already cancelled');
    return RentDue(
      tenancyId: tenancyId,
      tenantId: tenantId,
      unitId: unitId,
      propertyId: propertyId,
      period: period,
      dueDate: dueDate,
      amountPaise: amountPaise,
      state: RentDueState.cancelled,
      cancelledOn: on,
      cancelReason: reason.trim(),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'tenancyId': tenancyId,
    'tenantId': tenantId,
    'unitId': unitId,
    'propertyId': propertyId,
    'period': period.key,
    'dueDate': dueDate.toIso(),
    'amountPaise': amountPaise,
    'state': state.name,
    'cancelledOn': cancelledOn?.toIso(),
    'cancelReason': cancelReason,
  };

  factory RentDue.fromMap(Map<String, Object?> map) {
    final r = MapReader(map, 'RentDue');
    final due = RentDue(
      tenancyId: r.string('tenancyId'),
      tenantId: r.string('tenantId'),
      unitId: r.string('unitId'),
      propertyId: r.string('propertyId'),
      period: RentPeriod.parse(r.string('period')),
      dueDate: r.date('dueDate'),
      amountPaise: r.integer('amountPaise'),
      // Older maps without these keys read as active dues.
      state: map['state'] == null
          ? RentDueState.active
          : r.enumValue('state', RentDueState.values),
      cancelledOn: r.optDate('cancelledOn'),
      cancelReason: r.optString('cancelReason') ?? '',
    );
    if (map['id'] != null && map['id'] != due.id) {
      throw FormatException('RentDue.id does not match tenancy and period');
    }
    return due;
  }

  @override
  bool operator ==(Object other) =>
      other is RentDue &&
      other.tenancyId == tenancyId &&
      other.tenantId == tenantId &&
      other.unitId == unitId &&
      other.propertyId == propertyId &&
      other.period == period &&
      other.dueDate == dueDate &&
      other.amountPaise == amountPaise &&
      other.state == state &&
      other.cancelledOn == cancelledOn &&
      other.cancelReason == cancelReason;

  @override
  int get hashCode => Object.hash(
    tenancyId,
    tenantId,
    unitId,
    propertyId,
    period,
    dueDate,
    amountPaise,
    state,
    cancelledOn,
    cancelReason,
  );
}
