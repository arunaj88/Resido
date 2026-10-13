import 'package:flutter/material.dart';

/// Resido light theme colour tokens.
///
/// Values come from the Stitch project "Resido Mobile Design System"
/// (Tailwind config shared by every screen), plus the Resido brand palette.
abstract final class AppColors {
  // Brand palette.
  static const deepEmerald = Color(0xFF064E3B);
  static const secondaryEmerald = Color(0xFF047857);
  static const sageGray = Color(0xFF9CA3AF);
  static const softCharcoal = Color(0xFF1F2937);
  static const warmAmber = Color(0xFFF59E0B);
  static const white = Color(0xFFFFFFFF);

  // Stitch surface tokens.
  static const surface = Color(0xFFF9F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF1F3FF);
  static const surfaceContainer = Color(0xFFE9EDFF);
  static const surfaceContainerHigh = Color(0xFFE1E8FD);
  static const surfaceContainerHighest = Color(0xFFDCE2F7);
  static const onSurface = Color(0xFF141B2B);
  static const onSurfaceVariant = Color(0xFF404944);
  static const outline = Color(0xFF707974);
  static const outlineVariant = Color(0xFFBFC9C3);

  // Stitch accent tokens.
  static const primary = Color(0xFF003527);
  static const primaryContainer = deepEmerald;
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF80BEA6);
  static const secondary = Color(0xFF006C4E);
  static const secondaryContainer = Color(0xFF97F5CC);
  static const onSecondaryContainer = Color(0xFF007353);
  static const secondaryFixed = Color(0xFF97F5CC);
  static const secondaryFixedDim = Color(0xFF7BD8B1);
  static const onSecondaryFixed = Color(0xFF002115);
  static const onSecondaryFixedVariant = Color(0xFF00513A);
  static const primaryFixed = Color(0xFFB0F0D6);
  static const primaryFixedDim = Color(0xFF95D3BA);
  static const tertiary = Color(0xFF442800);
  static const tertiaryContainer = Color(0xFF623C00);
  static const onTertiaryContainer = Color(0xFFF69F0D);
  static const tertiaryFixed = Color(0xFFFFDDB8);
  static const tertiaryFixedDim = Color(0xFFFFB95F);
  static const onTertiaryFixed = Color(0xFF2A1700);
  static const onTertiaryFixedVariant = Color(0xFF653E00);
  static const surfaceVariant = Color(0xFFDCE2F7);
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

/// Tailwind shadow presets used by the Stitch designs.
abstract final class AppShadows {
  static const sm = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];
  static const md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];
  static const lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];
}
