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

/// 18. Tenant Details. Shows the current tenancy for assigned tenants and
/// the "Assign to Unit" state otherwise (driven by the mock tenant, not a
/// toggle).
class TenantDetailsScreen extends StatelessWidget {
  const TenantDetailsScreen({super.key, required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    void edit() => AppRoutes.openEditTenant(context, tenant);

    return Scaffold(
      appBar: SubPageTopBar(
        title: 'Tenant Details',
        showEdit: true,
        onEdit: edit,
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          12,
          12,
          12,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _ProfileCard(tenant: tenant, onEdit: edit),
          const SizedBox(height: 16),
          _ContactCard(tenant: tenant),
          const SizedBox(height: 16),
          if (tenant.tenancy != null)
            _CurrentTenancy(tenant: tenant)
          else
            _AssignPrompt(tenant: tenant),
          const SizedBox(height: 16),
          // Archiving changes records, so it is display-only here.
          Material(
            color: AppColors.errorContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Archive Tenant Profile',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Resido Kerala · Property & Tenancy Records',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.tenant, required this.onEdit});

  final MockTenant tenant;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final (
      statusText,
      statusBg,
      statusFg,
      dot,
      pulse,
    ) = switch (tenant.status) {
      TenantStatus.active => (
        'ACTIVE TENANCY',
        AppColors.secondaryContainer.withValues(alpha: 0.4),
        AppColors.onSecondaryContainer,
        AppColors.secondary,
        true,
      ),
      TenantStatus.unassigned => (
        'UNASSIGNED',
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
        AppColors.outline,
        false,
      ),
      TenantStatus.past => (
        'PAST TENANT',
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
        AppColors.outline,
        false,
      ),
    };

    Widget pill(IconData icon, String label, {bool filled = false}) => Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            // Calls / WhatsApp need device services: display only.
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  // Scales down only on very narrow screens (320 px).
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.primary,
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
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -48,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TenantAvatar(
                  initials: tenant.initials,
                  size: 80,
                  background: AppColors.primaryContainer,
                  color: AppColors.onPrimary,
                  textStyle: AppTextStyles.headlineMd,
                ),
                const SizedBox(height: 12),
                Text(
                  tenant.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMd.copyWith(
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resident ID: ${tenant.residentId}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusDot(color: dot, size: 6, pulsing: pulse),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: AppTextStyles.labelMd.copyWith(
                          color: statusFg,
                          letterSpacing: 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    pill(Icons.call, 'Call'),
                    const SizedBox(width: 8),
                    pill(Icons.chat_outlined, 'WhatsApp'),
                    const SizedBox(width: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Material(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        child: IconButton(
                          tooltip: 'Edit Profile',
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_note,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    Widget row(
      IconData icon,
      String label,
      String value, {
      bool bold = false,
    }) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: bold ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Contact Information', style: AppTextStyles.titleLg),
          const SizedBox(height: 12),
          row(
            Icons.phone_iphone,
            'Primary Mobile',
            tenant.displayPhone,
            bold: true,
          ),
          if (tenant.email.isNotEmpty) ...[
            const SizedBox(height: 12),
            row(Icons.mail_outline, 'Email Address', tenant.email),
          ],
          if (tenant.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: AppColors.onTertiaryFixedVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Landlord Memo',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tenant.notes,
                          style: AppTextStyles.bodySm.copyWith(
                            height: AppTextStyles.relaxed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CurrentTenancy extends StatelessWidget {
  const _CurrentTenancy({required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    final tenancy = tenant.tenancy!;
    final unit = tenancy.unit;
    final image = tenancy.property.cardImage ?? tenancy.property.heroImage;

    Widget money(
      IconData icon,
      Color iconColor,
      String label,
      int amount,
      Widget footer,
    ) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                InrFormat.full(amount),
                style: AppTextStyles.currencyDisplayMobile,
              ),
            ),
            const SizedBox(height: 2),
            footer,
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Current Tenancy', style: AppTextStyles.titleLg),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StatusDot(color: AppColors.secondary, size: 6),
                  const SizedBox(width: 4),
                  Text(
                    'Active since ${tenancy.activeSince}',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: AppShadows.sm,
                    ),
                    child: image == null
                        ? Icon(
                            tenancy.property.icon,
                            color: AppColors.primaryContainer,
                          )
                        : Image.asset(image, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenancy.property.typeLabel.toUpperCase(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          tenancy.property.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSm,
                        ),
                        Text(
                          '${unit.name} · ${unit.floor} (${unit.layout}) · '
                          '${tenancy.property.addressLine}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    money(
                      Icons.payments_outlined,
                      AppColors.secondary,
                      'Monthly Rent',
                      tenancy.rent,
                      Row(
                        children: [
                          const Icon(
                            Icons.event_repeat,
                            size: 12,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              'Due ${tenancy.dueDay}',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    money(
                      Icons.shield_outlined,
                      AppColors.onTertiaryContainer,
                      'Security Deposit',
                      tenancy.deposit,
                      Text(
                        'Refundable advance held',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_edu_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agreement Span (${tenancy.termLabel})',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            tenancy.endDate.isEmpty
                                ? 'From ${tenancy.startDate}'
                                : '${tenancy.startDate} – ${tenancy.endDate}',
                            style: AppTextStyles.labelLg,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${tenancy.remainingMonths} Mo Left',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'View Tenancy Details',
                trailingIcon: Icons.arrow_forward,
                iconSize: 18,
                height: 48,
                radius: 8,
                textStyle: AppTextStyles.labelLg,
                onPressed: () => AppRoutes.openTenancyDetails(context, tenant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignPrompt extends StatelessWidget {
  const _AssignPrompt({required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Tenancy Assignment', style: AppTextStyles.titleLg),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StatusDot(color: AppColors.outline, size: 6),
                  const SizedBox(width: 4),
                  Text(
                    'Vacant Profile',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No active tenancy assigned',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Text(
                  'This tenant is currently not linked to any property or unit in '
                  'your Kerala portfolio.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: AppTextStyles.relaxed,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Assign to Unit',
                leadingIcon: Icons.add_home_work_outlined,
                height: 48,
                radius: 8,
                textStyle: AppTextStyles.labelLg,
                onPressed: () =>
                    AppRoutes.openAssignTenant(context, tenant: tenant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
