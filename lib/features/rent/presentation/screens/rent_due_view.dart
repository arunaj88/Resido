import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/rent_overview_view.dart';
import 'package:resido/features/rent/presentation/screens/rent_tab.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

enum _DueFilter {
  all('All'),
  overdue('Overdue'),
  partial('Partially Paid'),
  upcoming('Upcoming');

  const _DueFilter(this.label);

  final String label;

  bool matches(RentRecord r) => switch (this) {
    all => true,
    overdue => r.status == RentStatus.overdue,
    partial => r.status == RentStatus.partiallyPaid,
    upcoming => r.status == RentStatus.upcoming,
  };
}

/// 23. Rent Due — open obligations with search and filters.
class RentDueView extends StatefulWidget {
  const RentDueView({super.key, required this.onOpenSection});

  final ValueChanged<RentSection> onOpenSection;

  @override
  State<RentDueView> createState() => _RentDueViewState();
}

class _RentDueViewState extends State<RentDueView> {
  final _search = TextEditingController();
  _DueFilter _filter = _DueFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(RentRecord r) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      r.tenantName,
      r.property.name,
      r.unitLabel,
    ].any((s) => s.toLowerCase().contains(q));
  }

  void _reset() => setState(() {
    _search.clear();
    _filter = _DueFilter.all;
  });

  @override
  Widget build(BuildContext context) {
    final dues = RentMockData.dues;
    final visible = dues
        .where((r) => _filter.matches(r) && _matchesQuery(r))
        .toList();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 24),
      children: [
        Row(
          children: [
            BackToOverviewButton(
              onPressed: () => widget.onOpenSection(RentSection.overview),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${RentMockData.outstanding} Pending',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _CycleSummary(),
        const SizedBox(height: 12),
        RentSearchField(
          controller: _search,
          hintText: 'Search by tenant, property, or unit #...',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final (i, f) in _DueFilter.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                RentFilterChip(
                  label: f.label.toUpperCase(),
                  count: dues.where(f.matches).length,
                  selected: f == _filter,
                  badgeColor: switch (f) {
                    _DueFilter.overdue => AppColors.error,
                    _DueFilter.partial => AppColors.tertiaryFixed,
                    _ => AppColors.surfaceContainerHighest,
                  },
                  badgeTextColor: switch (f) {
                    _DueFilter.overdue => AppColors.onError,
                    _DueFilter.partial => AppColors.onTertiaryFixedVariant,
                    _ => AppColors.onSurface,
                  },
                  onTap: () => setState(() => _filter = f),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          _NoObligations(onReset: _reset)
        else
          for (final (i, r) in visible.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            _DueCard(record: r),
          ],
        const SizedBox(height: 16),
        const ManualRecordNote(),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => widget.onOpenSection(RentSection.history),
          style: TextButton.styleFrom(alignment: Alignment.centerLeft),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Looking for settled rent? Check Payment History',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CycleSummary extends StatelessWidget {
  const _CycleSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 22,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RentCaption('Cycle Collection'),
                Text('3 Active Obligations', style: AppTextStyles.titleLg),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cleared so far',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '₹17,000.00',
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final (tint, fg) = rentStatusColors(status);
    final overdue = status == RentStatus.overdue;
    final upcoming = status == RentStatus.upcoming;
    final stripe = switch (status) {
      RentStatus.overdue => AppColors.error,
      RentStatus.partiallyPaid => AppColors.tertiaryFixedDim,
      _ => AppColors.secondaryFixedDim,
    };
    final remainingColor = switch (status) {
      RentStatus.overdue => AppColors.error,
      RentStatus.partiallyPaid => AppColors.onTertiaryFixedVariant,
      _ => AppColors.onSurface,
    };
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );

    Widget amount(
      String label,
      String value,
      Color color, {
      bool end = false,
    }) => Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: muted.copyWith(
            color: end ? remainingColor : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: (end ? AppTextStyles.headlineMd : AppTextStyles.titleLg)
              .copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: stripe),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TenantAvatar(
                      initials: record.initials,
                      size: 44,
                      background: tint,
                      color: fg,
                      textStyle: AppTextStyles.titleLg,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.tenantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineSm,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.home_work_outlined,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  record.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    RentStatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: overdue
                        ? AppColors.errorContainer.withValues(alpha: 0.5)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        overdue ? Icons.schedule : Icons.event_outlined,
                        size: 16,
                        color: overdue ? AppColors.error : AppColors.onSurface,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Due: ${record.dueDate}',
                          style: AppTextStyles.labelLg.copyWith(
                            color: overdue
                                ? AppColors.error
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.dueBadge,
                          style: AppTextStyles.labelSm.copyWith(
                            color: overdue
                                ? AppColors.error
                                : upcoming
                                ? AppColors.onSurfaceVariant
                                : AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Rent Period', style: muted)),
                          Text(record.period, style: AppTextStyles.labelLg),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: amount(
                              'Original',
                              record.rent,
                              AppColors.onSurface,
                            ),
                          ),
                          Expanded(
                            child: amount(
                              'Paid',
                              upcoming ? '₹0.00' : record.paid,
                              AppColors.secondary,
                            ),
                          ),
                          amount(
                            'Remaining',
                            record.remaining,
                            remainingColor,
                            end: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SplitProgressBar(fraction: record.paidFraction),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (overdue)
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Record Payment',
                          height: 48,
                          textStyle: AppTextStyles.labelLg,
                          onPressed: () =>
                              AppRoutes.openRecordPayment(context, record),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton(
                          label: 'View Details',
                          trailingIcon: Icons.arrow_forward,
                          iconSize: 18,
                          height: 48,
                          backgroundColor: AppColors.surfaceContainer,
                          foregroundColor: AppColors.onSurface,
                          textStyle: AppTextStyles.labelLg,
                          shadows: const [],
                          onPressed: () =>
                              AppRoutes.openRentDetails(context, record),
                        ),
                      ),
                    ],
                  )
                else
                  AppButton(
                    label: 'View Rent Details',
                    trailingIcon: Icons.arrow_forward,
                    iconSize: 18,
                    height: 48,
                    backgroundColor: AppColors.surfaceContainer,
                    foregroundColor: AppColors.onSurface,
                    textStyle: AppTextStyles.labelLg,
                    shadows: const [],
                    onPressed: () => AppRoutes.openRentDetails(context, record),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoObligations extends StatelessWidget {
  const _NoObligations({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 28,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text('No obligations found', style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(
            'No active dues match your search criteria. Try modifying your '
            'filter or clear the query.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Reset Filters',
            height: 44,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
