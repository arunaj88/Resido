import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/features/dashboard/data/dashboard_mock_data.dart';

/// 2×2 portfolio snapshot: estates, capacity, occupancy, turnover.
class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(
          const _MetricCard(
            metric: DashboardMockData.estates,
            marker: _IconTile(
              icon: Icons.apartment,
              background: AppColors.surfaceContainerLow,
              color: AppColors.primaryContainer,
            ),
          ),
          const _MetricCard(
            metric: DashboardMockData.capacity,
            marker: _IconTile(
              icon: Icons.meeting_room_outlined,
              background: AppColors.secondaryFixed,
              color: AppColors.onSecondaryFixedVariant,
            ),
            suffixStyle: _SuffixStyle.units,
            captionColor: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        _row(
          const _MetricCard(
            metric: DashboardMockData.occupancy,
            marker: _Dot(AppColors.secondary),
            suffixStyle: _SuffixStyle.status,
            accent: AppColors.secondary,
          ),
          const _MetricCard(
            metric: DashboardMockData.turnover,
            marker: _Dot(AppColors.onTertiaryContainer),
            suffixStyle: _SuffixStyle.status,
            accent: AppColors.onTertiaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _row(Widget a, Widget b) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    ),
  );
}

enum _SuffixStyle { units, status }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.marker,
    this.suffixStyle,
    this.accent = AppColors.secondary,
    this.captionColor,
  });

  final DashboardMetric metric;
  final Widget marker;
  final _SuffixStyle? suffixStyle;
  final Color accent;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final value = AppTextStyles.headlineMd.copyWith(
      fontWeight: FontWeight.w700,
    );
    final suffix = switch (suffixStyle) {
      _SuffixStyle.units => AppTextStyles.labelLg.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.outline,
      ),
      _SuffixStyle.status => AppTextStyles.labelSm.copyWith(
        fontWeight: FontWeight.w600,
        color: accent,
      ),
      null => null,
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label.toUpperCase(),
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
              marker,
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(metric.value, style: value),
                  if (metric.valueSuffix != null) ...[
                    const SizedBox(width: 4),
                    Text(metric.valueSuffix!, style: suffix),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                metric.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm.copyWith(
                  color: captionColor ?? AppColors.outline,
                  fontWeight: captionColor == null ? null : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// "October Rent Collection" summary with received/pending tiles and the
/// two-segment progress bar.
class RentCollectionCard extends StatelessWidget {
  const RentCollectionCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const d = DashboardMockData.rentCollectedPercent;
    final footer = AppTextStyles.labelSm.copyWith(color: AppColors.outline);
    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DashboardMockData.rentMonth} Rent Collection',
                      style: AppTextStyles.titleLg,
                    ),
                    Text(
                      DashboardMockData.rentCycleNote,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$d% Collected',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _AmountTile(
                    background: AppColors.surfaceContainerLow,
                    icon: Icons.check_circle_outline,
                    label: 'Received',
                    labelColor: AppColors.secondary,
                    amount: InrFormat.full(DashboardMockData.rentReceived),
                    amountColor: AppColors.primaryContainer,
                    note:
                        'Target: ${InrFormat.full(DashboardMockData.rentTarget)}',
                    noteColor: AppColors.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountTile(
                    background: AppColors.tertiaryFixed.withValues(alpha: 0.3),
                    icon: Icons.schedule,
                    label: 'Pending',
                    labelColor: AppColors.onTertiaryFixedVariant,
                    amount: InrFormat.full(DashboardMockData.rentPending),
                    amountColor: AppColors.onTertiaryFixed,
                    note:
                        '${DashboardMockData.rentOutstandingUnits} Outstanding units',
                    noteColor: AppColors.onTertiaryFixedVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: d,
                    child: const ColoredBox(color: AppColors.primaryContainer),
                  ),
                  Expanded(
                    flex: 100 - d,
                    child: const ColoredBox(
                      color: AppColors.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${InrFormat.compact(DashboardMockData.rentReceived)} collected',
                style: footer,
              ),
              Text(
                '${InrFormat.compact(DashboardMockData.rentPending)} pending',
                style: footer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.background,
    required this.icon,
    required this.label,
    required this.labelColor,
    required this.amount,
    required this.amountColor,
    required this.note,
    required this.noteColor,
  });

  final Color background;
  final IconData icon;
  final String label;
  final Color labelColor;
  final String amount;
  final Color amountColor;
  final String note;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelMd.copyWith(color: labelColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: AppTextStyles.currencyDisplayMobile.copyWith(
                color: amountColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm.copyWith(color: noteColor),
          ),
        ],
      ),
    );
  }
}
