import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';

/// Colours and text of a unit status badge.
class UnitBadgeStyle {
  const UnitBadgeStyle(
    this.label,
    this.background,
    this.foreground, {
    this.dot,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? dot;

  /// Badges on the Property Details unit cards.
  static UnitBadgeStyle forDetails(MockUnit unit) => switch (unit.condition) {
    UnitCondition.settled => const UnitBadgeStyle(
      'OCCUPIED',
      AppColors.secondaryContainer,
      AppColors.onSecondaryContainer,
    ),
    UnitCondition.overdue => UnitBadgeStyle(
      'DUE (${unit.overdueDays}D)',
      AppColors.errorContainer,
      AppColors.onErrorContainer,
    ),
    UnitCondition.ready => const UnitBadgeStyle(
      'VACANT',
      AppColors.surfaceContainer,
      AppColors.onSurfaceVariant,
    ),
    UnitCondition.refreshing => const UnitBadgeStyle(
      'RENOVATING',
      AppColors.tertiaryFixed,
      AppColors.onTertiaryFixed,
    ),
  };

  /// Badges on the Unit List cards (occupied / vacant with a dot).
  static UnitBadgeStyle forList(MockUnit unit) =>
      unit.status == UnitStatus.occupied
      ? const UnitBadgeStyle(
          'OCCUPIED',
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
          dot: AppColors.secondary,
        )
      : const UnitBadgeStyle(
          'VACANT',
          AppColors.tertiaryFixed,
          AppColors.onTertiaryFixed,
          dot: AppColors.onTertiaryContainer,
        );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.style});

  final UnitBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.dot != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: style.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            style.label,
            style: AppTextStyles.labelMd.copyWith(
              color: style.foreground,
              letterSpacing: style.dot != null ? 0.55 : 0.44,
            ),
          ),
        ],
      ),
    );
  }
}

/// 40px tile showing a unit number ("101", "G1", "Annex").
class UnitNumberTile extends StatelessWidget {
  const UnitNumberTile({
    super.key,
    required this.number,
    required this.background,
    required this.color,
    required this.textStyle,
    this.radius = 12,
  });

  final String number;
  final Color background;
  final Color color;
  final TextStyle textStyle;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(number, style: textStyle.copyWith(color: color)),
      ),
    );
  }
}

/// Small icon + text line.
class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.iconColor,
    this.iconSize = 16,
    this.gap = 4,
    this.style,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color? iconColor;
  final double iconSize;
  final double gap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor ?? color),
        SizedBox(width: gap),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (style ?? AppTextStyles.bodySm).copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// "₹24,000/mo" amount used on unit cards.
class MonthlyAmount extends StatelessWidget {
  const MonthlyAmount({super.key, required this.amount, required this.color});

  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: InrFormat.full(amount),
        style: AppTextStyles.titleLg.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: '/mo',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
