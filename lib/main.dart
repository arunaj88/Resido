import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/app_scope.dart';
import 'package:resido/app/resido_app.dart';
import 'package:resido/app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayStyle);
  // The screens still use their static mock data; the repositories are
  // available to new code through AppScope.
  runApp(
    AppScope(
      dependencies: AppDependencies.inMemorySeeded(),
      child: const ResidoApp(),
    ),
  );
}
