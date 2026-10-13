import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';



abstract final class AppTheme {
  /// Transparent status bar with dark icons, so every screen's own
  /// background shows behind it.
  static const systemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Android
    statusBarBrightness: Brightness.light, // iOS
  );

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepEmerald,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      tertiary: AppColors.warmAmber,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(systemOverlayStyle: systemOverlayStyle),
      fontFamily: AppTextStyles.bodyFamily,
      fontFamilyFallback: AppTextStyles.fallbackFamilies,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryContainer,
      ),
    );
  }
}
