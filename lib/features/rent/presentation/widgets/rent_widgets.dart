import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';

/// Colours for a rent status: (tint background, foreground).
(Color, Color) rentStatusColors(RentStatus status) => switch (status) {
  RentStatus.overdue => (AppColors.errorContainer, AppColors.error),
  RentStatus.partiallyPaid => (
    AppColors.tertiaryFixed,
    AppColors.onTertiaryFixedVariant,
  ),
  RentStatus.upcoming => (
    AppColors.surfaceContainerHigh,
    AppColors.onSurfaceVariant,
  ),
  RentStatus.paid => (
    AppColors.secondaryContainer,
    AppColors.onSecondaryContainer,
  ),
};

IconData rentStatusIcon(RentStatus status) => switch (status) {
  RentStatus.overdue => Icons.error,
  RentStatus.partiallyPaid => Icons.pending_outlined,
  RentStatus.upcoming => Icons.event_note_outlined,
  RentStatus.paid => Icons.check_circle,
};

/// Uppercase status pill ("OVERDUE", "PARTIALLY PAID").
class RentStatusChip extends StatelessWidget {
  const RentStatusChip({super.key, required this.status, this.label});

  final RentStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = rentStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(rentStatusIcon(status), size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            (label ?? status.label).toUpperCase(),
            style: AppTextStyles.labelMd.copyWith(
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

/// Small rectangular tag ("FULL", "PARTIAL", "Part Payment").
class RentTag extends StatelessWidget {
  const RentTag(
    this.text, {
    super.key,
    this.background = AppColors.surfaceContainerHigh,
    this.color = AppColors.onSurfaceVariant,
    this.icon,
  });

  final String text;
  final Color background;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// White search box with a clear button, as on the Rent screens.
class RentSearchField extends StatelessWidget {
  const RentSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                controller.clear();
                onChanged();
              },
              icon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// One filter pill with a count badge.
class RentFilterChip extends StatelessWidget {
  const RentFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.badgeColor = AppColors.surfaceContainerHighest,
    this.badgeTextColor = AppColors.onSurface,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLg.copyWith(
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? AppColors.secondary : badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    color: selected ? AppColors.onPrimary : badgeTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uppercase card heading used inside the Rent cards.
class RentCaption extends StatelessWidget {
  const RentCaption(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelMd.copyWith(
        color: color ?? AppColors.onSurfaceVariant,
        letterSpacing: 0.55,
      ),
    );
  }
}

/// Two-part progress bar: settled (green) and outstanding (amber or red).
class SplitProgressBar extends StatelessWidget {
  const SplitProgressBar({
    super.key,
    required this.fraction,
    this.restColor = AppColors.surfaceContainerHighest,
    this.height = 8,
  });

  final double fraction;
  final Color restColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fraction > 0)
              Expanded(
                flex: (fraction * 1000).round(),
                child: const ColoredBox(color: AppColors.secondary),
              ),
            if (fraction < 1)
              Expanded(
                flex: ((1 - fraction) * 1000).round(),
                child: ColoredBox(color: restColor),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selectable payment method tile (icon, label, detail, check).
class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  /// Row layout used by the three-up Partial Payment selector.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final fg = selected ? AppColors.primary : AppColors.onSurface;
    final iconColor = selected
        ? AppColors.secondary
        : AppColors.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? (compact
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainer)
            : AppColors.surfaceContainerLow,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 8 : 14),
            child: compact
                ? Row(
                    children: [
                      Icon(icon, size: 18, color: iconColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMd.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 24, color: iconColor),
                          const Spacer(),
                          if (selected)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.onPrimary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg.copyWith(color: fg),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Tinted, read-only-looking input box with a leading icon; [child] is the
/// field or the tappable value.
class RentInputBox extends StatelessWidget {
  const RentInputBox({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.height = 52,
    this.onTap,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(child: child),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clearly labelled note that a screen shows a static preview only.
class PreviewNotice extends StatelessWidget {
  const PreviewNotice({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.visibility_outlined,
            size: 20,
            color: AppColors.onTertiaryFixedVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Preview only. ',
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onTertiaryFixed,
                    ),
                  ),
                  TextSpan(text: message),
                ],
              ),
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onTertiaryFixedVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
