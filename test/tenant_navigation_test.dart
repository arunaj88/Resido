import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/screens/add_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/assign_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/edit_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/tenancy_details_screen.dart';
import 'package:resido/features/tenants/presentation/screens/tenant_details_screen.dart';
import 'package:resido/features/tenants/presentation/screens/tenant_list_tab.dart';

import 'test_helpers.dart';

/// Pumps the signed-in shell and opens the Tenants tab.
Future<void> pumpTenantList(WidgetTester tester) async {
  useMobileViewport(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (_) => [
        AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.home)),
      ],
    ),
  );
  await settle(tester);
  await tester.tap(
    find.descendant(
      of: find.byType(ResidoBottomNav),
      matching: find.text('Tenants'),
    ),
  );
  await settle(tester);
  expect(find.byType(TenantListTab).hitTestable(), findsOneWidget);
}

/// Pumps a single route as the app's only page.
Future<void> pumpRoute(
  WidgetTester tester,
  String name, {
  Object? arguments,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.light(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (_) => [
        AppRoutes.onGenerateRoute(
          RouteSettings(name: name, arguments: arguments),
        ),
      ],
    ),
  );
  await settle(tester);
}

Finder get _list => find.byType(Scrollable).hitTestable().first;

Future<void> scrollTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300, scrollable: _list);
  await tapVisible(tester, finder);
}

Future<void> tapNext(WidgetTester tester) =>
    scrollTap(tester, find.text('Next'));

