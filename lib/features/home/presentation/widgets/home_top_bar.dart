import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';

/// Frosted header for the top-level tabs: brand tile, "Resido" with the
/// section name, the notifications bell (amber unread dot) and the avatar.
///
/// With [eyebrow] set, the text block becomes a small eyebrow above the
/// section as a title (Stitch "10. Property List").
class HomeTopBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeTopBar({
    super.key,
    required this.section,
    required this.onNotifications,
    required this.onAvatar,
    this.hasUnread = true,
    this.eyebrow,
  });

  final String section;
  final String? eyebrow;
  final VoidCallback onNotifications;
  final VoidCallback onAvatar;
  final bool hasUnread;

  static const barHeight = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x0A064E3B),
            offset: Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: ColoredBox(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppShadows.sm,
                        ),
                        child: const Icon(
                          Icons.apartment,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: eyebrow != null
                            ? _EyebrowTitle(eyebrow: eyebrow!, title: section)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Resido',
                                    style: AppTextStyles.titleLg.copyWith(
                                      color: AppColors.primaryContainer,
                                      height: 1,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    section.toUpperCase(),
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.outline,
                                      height: 1,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      _BellButton(
                        hasUnread: hasUnread,
                        onPressed: onNotifications,
                      ),
                      const SizedBox(width: 4),
                      Semantics(
                        button: true,
                        label: 'Profile',
                        child: GestureDetector(
                          onTap: onAvatar,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
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

class _EyebrowTitle extends StatelessWidget {
  const _EyebrowTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineSm.copyWith(
            height: 1.25,
            letterSpacing: -0.45,
          ),
        ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasUnread, required this.onPressed});

  final bool hasUnread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Positioned.fill(
            child: IconButton(
              tooltip: 'Notifications',
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              icon: const Icon(
                Icons.notifications_outlined,
                size: 22,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 10,
              right: 10,
              child: IgnorePointer(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.onTertiaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surfaceContainerLowest,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
