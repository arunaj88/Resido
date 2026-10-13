import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 19. Edit Tenant, prefilled from the selected mock tenant. Edits stay in
/// local state; "Save Changes" returns without storing anything.
class EditTenantScreen extends StatefulWidget {
  const EditTenantScreen({super.key, required this.tenant});

  final MockTenant tenant;

  @override
  State<EditTenantScreen> createState() => _EditTenantScreenState();
}

class _EditTenantScreenState extends State<EditTenantScreen> {
  late final _name = TextEditingController(text: widget.tenant.name);
  late final _phone = TextEditingController(text: widget.tenant.phone);
  late final _email = TextEditingController(text: widget.tenant.email);
  late final _notes = TextEditingController(text: widget.tenant.notes);
  bool _showErrors = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    // Presentation only: nothing is stored.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final tenant = widget.tenant;
    final nameError = _showErrors && _name.text.trim().isEmpty;
    Widget icon(IconData data) => Padding(
      padding: const EdgeInsets.only(left: 14, right: 8),
      child: Icon(data, size: 20, color: AppColors.onSurfaceVariant),
    );
    Text optional(String text) => Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(
            text: ' (Optional)',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.outline),
          ),
        ],
      ),
      style: AppTextStyles.labelLg,
    );

    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Edit Tenant',
        showEdit: true,
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          _EditingBanner(tenant: tenant),
          const SizedBox(height: 12),
          LabeledField(
            label: const FieldLabel(
              'Full Name',
              required: true,
              color: AppColors.onSurface,
            ),
            field: FormTextInput(
              controller: _name,
              radius: 12,
              errorBorder: nameError,
              onChanged: (_) => setState(() {}),
              prefix: icon(Icons.person_outline),
            ),
            helper: nameError
                ? const FieldHelper(
                    'Please enter the tenant’s full name.',
                    icon: Icons.error_outline,
                    color: AppColors.error,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: Row(
              children: [
                Expanded(child: optional('Phone Number')),
                // Calling needs the phone dialer: display only.
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.call_outlined,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Direct Call',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            field: IndianPhoneField(
              controller: _phone,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'WhatsApp',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: optional('Email Address'),
            field: FormTextInput(
              controller: _email,
              radius: 12,
              keyboardType: TextInputType.emailAddress,
              prefix: icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 12),
          LabeledField(
            label: const FieldLabel(
              'Internal Management Notes',
              color: AppColors.onSurface,
              trailing: FieldNote('Private to owner', color: AppColors.outline),
            ),
            field: FormTextInput(controller: _notes, radius: 12, minLines: 3),
          ),
          if (tenant.tenancy != null) ...[
            const SizedBox(height: 16),
            _LinkedTenancyCard(tenant: tenant),
          ],
          const SizedBox(height: 20),
          AppButton(
            label: 'Save Changes',
            leadingIcon: Icons.save_outlined,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.onSurface,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 12),
          _DangerZone(hasTenancy: tenant.hasTenancy),
        ],
      ),
    );
  }
}

class _EditingBanner extends StatelessWidget {
  const _EditingBanner({required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (tenant.status) {
      TenantStatus.active => 'Active',
      TenantStatus.unassigned => 'Unassigned',
      TenantStatus.past => 'Past',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.badge,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'EDITING TENANT RECORD',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.55,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tenant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm,
                    ),
                    Text(
                      tenant.residentId,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info,
                  size: 16,
                  color: AppColors.tertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Updating contact information does not alter existing tenancy '
                    'terms, rent amounts, or security deposit records.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.25,
                    ),
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

class _LinkedTenancyCard extends StatelessWidget {
  const _LinkedTenancyCard({required this.tenant});

  final MockTenant tenant;

  @override
  Widget build(BuildContext context) {
    final tenancy = tenant.tenancy!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppShadows.sm,
                ),
                child: const Icon(
                  Icons.apartment,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'LINKED TENANCY',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.55,
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
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Agreement Live',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tenancy.property.name} • ${tenancy.unit.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLg,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tenancy.property.addressLine} • '
                      '${InrFormat.full(tenancy.rent)}/mo',
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
          Row(
            children: [
              const Icon(
                Icons.lock_reset,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'To modify rent or lease terms:',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => AppRoutes.openTenancyDetails(context, tenant),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tenancy Details',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.hasTenancy});

  final bool hasTenancy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasTenancy
                ? 'Cannot be deleted while an active tenancy is linked. End '
                      'tenancy first.'
                : 'Deleting is not available in this preview.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // Deleting records is out of scope: the button stays disabled.
          Opacity(
            opacity: 0.8,
            child: AppButton(
              label: 'Delete Tenant Record',
              leadingIcon: Icons.delete_forever_outlined,
              iconSize: 18,
              height: 44,
              backgroundColor: AppColors.surfaceContainerHighest.withValues(
                alpha: 0.6,
              ),
              foregroundColor: AppColors.outline,
              textStyle: AppTextStyles.labelLg,
              shadows: const [],
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}