void main() {
  testWidgets('Tenant list: filters, search empty state and demo empty', (
    tester,
  ) async {
    await pumpTenantList(tester);
    expect(find.text('Suresh Kumar'), findsOneWidget);

    await tester.tap(find.text('Unassigned').last);
    await tester.pump();
    expect(find.text('Rahul Varma'), findsOneWidget);
    expect(find.text('Suresh Kumar'), findsNothing);

    await tester.tap(find.text('All').first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('No tenants found'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Suresh Kumar'), findsOneWidget);

    await tester.tap(find.text('Demo Empty'));
    await tester.pump();
    expect(find.text('No tenants found'), findsOneWidget);
    await tapVisible(tester, find.text('Add First Tenant'));
    expect(find.byType(AddTenantScreen), findsOneWidget);
  });

  testWidgets('List → Details → Tenancy Details and Edit; back returns', (
    tester,
  ) async {
    await pumpTenantList(tester);
    await tapVisible(tester, find.text('Suresh Kumar'));
    expect(find.byType(TenantDetailsScreen), findsOneWidget);
    expect(find.text('+91 98470 23411'), findsWidgets);

    await scrollTap(tester, find.text('View Tenancy Details'));
    expect(find.byType(TenancyDetailsScreen), findsOneWidget);
    expect(
      find.textContaining('Preview only.', findRichText: true),
      findsNothing,
    );
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    expect(find.byType(TenantDetailsScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Edit'));
    await settle(tester);
    expect(find.byType(EditTenantScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    expect(find.byType(TenantListTab).hitTestable(), findsOneWidget);
  });

  testWidgets('Lease link on a card opens Tenancy Details', (tester) async {
    await pumpTenantList(tester);
    await tapVisible(tester, find.text('Lease').first);
    expect(find.byType(TenancyDetailsScreen), findsOneWidget);
  });

  testWidgets('Unassigned tenant details offer Assign to Unit', (tester) async {
    useMobileViewport(tester);
    await pumpRoute(
      tester,
      AppRoutes.tenantDetails,
      arguments: TenantMockData.rahul,
    );
    expect(find.text('No active tenancy assigned'), findsOneWidget);
    await scrollTap(tester, find.text('Assign to Unit'));
    expect(find.byType(AssignTenantScreen), findsOneWidget);
    expect(find.text('Rahul Varma'), findsOneWidget);
  });

  testWidgets('Add Tenant: name is required; Cancel returns', (tester) async {
    useMobileViewport(tester);
    await pumpTenantList(tester);
    await tapVisible(tester, find.text('Add Tenant').last);
    expect(find.byType(AddTenantScreen), findsOneWidget);

    await scrollTap(tester, find.text('Save Tenant'));
    final nameError = find.text('Please enter the tenant’s full name.');
    await tester.scrollUntilVisible(nameError, -300, scrollable: _list);
    expect(nameError, findsOneWidget);
    expect(find.byType(AddTenantScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Kavitha Pillai');
    await tester.pump();
    await scrollTap(tester, find.text('Save Tenant'));
    expect(find.byType(AddTenantScreen), findsNothing);
    expect(find.byType(TenantListTab).hitTestable(), findsOneWidget);

    await tapVisible(tester, find.text('Add Tenant').last);
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(AddTenantScreen), findsNothing);
  });

  testWidgets('Assign Tenant: four steps, Back, then labelled preview', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(
      tester,
      AppRoutes.assignTenant,
      arguments: AssignTenantArgs(tenant: TenantMockData.rahul),
    );
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('Unit 201'), findsOneWidget);
    expect(find.text('Unit 202'), findsOneWidget);
    await tester.tap(find.text('Unit 202'));
    await tester.pump();
    await tapNext(tester);

    // Step 2: rent is prefilled from Unit 202; the deposit is never
    // calculated automatically, so Next is blocked until it is entered.
    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    expect(find.text('Refundable · entered by landlord'), findsOneWidget);
    await tapNext(tester);
    expect(find.text('Enter the security deposit in ₹.'), findsOneWidget);
    expect(find.text('STEP 2 OF 4'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '60000');
    await tester.pump();
    expect(find.text('60,000'), findsOneWidget);
    expect(find.text('Sixty Thousand Indian Rupees only'), findsOneWidget);
    await tapNext(tester);

    expect(find.text('STEP 3 OF 4'), findsOneWidget);
    await tester.tap(find.text('Open Ended'));
    await tester.pump();
    expect(find.text('Not set'), findsOneWidget);
    await scrollTap(tester, find.text('Back'));
    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    await tapNext(tester);
    await tapNext(tester);

    expect(find.text('STEP 4 OF 4'), findsOneWidget);
    expect(find.text('Assignment Summary'), findsOneWidget);
    expect(find.text('₹60,000'), findsOneWidget);
    await scrollTap(tester, find.text('Create Tenancy'));

    expect(find.byType(TenancyDetailsScreen), findsOneWidget);
    expect(find.byType(AssignTenantScreen), findsNothing);
    expect(
      find.textContaining('Preview only.', findRichText: true),
      findsOneWidget,
    );

    // A preview cannot be ended.
    expect(find.text('End Tenancy'), findsNothing);
  });

  testWidgets('End Tenancy asks first and changes nothing', (tester) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.tenancyDetails);
    await scrollTap(tester, find.text('End Tenancy'));
    expect(find.text('Keep Tenancy Active'), findsOneWidget);
    await tester.tap(find.text('Keep Tenancy Active'));
    await settle(tester);
    expect(find.text('Keep Tenancy Active'), findsNothing);

    await scrollTap(tester, find.text('End Tenancy'));
    await tester.tap(find.text('End Tenancy').last);
    await settle(tester);
    expect(
      find.text('Preview only — the tenancy was not changed.'),
      findsOneWidget,
    );
    expect(find.byType(TenancyDetailsScreen), findsOneWidget);
  });

  testWidgets('Forms stay usable with the keyboard open', (tester) async {
    useMobileViewport(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);

    for (final (route, args) in <(String, Object?)>[
      (AppRoutes.addTenant, null),
      (AppRoutes.editTenant, TenantMockData.suresh),
      (AppRoutes.assignTenant, AssignTenantArgs(tenant: TenantMockData.meera)),
    ]) {
      await pumpRoute(tester, route, arguments: args);
      // Assign step 1 has no text field; the amounts are on step 2.
      if (route == AppRoutes.assignTenant) await tapNext(tester);
      await tester.showKeyboard(find.byType(TextField).first);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: route);
      expect(find.byType(TextField).first.hitTestable(), findsOneWidget);
    }
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 04 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final suresh = TenantMockData.suresh;
      for (final (route, args) in <(String, Object?)>[
        (AppRoutes.home, null),
        (AppRoutes.addTenant, null),
        (AppRoutes.tenantDetails, suresh),
        (AppRoutes.tenantDetails, TenantMockData.meera),
        (AppRoutes.editTenant, suresh),
        (AppRoutes.editTenant, TenantMockData.firoz),
        (AppRoutes.assignTenant, const AssignTenantArgs()),
        (
          AppRoutes.tenancyDetails,
          TenancyDetailsArgs(tenant: suresh, tenancy: suresh.tenancy!),
        ),
        (
          AppRoutes.tenancyDetails,
          TenancyDetailsArgs(
            tenant: TenantMockData.thomas,
            tenancy: TenantMockData.thomas.tenancy!,
            preview: true,
          ),
        ),
      ]) {
        await pumpRoute(tester, route, arguments: args);
        if (route == AppRoutes.home) {
          await tester.tap(
            find.descendant(
              of: find.byType(ResidoBottomNav),
              matching: find.text('Tenants'),
            ),
          );
          await settle(tester);
        }
        // Scroll the whole page so every lazily built item lays out.
        final scrollable = find.byType(Scrollable).hitTestable();
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -4000));
          await settle(tester);
        }
        expect(tester.takeException(), isNull, reason: '$route $args');
      }
    });
  }

  testWidgets('Assign Tenant steps lay out at 320 px', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpRoute(
      tester,
      AppRoutes.assignTenant,
      arguments: AssignTenantArgs(tenant: TenantMockData.meera),
    );
    await tapNext(tester);
    await tester.enterText(find.byType(TextField).at(1), '72000');
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tapNext(tester);
    expect(tester.takeException(), isNull);
    await tapNext(tester);
    expect(find.text('Assignment Summary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
