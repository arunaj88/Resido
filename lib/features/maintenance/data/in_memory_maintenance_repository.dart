import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/validators.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart'
    as mock;
import 'package:resido/features/maintenance/domain/maintenance_request.dart';
import 'package:resido/features/maintenance/domain/maintenance_repository.dart';
import 'package:resido/features/properties/data/in_memory_property_repository.dart';
import 'package:resido/features/properties/domain/property_repository.dart';
import 'package:resido/features/tenants/data/in_memory_tenant_repositories.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart'
    as tenant_mock;

/// In-memory maintenance requests. Saving checks the property and unit
/// links against [properties] (local emulation of future backend rules,
/// not a security guarantee). Each instance has its own state.
class InMemoryMaintenanceRepository implements MaintenanceRepository {
  InMemoryMaintenanceRepository({
    required PropertyRepository properties,
    Iterable<MaintenanceRequest> requests = const [],
  }) : _propertyRepo = properties {
    for (final r in requests) {
      _requests[r.id] = r;
    }
  }

  factory InMemoryMaintenanceRepository.seeded({
    required PropertyRepository properties,
  }) => InMemoryMaintenanceRepository(
    properties: properties,
    requests: seedRequests(),
  );

  /// The six requests in [mock.MaintenanceMockData]. The mock dates have no
  /// year, so they are read as 2024 (the app's mock cycle) and as IST.
  static List<MaintenanceRequest> seedRequests() => [
    for (final m in mock.MaintenanceMockData.requests) _fromMock(m),
  ];

  static MaintenanceRequest _fromMock(mock.MaintenanceRequest m) {
    final id = m.id.replaceFirst('#', '');
    String? unitId;
    if (!m.entireProperty) {
      for (final u in m.property.units) {
        if (m.locationLabel.startsWith(u.name) ||
            m.locationLabel.startsWith(u.number)) {
          unitId = InMemoryPropertyRepository.unitIdFor(
            m.property.id,
            u.number,
          );
          break;
        }
      }
    }
    String? tenantId;
    for (final t in tenant_mock.TenantMockData.tenants) {
      if (t.name == m.tenantName) tenantId = t.id;
    }

    // Mock log is newest first; domain events are oldest first.
    final entries = m.log.reversed.toList();
    MaintenanceStatus? previous;
    final events = <MaintenanceEvent>[];
    for (final (i, e) in entries.indexed) {
      final to = switch (e.title) {
        final t when t.contains('Completed') => MaintenanceStatus.completed,
        final t when t.contains('In Progress') => MaintenanceStatus.inProgress,
        _ => MaintenanceStatus.open,
      };
      events.add(
        MaintenanceEvent(
          id: '$id-e${i + 1}',
          at: _mockInstant(e.time),
          fromStatus: previous,
          toStatus: to,
          note: e.note,
        ),
      );
      previous = to;
    }

    return MaintenanceRequest(
      id: id,
      propertyId: m.property.id,
      unitId: unitId,
      entireProperty: m.entireProperty,
      tenantId: tenantId,
      title: m.title,
      category: MaintenanceCategory.values.byName(m.category.name),
      priority: MaintenancePriority.values.byName(m.priority.name),
      status: MaintenanceStatus.values.byName(m.status.name),
      description: m.description,
      reportedOn: _mockDay(m.reportedLong),
      assigneeName: m.assignee ?? '',
      assigneePhone: Validators.normalizeIndianMobile(m.assigneePhone),
      completedOn: m.completedOn == null
          ? null
          : InMemoryTenancyRepository.parseMockDate(m.completedOn!),
      resolution: m.resolution ?? '',
      costPaise: m.cost == null ? null : Money.parseRupees(m.cost!),
      events: events,
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "Reported 24 Oct, 08:10 AM" → 2024-10-24.
  static CalendarDate _mockDay(String text) {
    final m = RegExp(r'(\d{1,2}) ([A-Z][a-z]{2})').firstMatch(text)!;
    return CalendarDate(2024, _months.indexOf(m[2]!) + 1, int.parse(m[1]!));
  }

  /// "24 Oct · 11:00 AM" (IST, 2024) → UTC instant.
  static DateTime _mockInstant(String text) {
    final day = _mockDay(text);
    final t = RegExp(r'(\d{1,2}):(\d{2}) (AM|PM)').firstMatch(text)!;
    var hour = int.parse(t[1]!) % 12;
    if (t[3] == 'PM') hour += 12;
    return DateTime.utc(
      day.year,
      day.month,
      day.day,
      hour,
      int.parse(t[2]!),
    ).subtract(CalendarDate.istOffset);
  }

  final PropertyRepository _propertyRepo;
  final _requests = <String, MaintenanceRequest>{};

  @override
  Future<List<MaintenanceRequest>> getRequests({String? propertyId}) async =>
      List.unmodifiable(
        _requests.values.where(
          (r) => propertyId == null || r.propertyId == propertyId,
        ),
      );

  @override
  Future<MaintenanceRequest?> getRequest(String id) async => _requests[id];

  @override
  Future<void> saveRequest(MaintenanceRequest request) async {
    if (await _propertyRepo.getProperty(request.propertyId) == null) {
      throw RecordNotFoundException('Property', request.propertyId);
    }
    final unitId = request.unitId;
    if (unitId != null) {
      final unit = await _propertyRepo.getUnit(unitId);
      if (unit == null) throw RecordNotFoundException('Unit', unitId);
      if (unit.propertyId != request.propertyId) {
        throw const DomainException(
          'unit-property-mismatch',
          'The unit does not belong to the request\'s property',
        );
      }
    }
    _requests[request.id] = request;
  }
}
