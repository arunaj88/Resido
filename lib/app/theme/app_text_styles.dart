import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';


/// Resido type scale, mirroring the Stitch Tailwind `fontSize` tokens.
///
/// Headlines and titles use Plus Jakarta Sans; body and labels use Inter.
abstract final class AppTextStyles {
  static const headingFamily = 'PlusJakartaSans';
  static const bodyFamily = 'Inter';

  /// Inter's latin-ext subset; supplies ₹ which the latin subsets lack.
  static const fallbackFamilies = ['InterExt'];

  static TextStyle _jakarta(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFamilies,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        color: AppColors.onSurface,
      );

  static TextStyle _inter(double size, double lineHeight, FontWeight weight) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: fallbackFamilies,
        fontSize: size,
        height: lineHeight / size,
        fontWeight: weight,
        color: AppColors.onSurface,
      );

  /// 32 / 40, bold.
  static final headlineLg = _jakarta(32, 40, FontWeight.w700);

  /// 26 / 34, bold. Used as the main screen heading on mobile.
  static final headlineLgMobile = _jakarta(26, 34, FontWeight.w700)
      .copyWith(letterSpacing: -0.65);

  /// 24 / 32, bold, -0.01em. Rupee amounts on mobile.
  static final currencyDisplayMobile = _jakarta(24, 32, FontWeight.w700)
      .copyWith(letterSpacing: -0.24);

  /// 22 / 28, semibold.
  static final headlineMd = _jakarta(22, 28, FontWeight.w600);

  /// 18 / 24, semibold.
  static final headlineSm = _jakarta(18, 24, FontWeight.w600);

  /// 16 / 22, semibold.
  static final titleLg = _jakarta(16, 22, FontWeight.w600);

  /// 16 / 24, regular.
  static final bodyLg = _inter(16, 24, FontWeight.w400);

  /// 14 / 20, regular.
  static final bodyMd = _inter(14, 20, FontWeight.w400);

  /// 12 / 16, regular.
  static final bodySm = _inter(12, 16, FontWeight.w400);

  /// 13 / 16, semibold.
  static final labelLg = _inter(13, 16, FontWeight.w600);

  /// 11 / 14, semibold, 0.04em tracking.
  static final labelMd =
      _inter(11, 14, FontWeight.w600).copyWith(letterSpacing: 0.44);

  /// 10 / 12, medium.
  static final labelSm = _inter(10, 12, FontWeight.w500);

  /// Tailwind `leading-relaxed` (1.625) for body paragraphs.
  static const relaxed = 1.625;
}
