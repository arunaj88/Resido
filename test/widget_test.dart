import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resido/app/resido_app.dart';
import 'package:resido/features/auth/presentation/screens/welcome_screen.dart';
import 'package:resido/features/splash/presentation/screens/splash_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('App launches on the splash screen, then shows Welcome', (
    tester,
  ) async {
    useMobileViewport(tester);
    await tester.pumpWidget(const ResidoApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Resido'), findsOneWidget);
    expect(find.text('KERALA ESTATE & TENANCY SUITE'), findsOneWidget);

    await tester.pump(SplashScreen.displayDuration);
    await settle(tester);

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(
      find.text('Effortless property management for Indian landlords.'),
      findsOneWidget,
    );

    // Splash was replaced, so Welcome is the root route.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}
