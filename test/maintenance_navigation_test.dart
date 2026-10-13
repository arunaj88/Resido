import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/screens/maintenance_form_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/maintenance_list_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/request_details_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/update_status_screen.dart';

import 'test_helpers.dart';

/// Pumps [name] above a placeholder first page, so back has somewhere to go.
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
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Start')),
        ),
        AppRoutes.onGenerateRoute(
          RouteSettings(name: name, arguments: arguments),
        ),
      ],
    ),
  );
  await settle(tester);
}

/// The front-most vertical list (screens also contain horizontal chip rows).
Finder get _list => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Future<void> scrollTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 300, scrollable: _list);
  await tapVisible(tester, finder);
}

/// Scrolls down until a text field is built, then brings it into view.
Future<void> revealTextField(WidgetTester tester) async {
  for (var i = 0; i < 10 && find.byType(TextField).evaluate().isEmpty; i++) {
    await tester.drag(_list, const Offset(0, -200));
    await tester.pump();
  }
  await tester.ensureVisible(find.byType(TextField).first);
  await settle(tester);
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await settle(tester);
}

void main() {
  testWidgets('List: filters, search, empty preview and Create Request', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.maintenance);
    expect(find.text('Overhead Water Tank Motor Tripping'), findsOneWidget);

    await tapVisible(tester, find.text('Completed').first);
    expect(find.text('Overhead Water Tank Motor Tripping'), findsNothing);
    expect(find.text('Balcony Sliding Door Latch Replacement'), findsOneWidget);

    await tapVisible(tester, find.text('All'));
    await tester.enterText(find.byType(TextField).first, 'kseb');
    await tester.pump();
    expect(
      find.text('KSEB Main DB Phase 2 Voltage Fluctuation'),
      findsOneWidget,
    );
    expect(find.text('Overhead Water Tank Motor Tripping'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await scrollTap(tester, find.byType(Switch));
    expect(find.text('No Maintenance Requests'), findsOneWidget);
    await scrollTap(tester, find.text('Create Request'));
    expect(find.byType(MaintenanceFormScreen), findsOneWidget);
    expect(find.text('Create Request'), findsWidgets);
  });

  testWidgets('List → Details → Update Status → Save returns, unchanged', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.maintenance);

    await tester.enterText(find.byType(TextField).first, 'seepage');
    await tester.pump();
    await scrollTap(tester, find.text('View Details'));
    expect(find.byType(RequestDetailsScreen), findsOneWidget);
    expect(find.text('#MNT-2024-PG-04'), findsOneWidget);
    expect(find.text('+91 94471 88920'), findsOneWidget);

    await scrollTap(tester, find.text('Update Status'));
    expect(find.byType(UpdateStatusScreen), findsOneWidget);
    expect(find.text('Resolution Details'), findsNothing);
    await tapVisible(tester, find.text('Completed'));
    expect(find.text('Resolution Details'), findsOneWidget);

    await scrollTap(tester, find.text('Save Changes'));
    expect(find.byType(UpdateStatusScreen), findsNothing);
    expect(find.byType(RequestDetailsScreen), findsOneWidget);
    expect(
      find.text('Preview only — the request status was not changed.'),
      findsOneWidget,
    );
    // The request still shows its original status.
    await tester.scrollUntilVisible(
      find.text('IN PROGRESS'),
      -300,
      scrollable: _list,
    );
    expect(find.text('IN PROGRESS'), findsOneWidget);

    await back(tester);
    expect(find.byType(MaintenanceListScreen), findsOneWidget);
  });

  testWidgets('Update Status: Cancel returns without a message', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(
      tester,
      AppRoutes.maintenanceDetails,
      arguments: MaintenanceMockData.voltage,
    );
    await scrollTap(tester, find.text('Update Status'));
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(RequestDetailsScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Create Request: form controls, preview message, back to list', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.maintenance);
    await tapVisible(tester, find.text('New Request'));
    expect(find.byType(MaintenanceFormScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Gate hinge broken');
    await tester.pump();
    expect(find.text('17 / 80'), findsOneWidget);

    await scrollTap(
      tester,
      find.text('Applies to entire property / common areas'),
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    await scrollTap(tester, find.text('Electrical'));
    await scrollTap(tester, find.text('Urgent'));
    await scrollTap(tester, find.text('24 Oct 2024 (Today)'));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await settle(tester);

    await scrollTap(
      tester,
      find.descendant(
        of: find.byType(ListView),
        matching: find.text('Create Request'),
      ),
    );
    expect(find.byType(MaintenanceFormScreen), findsNothing);
    expect(find.byType(MaintenanceListScreen), findsOneWidget);
    expect(
      find.text('Preview only — the request was not saved.'),
      findsOneWidget,
    );
    // Still the six static requests.
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('Details → Edit Request is prefilled; Cancel returns', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(
      tester,
      AppRoutes.maintenanceDetails,
      arguments: MaintenanceMockData.seepage,
    );
    await scrollTap(tester, find.text('Edit Request Details'));
    expect(find.text('Edit Request'), findsOneWidget);
    expect(
      find.text('Master Bath Ceiling Seepage & Pipe Leak'),
      findsOneWidget,
    );
    expect(find.text('Unit 102 (Ananya Nair)'), findsOneWidget);

    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(RequestDetailsScreen), findsOneWidget);
  });

  testWidgets('Forms stay usable with the keyboard open', (tester) async {
    useMobileViewport(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);

    await pumpRoute(tester, AppRoutes.maintenanceForm);
    await revealTextField(tester);
    await tester.showKeyboard(find.byType(TextField).first);
    await settle(tester);
    expect(tester.takeException(), isNull);

    await pumpRoute(
      tester,
      AppRoutes.updateStatus,
      arguments: MaintenanceMockData.latch,
    );
    await revealTextField(tester);
    await tester.showKeyboard(find.byType(TextField).first);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField).first.hitTestable(), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 06 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final (route, args) in <(String, Object?)>[
        (AppRoutes.maintenance, null),
        (AppRoutes.maintenanceForm, null),
        for (final r in MaintenanceMockData.requests) ...[
          (AppRoutes.maintenanceDetails, r),
          (AppRoutes.maintenanceForm, r),
          (AppRoutes.updateStatus, r),
        ],
      ]) {
        await pumpRoute(tester, route, arguments: args);
        await tester.drag(_list, const Offset(0, -6000));
        await settle(tester);
        expect(tester.takeException(), isNull, reason: '$route $args');
      }

      // The resolution section appears only when Completed is chosen.
      await pumpRoute(
        tester,
        AppRoutes.updateStatus,
        arguments: MaintenanceMockData.seepage,
      );
      await tapVisible(tester, find.text('Completed'));
      await tester.drag(_list, const Offset(0, -6000));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'resolution section');
    });
  }
}
