import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';

/// Frosted 64px header for pushed sub-pages: back button, title, an
/// optional "more" button and the profile avatar.
class SubPageTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SubPageTopBar({
    super.key,
    required this.title,
    this.titleStyle,
    this.showMore = false,
    this.onMore,
    this.showEdit = false,
    this.onEdit,
    this.showAvatar = true,
  });

  final String title;
  final TextStyle? titleStyle;

  /// Shows the design's "more options" button. Without [onMore] it is
  /// display-only (no menu is designed yet).
  final bool showMore;
  final VoidCallback? onMore;

  /// Shows the design's "edit" icon button (display-only without [onEdit]).
  final bool showEdit;
  final VoidCallback? onEdit;

  /// The tenant screens' header has no avatar.
  final bool showAvatar;

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
            color: AppColors.surface.withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: 'Back',
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              titleStyle ??
                              AppTextStyles.headlineSm.copyWith(
                                letterSpacing: -0.45,
                              ),
                        ),
                      ),
                      if (showEdit)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'Edit',
                            padding: EdgeInsets.zero,
                            onPressed: onEdit ?? () {},
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 22,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (showMore)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'More options',
                            padding: EdgeInsets.zero,
                            onPressed: onMore ?? () {},
                            icon: const Icon(
                              Icons.more_vert,
                              size: 22,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (showAvatar) ...[
                        const SizedBox(width: 4),
                        Container(
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
                      ],
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
