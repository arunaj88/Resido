import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_theme.dart';

class ResidoApp extends StatelessWidget {
  const ResidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resido',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Applies the transparent status bar to every route.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemOverlayStyle,
        child: child!,
      ),
    );
  }
}
