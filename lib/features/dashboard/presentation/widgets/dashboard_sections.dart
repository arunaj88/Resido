import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/features/dashboard/data/dashboard_mock_data.dart';

/// Section title with an optional trailing link or label.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.badge,
    this.trailing,
  });

  final String title;
  final Widget? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleLg),
        if (badge != null) ...[const SizedBox(width: 8), badge!],
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

/// Small text link used in section headers (e.g. "View All").
class SectionLink extends StatelessWidget {
  const SectionLink(this.label, {super.key, this.onTap, this.style});

  final String label;
  final VoidCallback? onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style:
          style ?? AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
    );
    if (onTap == null) return text;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: text,
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.onAddProperty,
    required this.onAddTenant,
    required this.onRecordRent,
  });

  final VoidCallback onAddProperty;
  final VoidCallback onAddTenant;
  final VoidCallback onRecordRent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Shortcuts" is a label in the design with no destination.
        const DashboardSectionHeader(
          title: 'Quick Actions',
          trailing: SectionLink('Shortcuts'),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_home_work_outlined,
                  label: 'Add Property',
                  onTap: onAddProperty,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.person_add_outlined,
                  label: 'Add Tenant',
                  onTap: onAddTenant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.payments_outlined,
                  label: 'Record Rent',
                  background: AppColors.tertiaryFixed,
                  color: AppColors.tertiary,
                  onTap: onRecordRent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.background = AppColors.secondaryFixed,
    this.color = AppColors.primaryContainer,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLg.copyWith(height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingActionsSection extends StatelessWidget {
  const PendingActionsSection({super.key, required this.onAssignPlumber});

  final VoidCallback onAssignPlumber;

  @override
  Widget build(BuildContext context) {
    final actions = DashboardMockData.pendingActions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Pending Actions',
          badge: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.tertiaryFixed,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${actions.length}',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onTertiaryFixed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Bulk completion is business logic; shown per design, no action.
          trailing: SectionLink(
            'Mark All Done',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, action) in actions.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          _PendingActionCard(action: action, onAssignPlumber: onAssignPlumber),
        ],
      ],
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  const _PendingActionCard({
    required this.action,
    required this.onAssignPlumber,
  });

  final PendingAction action;
  final VoidCallback onAssignPlumber;

  @override
  Widget build(BuildContext context) {
    final (iconBg, iconFg, icon, badgeBg, badgeFg) = switch (action.kind) {
      PendingActionKind.overdueRent => (
        AppColors.errorContainer,
        AppColors.error,
        Icons.warning_amber,
        AppColors.errorContainer,
        AppColors.onErrorContainer,
      ),
      PendingActionKind.dueSoonRent => (
        AppColors.tertiaryFixed,
        AppColors.onTertiaryFixed,
        Icons.calendar_today_outlined,
        AppColors.tertiaryFixed,
        AppColors.onTertiaryFixedVariant,
      ),
      PendingActionKind.maintenance => (
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
        Icons.plumbing,
        AppColors.errorContainer,
        AppColors.onErrorContainer,
      ),
    };

    // Call / WhatsApp / reminder actions need external services, so they
    // are shown per design without an effect in this UI-only phase.
    final buttons = switch (action.kind) {
      PendingActionKind.overdueRent => [
        const _ChipButton(
          icon: Icons.phone_outlined,
          label: 'Call',
          background: AppColors.surfaceContainer,
          foreground: AppColors.primaryContainer,
        ),
        const _ChipButton(
          icon: Icons.send_outlined,
          label: 'WhatsApp Notice',
          background: AppColors.primaryContainer,
          foreground: AppColors.onPrimary,
        ),
      ],
      PendingActionKind.dueSoonRent => [
        const _ChipButton(
          icon: Icons.notifications_active_outlined,
          label: 'Send Reminder',
          background: AppColors.secondaryFixed,
          foreground: AppColors.onSecondaryFixed,
        ),
      ],
      PendingActionKind.maintenance => [
        _ChipButton(
          icon: Icons.engineering_outlined,
          label: 'Assign Plumber',
          background: AppColors.primaryContainer,
          foreground: AppColors.onPrimary,
          onTap: onAssignPlumber,
        ),
      ],
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLg,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.subtitle,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  action.badge,
                  style: AppTextStyles.labelSm.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  action.footnote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
              for (final (i, button) in buttons.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                button,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpotlightSection extends StatelessWidget {
  const SpotlightSection({super.key, required this.onViewLedger});

  final VoidCallback onViewLedger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Spotlight Estate',
          trailing: Text(
            DashboardMockData.spotlightLocality,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          onTap: onViewLedger,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 144,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      DashboardMockData.spotlightImage,
                      fit: BoxFit.cover,
                      semanticLabel: 'Palm Grove Enclave apartments',
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primary.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DashboardMockData.spotlightName,
                            style: AppTextStyles.titleLg.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            DashboardMockData.spotlightUnit,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primaryFixedDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DashboardMockData.spotlightStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMd,
                      ),
                    ),
                    Text(
                      'View Ledger →',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final items = DashboardMockData.recentActivity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardSectionHeader(
          title: 'Recent Activity',
          trailing: SectionLink('View All', onTap: onViewAll),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final (i, item) in items.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                _ActivityRow(item: item),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final rent = item.kind == ActivityKind.rentReceived;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: rent
                  ? AppColors.secondaryFixed
                  : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              rent ? Icons.currency_rupee : Icons.description_outlined,
              size: 18,
              color: rent ? AppColors.primaryContainer : AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLg,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.tag,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    Text(
                      item.note,
                      style: AppTextStyles.labelSm.copyWith(
                        color: rent
                            ? AppColors.secondary
                            : AppColors.primaryContainer,
                        fontWeight: rent ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MonsoonTipCard extends StatelessWidget {
  const MonsoonTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.water_drop_outlined,
            size: 24,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DashboardMockData.tipTitle,
                  style: AppTextStyles.labelLg.copyWith(height: 1.25),
                ),
                Text(
                  DashboardMockData.tipBody,
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
