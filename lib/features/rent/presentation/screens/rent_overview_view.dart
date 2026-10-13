import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/rent_tab.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 22. Rent Overview — static October 2024 summary.
class RentOverviewView extends StatelessWidget {
  const RentOverviewView({super.key, required this.onOpenSection});

  final ValueChanged<RentSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final dues = RentMockData.dues;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 24),
      children: [
        const _CycleCard(),
        const SizedBox(height: 12),
        _SectionTabs(onOpenSection: onOpenSection),
        const SizedBox(height: 12),
        const _StatCard(
          caption: 'Expected',
          amount: RentMockData.expected,
          note: RentMockData.expectedNote,
          amountColor: AppColors.onSurface,
          badge: Icon(
            Icons.account_balance_wallet_outlined,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        const _StatCard(
          caption: 'Collected',
          amount: RentMockData.collected,
          note: RentMockData.collectedNote,
          amountColor: AppColors.secondary,
          tint: AppColors.secondaryContainer,
          badge: RentTag(
            RentMockData.collectedPercent,
            background: AppColors.secondaryContainer,
            color: AppColors.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        const _StatCard(
          caption: 'Outstanding',
          amount: RentMockData.outstanding,
          note: RentMockData.outstandingNote,
          amountColor: AppColors.error,
          tint: AppColors.errorContainer,
          badge: RentTag(
            'Action Due',
            background: AppColors.errorContainer,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 12),
        const _CollectionBar(),
        const SizedBox(height: 16),
        _OverdueCard(record: dues.first),
        const SizedBox(height: 16),
        _UpcomingCard(record: dues.last),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: RentCaption('Account Receivables')),
            Text(
              'Kerala Region',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _LinkCard(
          icon: Icons.assignment_late_outlined,
          iconBackground: AppColors.surfaceContainer,
          iconColor: AppColors.primary,
          title: 'Rent Due & Receivables',
          subtitle:
              '2 pending obligations (${RentMockData.outstanding} outstanding)',
          onTap: () => onOpenSection(RentSection.due),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          icon: Icons.history_edu_outlined,
          iconBackground: AppColors.secondaryContainer,
          iconColor: AppColors.onSecondaryContainer,
          title: 'Payment History & Ledger',
          subtitle: '9 payments recorded this month',
          onTap: () => onOpenSection(RentSection.history),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 20,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Recent Payment Activity',
                style: AppTextStyles.headlineSm,
              ),
            ),
            TextButton(
              onPressed: () => onOpenSection(RentSection.history),
              child: Text(
                'View All',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            children: [
              for (final (i, p) in RentMockData.payments.take(3).indexed) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    color: AppColors.surfaceContainerHigh,
                  ),
                _ActivityRow(payment: p),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ManualRecordNote(),
      ],
    );
  }
}

/// "Rent tracking is manually recorded" footnote (Rent Due design copy).
class ManualRecordNote extends StatelessWidget {
  const ManualRecordNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RentCaption('Manual Verification Record'),
                const SizedBox(height: 2),
                Text(
                  'Resido rent tracking is manually recorded by the landlord. '
                  'No automated bank debit occurs.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard();

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
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 22,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RentCaption('Billing Cycle'),
                // Only the October 2024 mock cycle exists.
                PopupMenuButton<String>(
                  tooltip: 'Billing cycle',
                  initialValue: RentMockData.cycle,
                  color: AppColors.surfaceContainerLowest,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: RentMockData.cycle,
                      child: Text(RentMockData.cycle),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          RentMockData.cycle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSm,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.onSurface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StatusDot(color: AppColors.secondaryFixedDim),
                const SizedBox(width: 6),
                Text(
                  'Active Cycle',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.onOpenSection});

  final ValueChanged<RentSection> onOpenSection;

  @override
  Widget build(BuildContext context) {
    Widget pill({
      required String label,
      required IconData icon,
      required bool selected,
      Widget? badge,
      VoidCallback? onTap,
    }) {
      final radius = BorderRadius.circular(999);
      return Material(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLowest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.onPrimary : AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelLg.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.onSurface,
                  ),
                ),
                if (badge != null) ...[const SizedBox(width: 6), badge],
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          pill(
            label: 'Overview',
            icon: Icons.pie_chart_outline,
            selected: true,
          ),
          const SizedBox(width: 8),
          pill(
            label: 'Rent Due',
            icon: Icons.schedule,
            selected: false,
            badge: const RentTag(
              '3',
              background: AppColors.tertiaryFixed,
              color: AppColors.onTertiaryFixedVariant,
            ),
            onTap: () => onOpenSection(RentSection.due),
          ),
          const SizedBox(width: 8),
          pill(
            label: 'Payment History',
            icon: Icons.receipt_long_outlined,
            selected: false,
            onTap: () => onOpenSection(RentSection.history),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.caption,
    required this.amount,
    required this.note,
    required this.amountColor,
    required this.badge,
    this.tint = AppColors.surfaceContainer,
  });

  final String caption;
  final String amount;
  final String note;
  final Color amountColor;
  final Widget badge;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      clip: true,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: RentCaption(caption)),
                    badge,
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: AppTextStyles.headlineLgMobile.copyWith(
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionBar extends StatelessWidget {
  const _CollectionBar();

  @override
  Widget build(BuildContext context) {
    Widget legend(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: legend(
                  AppColors.primaryContainer,
                  'Realized: ${RentMockData.collected}',
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: legend(
                  AppColors.tertiaryFixedDim,
                  'Pending: ${RentMockData.outstanding}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SplitProgressBar(
            fraction: RentMockData.collectedFraction,
            restColor: AppColors.tertiaryFixedDim,
            height: 12,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Collection Rate Target: 95%',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                RentMockData.collectionAchieved,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverdueCard extends StatelessWidget {
  const _OverdueCard({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  size: 18,
                  color: AppColors.onError,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1 Overdue Rent',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      'Grace period ended 20 Oct',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              RentTag(
                record.dueBadge,
                background: AppColors.error,
                color: AppColors.onError,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => AppRoutes.openRentDetails(context, record),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    TenantAvatar(
                      initials: record.initials,
                      size: 36,
                      textStyle: AppTextStyles.labelLg,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.tenantName, style: AppTextStyles.titleLg),
                          Text(
                            '${record.unitLabel} • ${record.property.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          record.remaining,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Due ${record.dueDate.substring(0, 6)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'View Due',
                  leadingIcon: Icons.visibility_outlined,
                  iconSize: 18,
                  height: 44,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  foregroundColor: AppColors.onSurface,
                  textStyle: AppTextStyles.labelLg,
                  onPressed: () => AppRoutes.openRentDetails(context, record),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Record Payment',
                  height: 44,
                  textStyle: AppTextStyles.labelLg,
                  onPressed: () => AppRoutes.openRecordPayment(context, record),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_note_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 Upcoming Due', style: AppTextStyles.headlineSm),
                    Text(
                      'Next cycle payments pipeline',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.remaining,
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Combined',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => AppRoutes.openRentDetails(context, record),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const StatusDot(color: AppColors.tertiaryFixedDim),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${record.tenantName} (${record.unitLabel})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          record.rent,
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Due ${record.dueDate.substring(0, 6)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleLg),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.payment});

  final RentPayment payment;

  @override
  Widget build(BuildContext context) {
    final record = payment.record;
    return InkWell(
      onTap: () => AppRoutes.openReceipt(context, payment),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            TenantAvatar(
              initials: record.initials,
              size: 40,
              background: payment.partial
                  ? AppColors.tertiaryFixed
                  : AppColors.secondaryContainer,
              color: payment.partial
                  ? AppColors.onTertiaryFixedVariant
                  : AppColors.onSecondaryContainer,
              textStyle: AppTextStyles.labelLg,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(record.tenantName, style: AppTextStyles.titleLg),
                      payment.partial
                          ? const RentTag(
                              'PARTIAL',
                              background: AppColors.tertiaryFixed,
                              color: AppColors.onTertiaryFixedVariant,
                            )
                          : const RentTag(
                              'FULL',
                              background: AppColors.secondaryContainer,
                              color: AppColors.onSecondaryContainer,
                            ),
                    ],
                  ),
                  Text(
                    record.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${payment.date} • ${payment.method.label}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${payment.amount}',
                  style: AppTextStyles.titleLg.copyWith(
                    color: payment.partial
                        ? AppColors.onSurface
                        : AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      payment.partial ? Icons.timelapse : Icons.check_circle,
                      size: 13,
                      color: payment.partial
                          ? AppColors.onTertiaryContainer
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      payment.partial
                          ? '${payment.balanceAfter.replaceAll('.00', '')} Bal.'
                          : 'Settled',
                      style: AppTextStyles.labelSm.copyWith(
                        color: payment.partial
                            ? AppColors.onTertiaryContainer
                            : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
