import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/resido_app.dart';
import 'package:resido/app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayStyle);
  runApp(const ResidoApp());
}
