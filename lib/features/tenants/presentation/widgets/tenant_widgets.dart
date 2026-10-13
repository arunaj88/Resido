import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';

/// Initials avatar used across the tenant screens.
class TenantAvatar extends StatelessWidget {
  const TenantAvatar({
    super.key,
    required this.initials,
    this.size = 48,
    this.background = AppColors.surfaceContainerHigh,
    this.color = AppColors.secondary,
    this.textStyle,
  });

  final String initials;
  final double size;
  final Color background;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initials,
        style: (textStyle ?? AppTextStyles.headlineSm).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Status pill for a tenant: Active, Due Nd Ago, Unassigned, Completed.
class TenantStatusChip extends StatelessWidget {
  const TenantStatusChip({super.key, required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    final overdue = tenant.overdueDays != null;
    final (
      Color bg,
      Color fg,
      Widget lead,
      String label,
    ) = switch (tenant.status) {
      TenantStatus.active when overdue => (
        AppColors.tertiaryFixed,
        AppColors.onTertiaryFixed,
        const StatusDot(
          color: AppColors.onTertiaryContainer,
          size: 6,
          pulsing: true,
        ),
        'Due ${tenant.overdueDays}d Ago',
      ),
      TenantStatus.active => (
        AppColors.secondaryContainer,
        AppColors.onSecondaryContainer,
        const StatusDot(color: AppColors.secondary, size: 6),
        'Active',
      ),
      TenantStatus.unassigned => (
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
        const StatusDot(color: AppColors.outline, size: 6),
        'Unassigned',
      ),
      TenantStatus.past => (
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
        const Icon(Icons.history, size: 12, color: AppColors.onSurfaceVariant),
        'Completed',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          lead,
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelMd.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Round call / WhatsApp button. Calls and messages need device services,
/// so these are display-only in the UI phase.
class ContactCircleButton extends StatelessWidget {
  const ContactCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

/// Tenant card from Stitch "16. Tenant List".
class TenantCard extends StatelessWidget {
  const TenantCard({
    super.key,
    required this.tenant,
    required this.onOpenProfile,
    required this.onOpenLease,
    required this.onAssignUnit,
  });

  final MockTenant tenant;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenLease;
  final VoidCallback onAssignUnit;

  @override
  Widget build(BuildContext context) {
    final past = tenant.status == TenantStatus.past;
    final initialsColor = switch (tenant.status) {
      TenantStatus.active when tenant.overdueDays != null =>
        AppColors.onTertiaryContainer,
      TenantStatus.active => AppColors.secondary,
      _ => AppColors.onSurfaceVariant,
    };
    final radius = BorderRadius.circular(12);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.sm),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenProfile,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: past ? 0.75 : 1,
                      child: TenantAvatar(
                        initials: tenant.initials,
                        color: initialsColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  tenant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleLg,
                                ),
                              ),
                              if (past) ...[
                                const SizedBox(width: 6),
                                Text(
                                  'Archived',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            tenant.occupation,
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
                    TenantStatusChip(tenant: tenant),
                  ],
                ),
                const SizedBox(height: 14),
                _middle(),
                const SizedBox(height: 12),
                _footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _middle() {
    final tenancy = tenant.tenancy;
    if (tenancy != null) {
      final overdue = tenant.overdueDays != null;
      final unit = tenancy.unit;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    tenancy.property.category == PropertyCategory.villas
                        ? Icons.villa_outlined
                        : Icons.apartment,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tenancy.property.name} · ${unit.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${unit.floor} · ${unit.layout} · '
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      overdue ? 'RENT DUE' : 'MONTHLY RENT',
                      style: AppTextStyles.labelSm.copyWith(
                        color: overdue
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  Text(
                    InrFormat.full(
                      overdue
                          ? tenancy.unit.pendingAmount ?? tenancy.rent
                          : tenancy.rent,
                    ),
                    style: AppTextStyles.titleLg.copyWith(
                      color: overdue
                          ? AppColors.error
                          : AppColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (tenant.paymentNote != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· ${tenant.paymentNote}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: overdue ? AppColors.error : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    final past = tenant.status == TenantStatus.past;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            past
                ? Icons.history_edu_outlined
                : tenant.unassignedNote.startsWith('Lease')
                ? Icons.pending_actions_outlined
                : Icons.person_add_alt_outlined,
            size: 20,
            color: AppColors.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              past ? (tenant.pastSummary ?? '') : tenant.unassignedNote,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (past)
            Text(
              'Clean Exit',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppShadows.sm,
              ),
              child: Material(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onAssignUnit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.link,
                          size: 14,
                          color: AppColors.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Assign Unit',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _footer() {
    final past = tenant.status == TenantStatus.past;
    final overdue = tenant.overdueDays != null;
    final phone = Text(
      tenant.displayPhone,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
    );
    final hasLease = tenant.hasTenancy;
    return Row(
      children: [
        if (past)
          Expanded(child: phone)
        else ...[
          ContactCircleButton(
            icon: Icons.call_outlined,
            tooltip: 'Call ${tenant.name}',
          ),
          const SizedBox(width: 8),
          ContactCircleButton(
            icon: Icons.chat_outlined,
            tooltip: 'WhatsApp ${tenant.name}',
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          if (overdue)
            // Reminders need a messaging service: display only.
            Material(
              color: AppColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.send_outlined,
                        size: 14,
                        color: AppColors.onTertiaryFixed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Remind',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onTertiaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!overdue) Expanded(child: phone) else const Spacer(),
        ],
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: hasLease ? onOpenLease : onOpenProfile,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasLease ? 'Lease' : 'Profile',
                  style: AppTextStyles.labelMd.copyWith(
                    color: hasLease
                        ? AppColors.secondary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: hasLease
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Phone input with the fixed 🇮🇳 +91 prefix block.
class IndianPhoneField extends StatelessWidget {
  const IndianPhoneField({super.key, required this.controller, this.trailing});

  final TextEditingController controller;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            color: AppColors.surfaceContainerLow,
            child: Text(
              '🇮🇳 +91',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.55,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: AppTextStyles.bodyMd.copyWith(letterSpacing: 0.35),
              decoration: InputDecoration.collapsed(
                hintText: '98471 22340',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outline.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

/// Section heading with a small coloured bar (Add Tenant form).
class BarSectionTitle extends StatelessWidget {
  const BarSectionTitle(
    this.title, {
    super.key,
    this.barColor = AppColors.primaryContainer,
    this.trailing,
  });

  final String title;
  final Color barColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 14,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppTextStyles.titleLg)),
        ?trailing,
      ],
    );
  }
}
