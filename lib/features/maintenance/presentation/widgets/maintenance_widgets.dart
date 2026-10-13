import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';

/// (background, foreground) for a priority.
(Color, Color) priorityColors(MaintenancePriority p) => switch (p) {
  MaintenancePriority.high => (AppColors.errorContainer, AppColors.error),
  MaintenancePriority.medium => (
    AppColors.tertiaryFixed,
    AppColors.onTertiaryFixedVariant,
  ),
  MaintenancePriority.low => (
    AppColors.surfaceContainerHigh,
    AppColors.onSurfaceVariant,
  ),
};

/// (background, foreground) for a status.
(Color, Color) statusColors(MaintenanceStatus s) => switch (s) {
  MaintenanceStatus.open => (AppColors.surfaceContainerHigh, AppColors.primary),
  MaintenanceStatus.inProgress => (
    AppColors.tertiaryFixed,
    AppColors.onTertiaryFixedVariant,
  ),
  MaintenanceStatus.completed => (
    AppColors.secondaryContainer,
    AppColors.onSecondaryContainer,
  ),
};

/// "HIGH" / "MEDIUM" / "LOW" tag.
class PriorityTag extends StatelessWidget {
  const PriorityTag({super.key, required this.priority, this.long = false});

  final MaintenancePriority priority;

  /// "HIGH PRIORITY" with an icon, as on Request Details.
  final bool long;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = priorityColors(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (long) ...[
            Icon(Icons.warning_amber_rounded, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            long
                ? '${priority.label} Priority'.toUpperCase()
                : priority.label.toUpperCase(),
            style: AppTextStyles.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status pill with a dot (or a check when completed).
class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.status, this.prefix = ''});

  final MaintenanceStatus status;

  /// e.g. "Current: ".
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == MaintenanceStatus.completed)
            Icon(Icons.check_circle_outline, size: 13, color: fg)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: status == MaintenanceStatus.open
                    ? AppColors.error
                    : AppColors.onTertiaryFixedVariant,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            '$prefix${status.label}'.toUpperCase(),
            style: AppTextStyles.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded square icon tile used for categories and section headers.
class MaintenanceIconTile extends StatelessWidget {
  const MaintenanceIconTile({
    super.key,
    required this.icon,
    this.size = 40,
    this.background = AppColors.surfaceContainer,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

/// Static photo slot: no images are stored, so attachments show an icon
/// with their file name.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    required this.label,
    this.icon = Icons.image_outlined,
    this.height = 96,
  });

  final String label;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceContainerHigh, AppColors.outlineVariant],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(icon, size: 32, color: AppColors.onSurfaceVariant),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            right: 6,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
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

/// Small round icon button that is shown but inactive (calls, chat,
/// directions need device services).
class InactiveCircleButton extends StatelessWidget {
  const InactiveCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$tooltip (not available yet)',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: AppShadows.sm,
        ),
        child: Icon(icon, size: 18, color: AppColors.secondary),
      ),
    );
  }
}
