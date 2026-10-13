import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/partial_payment_screen.dart';
import 'package:resido/features/rent/presentation/screens/payment_history_view.dart';
import 'package:resido/features/rent/presentation/screens/receipt_screen.dart';
import 'package:resido/features/rent/presentation/screens/record_payment_screen.dart';
import 'package:resido/features/rent/presentation/screens/rent_details_screen.dart';
import 'package:resido/features/rent/presentation/screens/rent_due_view.dart';
import 'package:resido/features/rent/presentation/screens/rent_overview_view.dart';
import 'package:resido/features/rent/presentation/screens/rent_tab.dart';
import 'package:resido/features/tenants/presentation/screens/tenancy_details_screen.dart';

import 'test_helpers.dart';

/// Pumps the signed-in shell and opens the Rent tab.
Future<void> pumpRentTab(WidgetTester tester) async {
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
      matching: find.text('Rent'),
    ),
  );
  await settle(tester);
  expect(find.byType(RentOverviewView).hitTestable(), findsOneWidget);
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

/// The front-most vertical list (the screens also contain horizontal chip
/// rows).
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

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await settle(tester);
}

void main() {
  testWidgets('Rent tab switches between Overview, Rent Due and History', (
    tester,
  ) async {
    await pumpRentTab(tester);
    expect(find.text(RentMockData.expected), findsOneWidget);

    await tapVisible(tester, find.text('Rent Due').first);
    expect(find.byType(RentDueView), findsOneWidget);
    await tester.tap(find.text('Rent Overview').last);
    await settle(tester);
    expect(find.byType(RentOverviewView), findsOneWidget);

    await tapVisible(tester, find.text('Payment History').first);
    expect(find.byType(PaymentHistoryView), findsOneWidget);
    await tester.tap(find.text('Rent Overview').last);
    await settle(tester);

    await scrollTap(tester, find.text('Rent Due & Receivables'));
    expect(find.byType(RentDueView), findsOneWidget);
    await scrollTap(tester, find.textContaining('Check Payment History'));
    expect(find.byType(PaymentHistoryView), findsOneWidget);
  });

  testWidgets('Rent Due: filters, search empty state and reset', (
    tester,
  ) async {
    await pumpRentTab(tester);
    await tapVisible(tester, find.text('Rent Due').first);
    expect(find.text('Ananya Nair'), findsOneWidget);

    await tapVisible(tester, find.text('UPCOMING').first);
    expect(find.text('Sneha Joseph'), findsOneWidget);
    expect(find.text('Ananya Nair'), findsNothing);

    await tapVisible(tester, find.text('ALL'));
    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('No obligations found'), findsOneWidget);
    await tapVisible(tester, find.text('Reset Filters'));
    expect(find.text('Ananya Nair'), findsOneWidget);
  });

  testWidgets('Rent Due → Rent Details → Receipt and Tenancy; back works', (
    tester,
  ) async {
    await pumpRentTab(tester);
    await tapVisible(tester, find.text('Rent Due').first);

    await scrollTap(tester, find.text('View Details'));
    expect(find.byType(RentDetailsScreen), findsOneWidget);
    expect(find.text('₹13,000.00'), findsOneWidget);

    await scrollTap(tester, find.text('View Receipt'));
    expect(find.byType(ReceiptScreen), findsOneWidget);
    expect(find.text('#REC-2024-102-01'), findsOneWidget);
    await back(tester);

    await scrollTap(tester, find.text('View Tenancy Terms & Agreement'));
    expect(find.byType(TenancyDetailsScreen), findsOneWidget);
    await back(tester);
    await back(tester);
    expect(find.byType(RentDueView).hitTestable(), findsOneWidget);
  });

  testWidgets('Record Payment: form controls, then a labelled preview', (
    tester,
  ) async {
    await pumpRentTab(tester);
    await scrollTap(tester, find.text('Record Payment'));
    expect(find.byType(RecordPaymentScreen), findsOneWidget);

    await scrollTap(tester, find.text('Pay Full Balance (₹11,000)'));
    expect(find.text('11000'), findsOneWidget);
    await scrollTap(tester, find.text('Cash').first);
    expect(find.text('Selected: Cash'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('24 Oct 2024'),
      -300,
      scrollable: _list,
    );
    await tapVisible(tester, find.text('24 Oct 2024'));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    await scrollTap(tester, find.text('Save Payment'));
    expect(find.byType(ReceiptScreen), findsOneWidget);
    expect(find.byType(RecordPaymentScreen), findsNothing);
    expect(
      find.textContaining('has not been saved', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('PREVIEW'), findsOneWidget);

    await scrollTap(tester, find.text('Done · Return to Rent'));
    expect(find.byType(RentTab).hitTestable(), findsOneWidget);
  });

  testWidgets('Record Payment: Cancel returns without a receipt', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.home);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed(AppRoutes.recordPayment, arguments: RentMockData.ananya);
    await settle(tester);
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(RecordPaymentScreen), findsNothing);
    expect(find.byType(ReceiptScreen), findsNothing);
  });

  testWidgets('Partial Payment: presets, method, labelled preview', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(
      tester,
      AppRoutes.rentDetails,
      arguments: RentMockData.meera,
    );
    await scrollTap(tester, find.text('Record Partial Payment'));
    expect(find.byType(PartialPaymentScreen), findsOneWidget);
    expect(find.text('₹8,000.00'), findsWidgets);

    await scrollTap(tester, find.text('₹5,000'));
    expect(find.text('5,000'), findsOneWidget);
    await scrollTap(tester, find.text('Cash').first);

    await scrollTap(tester, find.textContaining('Save Partial Payment'));
    expect(find.byType(ReceiptScreen), findsOneWidget);
    expect(find.text('PREVIEW'), findsOneWidget);
  });

  testWidgets('Payment History: method filter, search empty state, receipt', (
    tester,
  ) async {
    await pumpRentTab(tester);
    await tapVisible(tester, find.text('Payment History').first);

    await tapVisible(tester, find.text('Cash').first);
    expect(find.text('Meera Pillai'), findsOneWidget);
    expect(find.text('1 displayed'), findsOneWidget);

    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.text('No Receipts Found'), findsOneWidget);
    await tapVisible(tester, find.text('Reset Search & Filters'));
    expect(find.text('9 displayed'), findsOneWidget);

    await scrollTap(tester, find.text('View Receipt').first);
    expect(find.byType(ReceiptScreen), findsOneWidget);
    expect(find.text('RECORDED'), findsOneWidget);
    await back(tester);

    await scrollTap(tester, find.text('Rent Details').first);
    expect(find.byType(RentDetailsScreen), findsOneWidget);
  });

  testWidgets('Forms stay usable with the keyboard open', (tester) async {
    useMobileViewport(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);

    for (final (route, args) in <(String, Object)>[
      (AppRoutes.recordPayment, RentMockData.ananya),
      (AppRoutes.partialPayment, RentMockData.meera),
    ]) {
      await pumpRoute(tester, route, arguments: args);
      await tester.showKeyboard(find.byType(TextField).first);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: route);
      expect(find.byType(TextField).first.hitTestable(), findsOneWidget);
    }
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 05 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> scrollAll() async {
        await tester.pump();
        if (_list.evaluate().isNotEmpty) {
          await tester.drag(_list, const Offset(0, -5000));
          await settle(tester);
        }
      }

      // Rent tab sections.
      await pumpRoute(tester, AppRoutes.home);
      await tester.tap(
        find.descendant(
          of: find.byType(ResidoBottomNav),
          matching: find.text('Rent'),
        ),
      );
      await settle(tester);
      await scrollAll();
      expect(tester.takeException(), isNull, reason: 'overview');
      for (final section in ['Rent Due', 'Payment History']) {
        await tester.drag(_list, const Offset(0, 5000));
        await settle(tester);
        await tapVisible(tester, find.text(section).first);
        await scrollAll();
        expect(tester.takeException(), isNull, reason: section);
        await tester.drag(_list, const Offset(0, 5000));
        await settle(tester);
        await tapVisible(tester, find.text('Rent Overview').last);
      }

      for (final (route, args) in <(String, Object)>[
        (AppRoutes.rentDetails, RentMockData.ananya),
        (AppRoutes.rentDetails, RentMockData.meera),
        (AppRoutes.rentDetails, RentMockData.sneha),
        (AppRoutes.rentDetails, RentMockData.thomas),
        (AppRoutes.recordPayment, RentMockData.ananya),
        (AppRoutes.recordPayment, RentMockData.sneha),
        (AppRoutes.partialPayment, RentMockData.meera),
        for (final p in RentMockData.payments)
          (AppRoutes.receipt, ReceiptArgs(payment: p)),
        (
          AppRoutes.receipt,
          const ReceiptArgs(
            payment: RentMockData.partialPreview,
            preview: true,
          ),
        ),
      ]) {
        await pumpRoute(tester, route, arguments: args);
        await scrollAll();
        expect(tester.takeException(), isNull, reason: '$route $args');
      }
    });
  }
}
