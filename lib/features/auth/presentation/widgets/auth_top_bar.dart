import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/resido_logo.dart';


/// Frosted 64px header shared by the auth screens: back button, Resido
/// wordmark, an optional title and a screen-specific trailing widget.
class AuthTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthTopBar({
    super.key,
    this.title,
    this.titleStyle,
    this.trailing,
    this.logoSize = 28,
    this.backIconSize = 22,
    this.onBack,
  });

  final String? title;
  final TextStyle? titleStyle;
  final Widget? trailing;
  final double logoSize;
  final double backIconSize;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;

  static const barHeight = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 8),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: ColoredBox(
            color: AppColors.surface.withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 24),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: 'Back',
                          padding: EdgeInsets.zero,
                          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                          icon: Icon(
                            Icons.arrow_back,
                            size: backIconSize,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ResidoLogo(size: logoSize),
                      const SizedBox(width: 8),
                      Text(
                        'Resido',
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Expanded(
                        child: title == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  title!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: titleStyle ?? AppTextStyles.headlineSm,
                                ),
                              ),
                      ),
                      ?trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 32px tinted circle with an icon used as the header's trailing badge.
class AuthHeaderBadge extends StatelessWidget {
  const AuthHeaderBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
