import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/core/domain/domain_exception.dart';
import 'package:resido/core/domain/money.dart';
import 'package:resido/core/domain/validators.dart';
import 'package:resido/features/properties/data/in_memory_property_repository.dart';
import 'package:resido/features/properties/domain/property_repository.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart' as mock;
import 'package:resido/features/tenants/domain/tenancy.dart';
import 'package:resido/features/tenants/domain/tenant.dart';
import 'package:resido/features/tenants/domain/tenant_repositories.dart';

/// In-memory tenants. Each instance has its own state.
class InMemoryTenantRepository implements TenantRepository {
  InMemoryTenantRepository([Iterable<Tenant> tenants = const []]) {
    for (final t in tenants) {
      _tenants[t.id] = t;
    }
  }

  /// Seeded from [mock.TenantMockData]: all six tenants.
  factory InMemoryTenantRepository.seeded() =>
      InMemoryTenantRepository(seedTenants());

  static List<Tenant> seedTenants() => [
    for (final t in mock.TenantMockData.tenants)
      Tenant(
        id: t.id,
        name: t.name,
        phone: Validators.normalizeIndianMobile(t.phone),
        email: t.email,
        notes: t.notes,
      ),
  ];

  final _tenants = <String, Tenant>{};

  @override
  Future<List<Tenant>> getTenants() async => List.unmodifiable(_tenants.values);

  @override
  Future<Tenant?> getTenant(String id) async => _tenants[id];

  @override
  Future<void> saveTenant(Tenant tenant) async => _tenants[tenant.id] = tenant;
}

/// In-memory tenancies. Saving checks the tenant, unit and property links
/// against the given repositories and keeps one active tenancy per unit.
///
/// These checks emulate future backend rules for local use and tests only;
/// they provide no security or atomicity guarantees.
class InMemoryTenancyRepository implements TenancyRepository {
  InMemoryTenancyRepository({
    required TenantRepository tenants,
    required PropertyRepository properties,
    Iterable<Tenancy> tenancies = const [],
  }) : _tenantRepo = tenants,
       _propertyRepo = properties {
    for (final t in tenancies) {
      _tenancies[t.id] = t;
    }
  }

  /// Seeded from the three tenancies in [mock.TenantMockData].
  factory InMemoryTenancyRepository.seeded({
    required TenantRepository tenants,
    required PropertyRepository properties,
  }) => InMemoryTenancyRepository(
    tenants: tenants,
    properties: properties,
    tenancies: seedTenancies(),
  );

  static List<Tenancy> seedTenancies() => [
    for (final t in mock.TenantMockData.tenants)
      if (t.tenancy case final tenancy?)
        Tenancy(
          id: tenancy.reference.replaceFirst('#', ''),
          tenantId: t.id,
          unitId: InMemoryPropertyRepository.unitIdFor(
            tenancy.property.id,
            tenancy.unit.number,
          ),
          propertyId: tenancy.property.id,
          startDate: parseMockDate(tenancy.startDate),
          endDate: tenancy.endDate.isEmpty
              ? null
              : parseMockDate(tenancy.endDate),
          rentPaise: Money.fromRupees(tenancy.rent),
          depositPaise: Money.fromRupees(tenancy.deposit),
          dueDay: int.parse(RegExp(r'\d+').firstMatch(tenancy.dueDay)![0]!),
        ),
  ];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Parses the mock data's "01 Oct 2023" dates.
  static CalendarDate parseMockDate(String text) {
    final parts = text.trim().split(' ');
    if (parts.length != 3) {
      throw FormatException('Expected "DD Mon YYYY"', text);
    }
    final month = _months.indexOf(parts[1]) + 1;
    if (month == 0) throw FormatException('Unknown month', text);
    return CalendarDate(int.parse(parts[2]), month, int.parse(parts[0]));
  }

  final TenantRepository _tenantRepo;
  final PropertyRepository _propertyRepo;
  final _tenancies = <String, Tenancy>{};

  @override
  Future<List<Tenancy>> getTenancies({
    String? tenantId,
    String? unitId,
  }) async => List.unmodifiable(
    _tenancies.values.where(
      (t) =>
          (tenantId == null || t.tenantId == tenantId) &&
          (unitId == null || t.unitId == unitId),
    ),
  );

  @override
  Future<Tenancy?> getTenancy(String id) async => _tenancies[id];

  @override
  Future<Tenancy?> activeTenancyForUnit(String unitId) async {
    for (final t in _tenancies.values) {
      if (t.unitId == unitId && t.isActive) return t;
    }
    return null;
  }

  @override
  Future<void> saveTenancy(Tenancy tenancy) async {
    if (await _tenantRepo.getTenant(tenancy.tenantId) == null) {
      throw RecordNotFoundException('Tenant', tenancy.tenantId);
    }
    final unit = await _propertyRepo.getUnit(tenancy.unitId);
    if (unit == null) throw RecordNotFoundException('Unit', tenancy.unitId);
    if (unit.propertyId != tenancy.propertyId) {
      throw const DomainException(
        'tenancy-property-mismatch',
        'The unit does not belong to the given property',
      );
    }
    final existing = _tenancies[tenancy.id];
    if (existing != null &&
        (existing.tenantId != tenancy.tenantId ||
            existing.unitId != tenancy.unitId)) {
      throw const DomainException(
        'tenancy-links-immutable',
        'A tenancy cannot be moved to another tenant or unit',
      );
    }
    if (tenancy.isActive) {
      final holder = await activeTenancyForUnit(tenancy.unitId);
      if (holder != null && holder.id != tenancy.id) {
        throw DomainException(
          'unit-occupied',
          'Unit already has active tenancy ${holder.id}',
        );
      }
    }
    _tenancies[tenancy.id] = tenancy;
  }

  @override
  Future<Tenancy> endTenancy(String id, CalendarDate on) async {
    final tenancy = _tenancies[id];
    if (tenancy == null) throw RecordNotFoundException('Tenancy', id);
    if (!tenancy.isActive) {
      throw DomainException('tenancy-ended', 'Tenancy $id has already ended');
    }
    if (on.isBefore(tenancy.startDate)) {
      throw const DomainException(
        'invalid-end-date',
        'A tenancy cannot end before it starts',
      );
    }
    return _tenancies[id] = tenancy.end(on);
  }
}
