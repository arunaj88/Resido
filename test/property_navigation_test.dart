import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/screens/add_property_screen.dart';
import 'package:resido/features/properties/presentation/screens/edit_property_screen.dart';
import 'package:resido/features/properties/presentation/screens/property_details_screen.dart';
import 'package:resido/features/properties/presentation/screens/property_list_tab.dart';
import 'package:resido/features/properties/presentation/screens/unit_form_screen.dart';
import 'package:resido/features/properties/presentation/screens/unit_list_screen.dart';
import 'package:resido/features/properties/presentation/widgets/property_card.dart';
import 'package:resido/features/tenants/presentation/screens/assign_tenant_screen.dart';

import 'test_helpers.dart';

/// Pumps the signed-in shell and opens the Properties tab.
Future<void> pumpPropertyList(WidgetTester tester) async {
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
      matching: find.text('Properties'),
    ),
  );
  await settle(tester);
  expect(find.byType(PropertyListTab), findsOneWidget);
}

/// Scrolls the front-most list until [finder] is built, then taps it.
Future<void> scrollTap(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find.byType(Scrollable).hitTestable().first,
  );
  await tapVisible(tester, finder);
}

String fieldText(WidgetTester tester, String text) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.widgetWithText(TextField, text),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

void main() {
  testWidgets('Property List shows mock properties; chips and search filter', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    expect(find.text('Palm Grove Enclave'), findsOneWidget);
    expect(find.text('All (4)'), findsOneWidget);
    expect(find.text('Apartments (2)'), findsOneWidget);

    await tapVisible(tester, find.text('Commercial (1)'));
    expect(find.text('Palm Grove Enclave'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Malabar Heights Commercial'),
      200,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    expect(find.text('Malabar Heights Commercial'), findsOneWidget);

    await tapVisible(tester, find.text('All (4)'));
    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pump();
    expect(find.text('No properties match your filter'), findsOneWidget);
    await scrollTap(tester, find.text('Clear All Filters'));
    expect(find.text('Palm Grove Enclave'), findsOneWidget);

    await tester.tap(find.text('Preview Empty State'));
    await tester.pump();
    expect(find.text('No properties match your filter'), findsOneWidget);
    await tester.tap(find.text('Show Properties'));
    await tester.pump();
    expect(find.text('Palm Grove Enclave'), findsOneWidget);
  });

  testWidgets('List → Details → Edit keeps the selected property', (
    tester,
  ) async {
    await pumpPropertyList(tester);

    await tapVisible(tester, find.text('Palm Grove Enclave'));
    expect(find.byType(PropertyDetailsScreen), findsOneWidget);
    expect(find.text('ID: KL-EKM-2024-04'), findsOneWidget);

    await tapVisible(tester, find.text('Edit Property'));
    expect(find.byType(EditPropertyScreen), findsOneWidget);
    expect(fieldText(tester, 'Palm Grove Enclave'), 'Palm Grove Enclave');
    expect(fieldText(tester, '682036'), '682036');

    // Local edit, then Cancel: back on details, nothing persisted.
    await tester.enterText(
      find.widgetWithText(TextField, 'Palm Grove Enclave'),
      'Renamed',
    );
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(PropertyDetailsScreen), findsOneWidget);
    expect(find.text('Palm Grove Enclave'), findsWidgets);

    await tapVisible(tester, find.text('Edit Property'));
    await scrollTap(tester, find.text('Save Changes'));
    expect(find.byType(PropertyDetailsScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    expect(find.byType(PropertyListTab), findsOneWidget);
  });

  testWidgets('Edit Property danger zone shows the Deletion Blocked sheet', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    await tapVisible(tester, find.text('Palm Grove Enclave'));
    await tapVisible(tester, find.text('Edit Property'));
    await scrollTap(tester, find.text('Delete this Property'));
    expect(find.text('Deletion Blocked'), findsOneWidget);
    expect(find.text('2 Active Tenants'), findsOneWidget);
    await tapVisible(tester, find.text('Understood, Keep Property'));
    expect(find.text('Deletion Blocked'), findsNothing);
    expect(find.byType(EditPropertyScreen), findsOneWidget);
  });

  testWidgets('Details → Unit List → Add Unit and Edit Unit forms', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    await tapVisible(tester, find.text('Palm Grove Enclave'));

    await scrollTap(tester, find.text('View All Units'));
    expect(find.byType(UnitListScreen), findsOneWidget);
    expect(find.text('Units in Palm Grove Enclave'), findsOneWidget);

    // Filter to vacant units (the segment is the last "Vacant" label).
    await tester.tap(find.text('Vacant').last);
    await tester.pump();
    expect(find.text('Unit 101'), findsNothing);
    expect(find.text('Unit 201'), findsOneWidget);
    await tester.tap(find.text('All').first);
    await tester.pump();

    // Edit button on Unit 101 opens the prefilled form.
    await scrollTap(tester, find.byTooltip('Edit Unit 101'));
    expect(find.byType(UnitFormScreen), findsOneWidget);
    expect(find.text('Edit Unit'), findsOneWidget);
    expect(fieldText(tester, 'Unit 101'), 'Unit 101');
    expect(fieldText(tester, '24,000'), '24,000');
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(UnitListScreen), findsOneWidget);

    // Add Unit: empty form, required-field feedback, then back.
    await tapVisible(tester, find.text('Add Unit'));
    expect(find.byType(UnitFormScreen), findsOneWidget);
    await scrollTap(tester, find.text('Save Unit'));
    expect(
      find.text('Please provide an identifier for this unit.'),
      findsOneWidget,
    );
    expect(find.byType(UnitFormScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('Unit Number or Name'),
      -300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g., Flat 3B, Villa Annex, Shop #2'),
      'Unit 301',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'e.g., 20000'),
      '22000',
    );
    await tester.pump();
    expect(find.text('22,000'), findsOneWidget);
    await scrollTap(tester, find.text('Save Unit'));
    expect(find.byType(UnitListScreen), findsOneWidget);
  });

  testWidgets('Manage Units opens the unit list of that property', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    await tester.scrollUntilVisible(
      find.text('Kakkanad Tech Residency'),
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    final kakkanadManage = find.descendant(
      of: find.ancestor(
        of: find.text('Kakkanad Tech Residency'),
        matching: find.byType(PropertyCard),
      ),
      matching: find.text('Manage Units'),
    );
    await scrollTap(tester, kakkanadManage);
    expect(find.text('Units in Kakkanad Tech Residency'), findsOneWidget);
  });

  testWidgets('Assign Tenant on a vacant unit opens the Assign Tenant flow', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    await tapVisible(tester, find.text('Palm Grove Enclave'));
    await scrollTap(tester, find.text('View All Units'));
    await scrollTap(tester, find.text('Assign Tenant'));
    expect(find.byType(AssignTenantScreen), findsOneWidget);
    expect(find.text('Unit 201'), findsOneWidget);
  });

  testWidgets('Add Property: PIN feedback and Save returns to the list', (
    tester,
  ) async {
    await pumpPropertyList(tester);
    await tapVisible(tester, find.text('Add Property'));
    expect(find.byType(AddPropertyScreen), findsOneWidget);
    expect(find.text('Valid Kerala PIN'), findsOneWidget);

    final pin = find.widgetWithText(TextField, '682030');
    await tester.scrollUntilVisible(
      pin,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.enterText(pin, '5600');
    await tester.pump();
    expect(find.text('Incomplete'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, '5600'), '560001');
    await tester.pump();
    expect(find.text('Indian PIN (Non-Kerala)'), findsOneWidget);

    await scrollTap(tester, find.text('Save Property'));
    expect(find.byType(AddPropertyScreen), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 03 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final screens = <Widget>[
        PropertyListTab(onOpenNotifications: () {}, onOpenProfile: () {}),
        const AddPropertyScreen(),
        for (final p in PropertyMockData.properties) ...[
          PropertyDetailsScreen(property: p),
          EditPropertyScreen(property: p),
          UnitListScreen(property: p),
          UnitFormScreen(args: UnitFormArgs(property: p)),
          UnitFormScreen(
            args: UnitFormArgs(property: p, unit: p.units.first),
          ),
        ],
      ];
      for (final screen in screens) {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light(), home: screen),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final list = find.byType(Scrollable).first;
        await tester.fling(list, const Offset(0, -4000), 4000);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull, reason: '$screen at $size');
      }
    });
  }
}
