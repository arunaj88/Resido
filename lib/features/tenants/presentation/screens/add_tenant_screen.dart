import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 17. Add Tenant. Fields are local state; "Save Tenant" only checks the
/// required name for presentation and returns — nothing is stored.
class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  bool _showErrors = false;

  static const _tags = [
    'IT Professional',
    'Family',
    'NRI Relocation',
    'Long-term',
  ];

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _appendTag(String tag) {
    final current = _notes.text.trim();
    final next = current.isEmpty ? tag : '$current • $tag';
    if (next.length > 250) return;
    setState(() => _notes.text = next);
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    // Presentation only: return without storing the tenant.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final nameError = _showErrors && _name.text.trim().isEmpty;
    final helper = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );

    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Add Tenant',
        showEdit: true,
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.paddingOf(context).bottom + 48,
        ),
        children: [
          const _RegistryBanner(),
          const SizedBox(height: 24),
          const BarSectionTitle('Personal Details'),
          const SizedBox(height: 16),
          LabeledField(
            label: const FieldLabel(
              'Full Name',
              required: true,
              color: AppColors.onSurface,
              trailing: FieldNote('Mandatory', color: AppColors.outline),
            ),
            field: FormTextInput(
              controller: _name,
              radius: 12,
              hintText: 'e.g. Kavitha R. Pillai',
              errorBorder: nameError,
              onChanged: (_) => setState(() {}),
              prefix: const _FieldIcon(Icons.badge_outlined),
            ),
            helper: nameError
                ? const FieldHelper(
                    'Please enter the tenant’s full name.',
                    icon: Icons.error_outline,
                    color: AppColors.error,
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text('As per tenancy agreement', style: helper),
                  ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const _OptionalLabel(
              'Phone Number',
              trailing: FieldNote('WhatsApp enabled'),
            ),
            field: IndianPhoneField(controller: _phone),
            helper: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('Standard 10-digit mobile number', style: helper),
            ),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const _OptionalLabel('Email Address'),
            field: FormTextInput(
              controller: _email,
              radius: 12,
              hintText: 'kavitha.pillai@email.in',
              keyboardType: TextInputType.emailAddress,
              prefix: const _FieldIcon(Icons.mail_outline),
            ),
            helper: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('Optional contact email', style: helper),
            ),
          ),
          const SizedBox(height: 24),
          const BarSectionTitle(
            'Background & Memo',
            barColor: AppColors.secondary,
            trailing: FieldNote('Private owner note'),
          ),
          const SizedBox(height: 16),
          LabeledField(
            label: const _OptionalLabel('Profile Notes'),
            field: FormTextInput(
              controller: _notes,
              radius: 12,
              minLines: 4,
              hintText:
                  'Software professional relocated to Infopark area. '
                  'Moving in with family.',
              inputFormatters: [LengthLimitingTextInputFormatter(250)],
              onChanged: (_) => setState(() {}),
              textStyle: AppTextStyles.bodyMd.copyWith(
                height: AppTextStyles.relaxed,
              ),
            ),
            helper: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Private note for your records', style: helper),
                  ),
                  FieldNote(
                    '${_notes.text.length} / 250',
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SUGGESTED QUICK TAGS',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _tags)
                Material(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _appendTag(tag),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text('+ $tag', style: AppTextStyles.labelSm),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const _NextStepsCard(),
          const SizedBox(height: 36),
          AppButton(
            label: 'Save Tenant',
            leadingIcon: Icons.save_outlined,
            textStyle: AppTextStyles.headlineSm,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: AppColors.surfaceContainerLow,
            foregroundColor: AppColors.onSurfaceVariant,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
    );
  }
}

/// "Label (Optional)" field label.
class _OptionalLabel extends StatelessWidget {
  const _OptionalLabel(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(
            text: ' (Optional)',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      style: AppTextStyles.labelLg,
    );
    if (trailing == null) return label;
    return Row(
      children: [
        Expanded(child: label),
        trailing!,
      ],
    );
  }
}

class _RegistryBanner extends StatelessWidget {
  const _RegistryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_outlined,
                    size: 22,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TENANT RECORD REGISTRY',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.55,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a contact profile for a prospective or current '
                        'tenant. You can assign them to a property and unit after '
                        'saving.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: AppTextStyles.relaxed,
                        ),
                      ),
                    ],
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

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next?',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saving creates a tenant profile in your Resido directory. You '
                  'will have the option to assign an available unit and configure '
                  'monthly rent immediately.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: AppTextStyles.relaxed,
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
