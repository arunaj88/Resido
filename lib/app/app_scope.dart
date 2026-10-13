import 'package:flutter/widgets.dart';
import 'package:resido/features/maintenance/data/in_memory_maintenance_repository.dart';
import 'package:resido/features/maintenance/domain/maintenance_repository.dart';
import 'package:resido/features/profile/data/in_memory_user_profile_repository.dart';
import 'package:resido/features/profile/domain/user_profile_repository.dart';
import 'package:resido/features/properties/data/in_memory_property_repository.dart';
import 'package:resido/features/properties/domain/property_repository.dart';
import 'package:resido/features/rent/data/in_memory_rent_repository.dart';
import 'package:resido/features/rent/domain/rent_repository.dart';
import 'package:resido/features/tenants/data/in_memory_tenant_repositories.dart';
import 'package:resido/features/tenants/domain/tenant_repositories.dart';

/// The app's repositories. Construct it directly (e.g. with fakes in
/// tests) or use [AppDependencies.inMemorySeeded].
class AppDependencies {
  const AppDependencies({
    required this.properties,
    required this.tenants,
    required this.tenancies,
    required this.rent,
    required this.maintenance,
    required this.profile,
  });

  /// Fresh in-memory repositories seeded from the existing mock data. Each
  /// call returns independent state.
  factory AppDependencies.inMemorySeeded() {
    final properties = InMemoryPropertyRepository.seeded();
    final tenants = InMemoryTenantRepository.seeded();
    return AppDependencies(
      properties: properties,
      tenants: tenants,
      tenancies: InMemoryTenancyRepository.seeded(
        tenants: tenants,
        properties: properties,
      ),
      rent: InMemoryRentRepository.seeded(
        InMemoryTenancyRepository.seedTenancies(),
      ),
      maintenance: InMemoryMaintenanceRepository.seeded(properties: properties),
      profile: InMemoryUserProfileRepository.seeded(),
    );
  }

  final PropertyRepository properties;
  final TenantRepository tenants;
  final TenancyRepository tenancies;
  final RentRepository rent;
  final MaintenanceRepository maintenance;
  final UserProfileRepository profile;
}

/// Provides [AppDependencies] to the widget tree (Flutter SDK only; no
/// global service locator). Placed above `MaterialApp`, so every route can
/// reach it.
///
/// ```dart
/// final rent = AppScope.of(context).rent;
/// ```
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  /// The nearest dependencies. Throws a descriptive [FlutterError] when no
  /// [AppScope] is above [context].
  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary('AppScope.of() called with no AppScope in the tree.'),
        ErrorDescription(
          'The widget that called it (${context.widget.runtimeType}) is not '
          'below an AppScope.',
        ),
        ErrorHint(
          'Wrap the app (or the widget under test) in '
          'AppScope(dependencies: ..., child: ...).',
        ),
      ]);
    }
    return scope.dependencies;
  }

  /// The nearest dependencies, or null when there is no [AppScope].
  static AppDependencies? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()?.dependencies;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      !identical(dependencies, oldWidget.dependencies);
}
