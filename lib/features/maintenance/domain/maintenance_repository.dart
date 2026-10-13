import 'package:resido/features/maintenance/domain/maintenance_request.dart';

abstract interface class MaintenanceRepository {
  /// All requests, optionally only one property's.
  Future<List<MaintenanceRequest>> getRequests({String? propertyId});

  /// Null when no request has [id].
  Future<MaintenanceRequest?> getRequest(String id);

  /// Creates or replaces a request. Throws DomainException when the
  /// property or unit link is invalid.
  Future<void> saveRequest(MaintenanceRequest request);
}
