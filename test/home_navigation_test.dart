import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/coming_soon_view.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_view.dart';
import 'package:resido/features/dashboard/presentation/widgets/empty_dashboard_view.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:resido/features/properties/presentation/screens/add_property_screen.dart';
import 'package:resido/features/properties/presentation/screens/property_list_tab.dart';

import 'test_helpers.dart';

/// Pumps the app starting at the signed-in shell.
Future<void> pumpHome(WidgetTester tester, {bool empty = false}) async {
  useMobileViewport(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (_) => [
        AppRoutes.onGenerateRoute(
          RouteSettings(
            name: AppRoutes.home,
            arguments: HomeArgs(emptyPortfolio: empty),
          ),
        ),
      ],
    ),
  );
  await settle(tester);
}

Finder navItem(HomeTab tab) => find.descendant(
  of: find.byType(ResidoBottomNav),
  matching: find.text(tab.label),
);

void main() {
  group('InrFormat', () {
    test('uses Indian digit grouping', () {
      expect(InrFormat.full(0), '₹0');
      expect(InrFormat.full(999), '₹999');
      expect(InrFormat.full(11000), '₹11,000');
      expect(InrFormat.full(152000), '₹1,52,000');
      expect(InrFormat.full(1234567), '₹12,34,567');
    });

    test('compacts to K / L / Cr', () {
      expect(InrFormat.compact(33000), '₹33K');
      expect(InrFormat.compact(152000), '₹1.52L');
      expect(InrFormat.compact(12500000), '₹1.25Cr');
    });
  });

  testWidgets('Dashboard shows mock portfolio with rupee amounts', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.text('₹1,52,000'), findsOneWidget);
    expect(find.text('Target: ₹1,85,000'), findsOneWidget);
    expect(find.text('₹1.52L collected'), findsOneWidget);

    // Both segments of the collection progress bar are actually drawn.
    for (final color in [
      AppColors.primaryContainer,
      AppColors.onTertiaryContainer,
    ]) {
      final segment = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == color && w.child == null,
      );
      expect(tester.getSize(segment).height, 10);
    }
  });

  testWidgets('Bottom navigation switches tabs; back returns to Dashboard', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(navItem(HomeTab.properties));
    await settle(tester);
    expect(find.byType(PropertyListTab).hitTestable(), findsOneWidget);

    for (final tab in [HomeTab.tenants, HomeTab.rent, HomeTab.profile]) {
      await tester.tap(navItem(tab));
      await settle(tester);
      final shownTitle = find.descendant(
        of: find.byType(ComingSoonView),
        matching: find.text(tab.label),
      );
      expect(shownTitle.hitTestable(), findsOneWidget, reason: tab.label);
    }

    // System back from a non-dashboard tab goes to Dashboard, not out.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(DashboardView).hitTestable(), findsOneWidget);
  });

  testWidgets('Header bell opens Notifications; back returns', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await settle(tester);
    expect(find.byType(NotificationsScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await settle(tester);
    expect(find.byType(DashboardView), findsOneWidget);
  });

  testWidgets('Dashboard actions open placeholders and the Rent tab', (
    tester,
  ) async {
    await pumpHome(tester);

    await tapVisible(tester, find.text('Add Property'));
    expect(find.byType(AddPropertyScreen), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    await tester.scrollUntilVisible(
      find.text('Assign Plumber'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapVisible(tester, find.text('Assign Plumber'));
    expect(find.text('Maintenance Request'), findsWidgets);
    await tester.pageBack();
    await settle(tester);

    await tester.scrollUntilVisible(
      find.text('October Rent Collection'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapVisible(tester, find.text('October Rent Collection'));
    expect(
      find
          .descendant(
            of: find.byType(ComingSoonView),
            matching: find.text('Rent'),
          )
          .hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('Empty Dashboard: add property and explore preview', (
    tester,
  ) async {
    await pumpHome(tester, empty: true);
    expect(find.byType(EmptyDashboardView), findsOneWidget);
    expect(find.text("Let's add your first property"), findsOneWidget);

    await tapVisible(tester, find.text('Add Your First Property'));
    expect(find.byType(AddPropertyScreen), findsOneWidget);
    await tester.pageBack();
    await settle(tester);

    await tapVisible(tester, find.text('Explore Dashboard Preview'));
    expect(find.byType(DashboardView), findsOneWidget);
    expect(find.byType(EmptyDashboardView), findsNothing);
  });

  testWidgets('Notifications: filters, mark all read, open item', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byTooltip('Notifications'));
    await settle(tester);

    expect(find.byKey(const ValueKey('unread-dot')), findsNWidgets(2));
    await tester.tap(find.text('Mark all as read'));
    await tester.pump();
    expect(find.byKey(const ValueKey('unread-dot')), findsNothing);
    expect(find.text('All Caught Up'), findsOneWidget);

    await tester.tap(find.text('Maintenance'));
    await tester.pump();
    expect(find.text('Plumbing Request Updated'), findsOneWidget);
    expect(find.text('Rent Received: ₹24,000'), findsNothing);
    expect(find.text('Earlier This Week'), findsNothing);

    await tapVisible(tester, find.text('Plumbing Request Updated'));
    expect(find.byType(ComingSoonScreen), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 02 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final screen in <Widget>[
        const HomeShell(),
        const HomeShell(args: HomeArgs(emptyPortfolio: true)),
        const NotificationsScreen(),
      ]) {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light(), home: screen),
        );
        await tester.pump(const Duration(milliseconds: 100));
        // Scroll through the whole list to lay out every section.
        final list = find.byType(Scrollable).first;
        await tester.fling(list, const Offset(0, -3000), 3000);
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull, reason: '$screen at $size');
      }
    });
  }
}
