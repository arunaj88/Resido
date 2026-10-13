import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/app_scope.dart';
import 'package:resido/features/profile/data/in_memory_user_profile_repository.dart';
import 'package:resido/features/properties/data/in_memory_property_repository.dart';
import 'package:resido/features/rent/data/in_memory_rent_repository.dart';
import 'package:resido/features/tenants/data/in_memory_tenant_repositories.dart';
import 'package:resido/features/maintenance/data/in_memory_maintenance_repository.dart';

void main() {
  testWidgets('descendants and routes read dependencies from AppScope', (
    tester,
  ) async {
    final deps = AppDependencies.inMemorySeeded();
    AppDependencies? fromHome;
    AppDependencies? fromPushedRoute;

    await tester.pumpWidget(
      AppScope(
        dependencies: deps,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              fromHome = AppScope.of(context);
              return TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      fromPushedRoute = AppScope.of(context);
                      return const Text('Pushed');
                    },
                  ),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );
    expect(fromHome, same(deps));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Pushed'), findsOneWidget);
    expect(fromPushedRoute, same(deps));
  });

  testWidgets('a missing AppScope gives a descriptive error', (tester) async {
    Object? error;
    AppDependencies? maybe = AppDependencies.inMemorySeeded();
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          maybe = AppScope.maybeOf(context);
          try {
            AppScope.of(context);
          } catch (e) {
            error = e;
          }
          return const SizedBox();
        },
      ),
    );
    expect(maybe, isNull);
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('no AppScope in the tree'));
  });

  test('dependencies are easy to build from parts in tests', () async {
    final properties = InMemoryPropertyRepository();
    final tenants = InMemoryTenantRepository();
    final deps = AppDependencies(
      properties: properties,
      tenants: tenants,
      tenancies: InMemoryTenancyRepository(
        tenants: tenants,
        properties: properties,
      ),
      rent: InMemoryRentRepository(),
      maintenance: InMemoryMaintenanceRepository(properties: properties),
      profile: InMemoryUserProfileRepository(),
    );
    expect(await deps.properties.getProperties(), isEmpty);
    expect(await deps.profile.getProfile(), isNull);
  });

  testWidgets('replacing the dependencies notifies dependents', (tester) async {
    var builds = 0;
    final child = Builder(
      builder: (context) {
        AppScope.of(context);
        builds++;
        return const SizedBox();
      },
    );
    final a = AppDependencies.inMemorySeeded();
    await tester.pumpWidget(AppScope(dependencies: a, child: child));
    await tester.pumpWidget(AppScope(dependencies: a, child: child));
    expect(builds, 1);
    await tester.pumpWidget(
      AppScope(dependencies: AppDependencies.inMemorySeeded(), child: child),
    );
    expect(builds, 2);
  });
}
