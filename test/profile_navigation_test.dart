import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';
import 'package:resido/core/widgets/coming_soon_view.dart';
import 'package:resido/features/auth/presentation/screens/welcome_screen.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_view.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/home/presentation/widgets/resido_bottom_nav.dart';
import 'package:resido/features/profile/data/profile_mock_data.dart';
import 'package:resido/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:resido/features/profile/presentation/screens/profile_tab.dart';
import 'package:resido/features/profile/presentation/screens/settings_screen.dart';
import 'package:resido/features/profile/presentation/widgets/profile_widgets.dart';

import 'test_helpers.dart';

/// Pumps [name] above a placeholder first page, so back has somewhere to go.
Future<void> pumpRoute(WidgetTester tester, String name) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: AppTheme.light(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Start')),
        ),
        AppRoutes.onGenerateRoute(RouteSettings(name: name)),
      ],
    ),
  );
  await settle(tester);
}

/// Pumps the signed-in shell and opens the Profile tab from the bottom bar.
Future<void> pumpProfileTab(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
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
      matching: find.text('Profile'),
    ),
  );
  await settle(tester);
  expect(find.byType(ProfileTab).hitTestable(), findsOneWidget);
}

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
  testWidgets('Profile tab shows the landlord and is reachable from avatars', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpProfileTab(tester);
    expect(find.text(ProfileMockData.name), findsOneWidget);
    expect(find.text(ProfileMockData.email), findsOneWidget);
    expect(find.text(ProfileMockData.portfolio), findsOneWidget);

    // Back to Dashboard, then the Dashboard header avatar opens Profile.
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.byType(DashboardView).hitTestable(), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(HomeTopBar),
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == 'Profile',
            ),
          )
          .hitTestable(),
    );
    await settle(tester);
    expect(find.byType(ProfileTab).hitTestable(), findsOneWidget);
  });

  testWidgets('Profile → Edit Profile, Account Settings and Notification '
      'Preferences; back returns', (tester) async {
    useMobileViewport(tester);
    await pumpProfileTab(tester);

    await tapVisible(tester, find.text('Edit Profile'));
    expect(find.byType(EditProfileScreen), findsOneWidget);
    await back(tester);
    expect(find.byType(ProfileTab).hitTestable(), findsOneWidget);

    await scrollTap(tester, find.text('Account Settings'));
    expect(find.byType(SettingsScreen), findsOneWidget);
    await back(tester);

    await scrollTap(tester, find.text('Notification Preferences'));
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tapVisible(tester, find.text('Edit'));
    expect(find.byType(EditProfileScreen), findsOneWidget);
    await back(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    await back(tester);
    expect(find.byType(HomeShell), findsOneWidget);
  });

  testWidgets('Rows without designs open Coming Soon', (tester) async {
    useMobileViewport(tester);
    await pumpProfileTab(tester);
    for (final row in [
      'Change Password',
      'Help & Support',
      'Privacy Policy',
      'About Resido',
    ]) {
      await scrollTap(tester, find.text(row));
      expect(find.byType(ComingSoonScreen), findsOneWidget, reason: row);
      expect(find.text(row), findsWidgets);
      await tester.pageBack();
      await settle(tester);
      expect(find.byType(ProfileTab).hitTestable(), findsOneWidget);
    }

    await pumpRoute(tester, AppRoutes.settings);
    for (final row in [
      'Change Password',
      'Help & Support',
      'Privacy Policy',
      'About Resido',
    ]) {
      await scrollTap(tester, find.text(row));
      expect(find.byType(ComingSoonScreen), findsOneWidget, reason: row);
      await tester.pageBack();
      await settle(tester);
    }
  });

  testWidgets('Sign Out: Stay Signed In closes; confirm returns to Welcome', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpProfileTab(tester);

    await scrollTap(tester, find.text('Sign Out'));
    expect(find.byType(SignOutDialog), findsOneWidget);
    expect(
      find.textContaining('email and password', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Stay Signed In'));
    await settle(tester);
    expect(find.byType(SignOutDialog), findsNothing);
    expect(find.byType(ProfileTab).hitTestable(), findsOneWidget);

    await scrollTap(tester, find.text('Sign Out'));
    await tester.tap(find.text('Yes, Sign Out'));
    await settle(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    // Nothing is left to go back to.
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('Settings Sign Out uses the same dialog', (tester) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.settings);
    await scrollTap(tester, find.text('Sign Out'));
    expect(find.byType(SignOutDialog), findsOneWidget);
    await tester.tap(find.text('Yes, Sign Out'));
    await settle(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Edit Profile: Save shows preview-only feedback; Cancel '
      'returns', (tester) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.editProfile);
    expect(find.text(ProfileMockData.name), findsOneWidget);
    expect(find.text(ProfileMockData.phone), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Hari Menon');
    await tester.pump();
    await scrollTap(tester, find.text('Save Changes'));
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(
      find.text('Preview only — your profile was not changed.'),
      findsOneWidget,
    );

    await pumpRoute(tester, AppRoutes.editProfile);
    await scrollTap(tester, find.text('Cancel'));
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Settings toggles change on screen with preview feedback', (
    tester,
  ) async {
    useMobileViewport(tester);
    await pumpRoute(tester, AppRoutes.settings);

    final digest = find.byType(Switch).at(3);
    await tester.scrollUntilVisible(digest, 200, scrollable: _list);
    expect(tester.widget<Switch>(digest).value, isFalse);
    await tester.tap(digest);
    await tester.pump();
    expect(tester.widget<Switch>(digest).value, isTrue);
    expect(
      find.text('Preview only — this preference was not saved.'),
      findsOneWidget,
    );

    // Not persisted: a fresh Settings screen shows the defaults again.
    await pumpRoute(tester, AppRoutes.settings);
    await tester.scrollUntilVisible(
      find.byType(Switch).at(3),
      200,
      scrollable: _list,
    );
    expect(tester.widget<Switch>(find.byType(Switch).at(3)).value, isFalse);
  });

  testWidgets('Edit Profile stays usable with the keyboard open', (
    tester,
  ) async {
    useMobileViewport(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.resetViewInsets);
    await pumpRoute(tester, AppRoutes.editProfile);
    for (final text in [
      ProfileMockData.name,
      ProfileMockData.phone,
      ProfileMockData.district,
    ]) {
      final field = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == text,
      );
      await tester.scrollUntilVisible(field, 200, scrollable: _list);
      await tester.showKeyboard(field);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: text);
      expect(field.hitTestable(), findsOneWidget, reason: text);
    }
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 07 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpProfileTab(tester);
      await tester.drag(_list, const Offset(0, -4000));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'profile');

      await tester.drag(_list, const Offset(0, 4000));
      await settle(tester);
      await scrollTap(tester, find.text('Sign Out'));
      expect(tester.takeException(), isNull, reason: 'sign out dialog');

      for (final route in [AppRoutes.editProfile, AppRoutes.settings]) {
        await pumpRoute(tester, route);
        await tester.drag(_list, const Offset(0, -4000));
        await settle(tester);
        expect(tester.takeException(), isNull, reason: route);
      }
    });
  }
}
