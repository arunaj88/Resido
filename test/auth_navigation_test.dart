import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resido/app/resido_app.dart';
import 'package:resido/features/auth/presentation/screens/create_account_screen.dart';
import 'package:resido/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:resido/features/auth/presentation/screens/recovery_feedback_screen.dart';
import 'package:resido/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:resido/features/auth/presentation/screens/welcome_screen.dart';
import 'package:resido/features/dashboard/presentation/widgets/dashboard_view.dart';
import 'package:resido/features/dashboard/presentation/widgets/empty_dashboard_view.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';
import 'package:resido/features/splash/presentation/screens/splash_screen.dart';

import 'test_helpers.dart';

Future<void> launchToWelcome(WidgetTester tester) async {
  useMobileViewport(tester);
  await tester.pumpWidget(const ResidoApp());
  await tester.pump(SplashScreen.displayDuration);
  await settle(tester);
  expect(find.byType(WelcomeScreen), findsOneWidget);
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

Finder button(String label) => find.widgetWithText(InkWell, label);

Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Back'));
  await settle(tester);
}

void main() {
  testWidgets('Welcome opens Create Account and Sign In; back returns', (
    tester,
  ) async {
    await launchToWelcome(tester);

    await tapVisible(tester, button('Create Account'));
    expect(find.byType(CreateAccountScreen), findsOneWidget);
    await goBack(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await tapVisible(tester, button('Sign In'));
    expect(find.byType(SignInScreen), findsOneWidget);
    await goBack(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('Sign In ↔ Create Account links do not stack pages', (
    tester,
  ) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Sign In'));

    await tapVisible(tester, find.text('Create Account'));
    expect(find.byType(CreateAccountScreen), findsOneWidget);

    await tapVisible(tester, find.text('Sign In').last);
    expect(find.byType(SignInScreen), findsOneWidget);

    // Only Welcome sits underneath.
    await goBack(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('Sign In toggles password visibility and opens the dashboard', (
    tester,
  ) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Sign In'));

    EditableText password() => tester.widget<EditableText>(
      find.descendant(
        of: find.widgetWithText(TextField, 'Kochi@2024Estate!'),
        matching: find.byType(EditableText),
      ),
    );
    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(password().obscureText, isFalse);

    await tapVisible(tester, button('Sign In').last);
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(DashboardView), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets(
    'Forgot Password flows to the link-sent state and back to Sign In',
    (tester) async {
      await launchToWelcome(tester);
      await tapVisible(tester, button('Sign In'));

      await tapVisible(tester, find.text('Forgot Password?'));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'owner@keralaestates.in');
      await tester.pump();
      expect(find.text('Verified format'), findsOneWidget);

      await tapVisible(tester, button('Send Reset Link'));
      expect(find.byType(RecoveryFeedbackScreen), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);

      await tapVisible(tester, button('Return to Sign In'));
      expect(find.byType(SignInScreen), findsOneWidget);
      await goBack(tester);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    },
  );

  testWidgets('Forgot Password back links return to Sign In', (tester) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Sign In'));
    await tapVisible(tester, find.text('Forgot Password?'));

    await tapVisible(tester, find.text('Back to Sign In'));
    expect(find.byType(SignInScreen), findsOneWidget);

    await tapVisible(tester, find.text('Forgot Password?'));
    await goBack(tester);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('Create Account opens the verify state; tabs switch states', (
    tester,
  ) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Create Account'));

    await tapVisible(tester, button('Create Account').last);
    expect(find.byType(RecoveryFeedbackScreen), findsOneWidget);
    expect(find.text('Confirm Your Email'), findsOneWidget);

    await tester.tap(find.text('Failed'));
    await settle(tester);
    expect(find.text('Unable to Send Reset Link'), findsOneWidget);

    await tester.tap(find.text('Submitting'));
    await settle(tester);
    expect(find.text('Submitting Request'), findsOneWidget);

    await tester.tap(find.text('Link Sent'));
    await settle(tester);
    expect(find.text('Check your email'), findsOneWidget);

    await tester.tap(find.text('Verify Account'));
    await settle(tester);
    await tapVisible(tester, button('Go to Sign In'));
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('New account: Verify → Sign In lands on the Empty Dashboard', (
    tester,
  ) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Create Account'));
    await tapVisible(tester, button('Create Account').last);
    await tapVisible(tester, button('Go to Sign In'));
    expect(find.byType(SignInScreen), findsOneWidget);

    await tapVisible(tester, button('Sign In').last);
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(EmptyDashboardView), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('Failed state retries back to the form', (tester) async {
    await launchToWelcome(tester);
    await tapVisible(tester, button('Sign In'));
    await tapVisible(tester, find.text('Forgot Password?'));
    await tapVisible(tester, button('Send Reset Link'));

    await tester.tap(find.text('Failed'));
    await settle(tester);
    await tapVisible(tester, button('Retry Again'));
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });

  for (final size in [const Size(320, 640), const Size(390, 844)]) {
    testWidgets('Batch 01 screens lay out without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final screen in <Widget>[
        const SplashScreen(),
        const WelcomeScreen(),
        const CreateAccountScreen(),
        const SignInScreen(),
        const ForgotPasswordScreen(),
        for (final state in RecoveryFeedbackState.values)
          RecoveryFeedbackScreen(initialState: state),
      ]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$screen at $size');
      }
      // Leave the splash timer nothing to fire into.
      await tester.pumpWidget(const SizedBox());
    });
  }
}
