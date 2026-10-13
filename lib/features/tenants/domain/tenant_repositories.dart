import 'package:resido/core/domain/calendar_date.dart';
import 'package:resido/features/tenants/domain/tenancy.dart';
import 'package:resido/features/tenants/domain/tenant.dart';

abstract interface class TenantRepository {
  Future<List<Tenant>> getTenants();

  /// Null when no tenant has [id].
  Future<Tenant?> getTenant(String id);

  /// Creates or replaces a tenant.
  Future<void> saveTenant(Tenant tenant);
}

abstract interface class TenancyRepository {
  /// All tenancies, optionally only those of [tenantId] and/or [unitId].
  Future<List<Tenancy>> getTenancies({String? tenantId, String? unitId});

  /// Null when no tenancy has [id].
  Future<Tenancy?> getTenancy(String id);

  /// The unit's active (not ended) tenancy, if any.
  Future<Tenancy?> activeTenancyForUnit(String unitId);

  /// Creates or replaces a tenancy. Throws DomainException when the
  /// tenant, unit or property link is invalid, or when another active
  /// tenancy already holds the unit.
  Future<void> saveTenancy(Tenancy tenancy);

  /// Ends the tenancy on [on] (inclusive) and returns the updated record.
  Future<Tenancy> endTenancy(String id, CalendarDate on);
}
