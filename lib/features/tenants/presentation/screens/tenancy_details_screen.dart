import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// Arguments for [AppRoutes.tenancyDetails].
class TenancyDetailsArgs {
  const TenancyDetailsArgs({
    required this.tenant,
    required this.tenancy,
    this.preview = false,
  });

  final MockTenant tenant;
  final MockTenancy tenancy;

  /// True when shown straight after Assign Tenant: nothing was saved.
  final bool preview;
}

/// 21. Tenancy Details. Read-only presentation of a mock tenancy; End
/// Tenancy only shows a confirmation with preview feedback.
class TenancyDetailsScreen extends StatelessWidget {
  const TenancyDetailsScreen({super.key, required this.args});

  final TenancyDetailsArgs args;

  Future<void> _confirmEnd(BuildContext context) async {
    final tenancy = args.tenancy;
    final end = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99293040),
      builder: (_) => _EndTenancyDialog(tenant: args.tenant, tenancy: tenancy),
    );
    if (end == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preview only — the tenancy was not changed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenancy = args.tenancy;
    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Tenancy Details',
        showEdit: true,
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          if (args.preview) ...[
            const _PreviewNotice(),
            const SizedBox(height: 16),
          ],
          _HeaderCard(args: args),
          const SizedBox(height: 16),
          _FinancialCard(tenancy: tenancy, preview: args.preview),
          const SizedBox(height: 16),
          _LeaseCard(tenancy: tenancy),
          if (tenancy.utilities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _UtilitiesCard(utilities: tenancy.utilities),
          ],
          // Ending a tenancy only applies to a saved tenancy, not a preview.
          if (!args.preview) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.tertiaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Marks the unit as vacating. Tenant contact details are '
                          'retained.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'End Tenancy',
                    leadingIcon: Icons.door_front_door_outlined,
                    height: 44,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    foregroundColor: AppColors.error,
                    textStyle: AppTextStyles.labelLg,
                    onPressed: () => _confirmEnd(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryFixed.withValues(alpha: 0.6),
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
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onTertiaryFixed,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'This tenancy has not been saved — it shows how the '
                        'assignment would look.',
                  ),
                ],
              ),
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onTertiaryFixedVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.args});

  final TenancyDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final tenancy = args.tenancy;
    final tenant = args.tenant;
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
          Container(
            height: 6,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.primaryFixed,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AGREEMENT REF',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.55,
                            ),
                          ),
                          Text(
                            tenancy.reference,
                            style: AppTextStyles.titleLg.copyWith(
                              color: AppColors.primary,
                              letterSpacing: -0.4,
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
                        color: args.preview
                            ? AppColors.tertiaryFixed
                            : AppColors.secondaryFixed.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusDot(
                            color: args.preview
                                ? AppColors.onTertiaryContainer
                                : AppColors.secondary,
                            size: 6,
                            pulsing: !args.preview,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            args.preview ? 'PREVIEW' : 'ACTIVE TENANCY',
                            style: AppTextStyles.labelMd.copyWith(
                              color: args.preview
                                  ? AppColors.onTertiaryFixed
                                  : AppColors.onSecondaryFixedVariant,
                              letterSpacing: 0.275,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      TenantAvatar(
                        initials: tenant.initials,
                        size: 44,
                        background: AppColors.primary,
                        color: AppColors.onPrimary,
                        textStyle: AppTextStyles.titleLg,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Primary Tenant',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              tenant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleLg,
                            ),
                            Text(
                              tenant.displayPhone,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.sm,
                          ),
                          child: Material(
                            color: AppColors.surfaceContainerLowest,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'View tenant profile',
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  AppRoutes.openTenantDetails(context, tenant),
                              icon: const Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.apartment,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Property & Unit',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${tenancy.property.name} · ${tenancy.unitLabel}',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            tenancy.property.addressLine,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyles.titleLg)),
              ?trailing,
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({required this.tenancy, required this.preview});

  final MockTenancy tenancy;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    Widget tile(String label, int amount, Color color, Widget footer) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    InrFormat.full(amount),
                    style: AppTextStyles.currencyDisplayMobile.copyWith(
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                footer,
              ],
            ),
          ),
        );

    return _SectionCard(
      icon: Icons.payments_outlined,
      title: 'Financial Terms',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          preview ? 'MONTHLY' : 'MONTHLY ACTIVE',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tile(
                'Monthly Rent',
                tenancy.rent,
                AppColors.primary,
                Row(
                  children: [
                    const Icon(
                      Icons.event_repeat,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Due ${tenancy.dueDay}',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              tile(
                'Security Deposit',
                tenancy.deposit,
                AppColors.onSurface,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Refundable Advance Deposit',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (tenancy.maintenanceNote != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.handyman_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Association Maintenance',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                tenancy.maintenanceNote!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LeaseCard extends StatelessWidget {
  const _LeaseCard({required this.tenancy});

  final MockTenancy tenancy;

  @override
  Widget build(BuildContext context) {
    final progress = tenancy.totalMonths == 0
        ? 0.0
        : tenancy.elapsedMonths / tenancy.totalMonths;
    Widget fact(IconData icon, Color color, String label, String value) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        value,
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    final small = AppTextStyles.labelSm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return _SectionCard(
      icon: Icons.calendar_month_outlined,
      title: 'Lease Period & Tenor',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.secondaryFixed.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          tenancy.termLabel,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSecondaryFixedVariant,
          ),
        ),
      ),
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${tenancy.elapsedMonths} Months Elapsed',
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              tenancy.endDate.isEmpty
                  ? 'Open-ended'
                  : '${tenancy.remainingMonths} Months Remaining',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.surfaceContainer),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0, 1),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: Text('Start: ${tenancy.startDate}', style: small)),
            Text(
              tenancy.endDate.isEmpty
                  ? 'Expiry: Not set'
                  : 'Expiry: ${tenancy.endDate}',
              style: small,
            ),
          ],
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fact(
                Icons.history_toggle_off,
                AppColors.tertiaryContainer,
                'Notice Period',
                tenancy.noticePeriod,
              ),
              const SizedBox(width: 8),
              fact(
                Icons.description_outlined,
                AppColors.primary,
                'Agreement',
                tenancy.agreementLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UtilitiesCard extends StatelessWidget {
  const _UtilitiesCard({required this.utilities});

  final List<TenancyUtility> utilities;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.tune,
      title: 'Utilities & Provisions',
      children: [
        for (final u in utilities) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Icon(
                    switch (u.kind) {
                      UtilityKind.electricity => Icons.bolt,
                      UtilityKind.parking => Icons.directions_car_outlined,
                      UtilityKind.water => Icons.water_drop_outlined,
                    },
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.title,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        u.detail,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: u.highlightTag
                        ? AppColors.secondaryFixed.withValues(alpha: 0.5)
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: u.highlightTag ? null : AppShadows.sm,
                  ),
                  child: Text(
                    u.tag,
                    style: AppTextStyles.labelSm.copyWith(
                      color: u.highlightTag
                          ? AppColors.onSecondaryFixedVariant
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _EndTenancyDialog extends StatelessWidget {
  const _EndTenancyDialog({required this.tenant, required this.tenancy});

  final MockTenant tenant;
  final MockTenancy tenancy;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber,
                  size: 28,
                  color: AppColors.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'End Tenancy for ${tenancy.unit.name}?',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This marks ${tenancy.property.name} ${tenancy.unit.name} as '
              'vacating. ${tenant.name}’s contact details are kept in your '
              'directory.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 18,
                    color: AppColors.tertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notice period: ${tenancy.noticePeriod.toLowerCase()}.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'End Tenancy',
              height: 44,
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              textStyle: AppTextStyles.labelLg,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Keep Tenancy Active',
              height: 44,
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.onSurface,
              textStyle: AppTextStyles.labelLg,
              shadows: const [],
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
