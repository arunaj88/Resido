import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';

/// 13. Edit Property, prefilled from the selected mock property. Edits stay
/// in this screen's local state; "Save Changes" returns without storing.
class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({super.key, required this.property});

  final MockProperty property;

  static const propertyTypes = [
    'Apartment Building',
    'Independent Villa',
    'Ancestral Tharavadu',
    'Commercial Plaza',
    'Gated Community Layout',
  ];

  static const districts = [
    'Ernakulam',
    'Thiruvananthapuram',
    'Kozhikode',
    'Thrissur',
    'Kottayam',
    'Kannur',
    'Malappuram',
    'Alappuzha',
    'Palakkad',
    'Kollam',
  ];

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  late final _name = TextEditingController(text: widget.property.name);
  late final _street = TextEditingController(text: widget.property.street);
  late final _locality = TextEditingController(text: widget.property.locality);
  late final _city = TextEditingController(text: widget.property.city);
  late final _pin = TextEditingController(text: widget.property.pinCode);
  late final _description = TextEditingController(
    text: widget.property.description,
  );
  late String _type = switch (widget.property.category) {
    PropertyCategory.apartments => 'Apartment Building',
    PropertyCategory.villas => 'Independent Villa',
    PropertyCategory.commercial => 'Commercial Plaza',
  };
  late String _district = widget.property.district;
  bool _showErrors = false;

  @override
  void dispose() {
    for (final c in [_name, _street, _locality, _city, _pin, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _missing(TextEditingController c) =>
      _showErrors && c.text.trim().isEmpty;

  void _save() {
    final ok =
        [
          _name,
          _street,
          _locality,
          _city,
        ].every((c) => c.text.trim().isNotEmpty) &&
        pinStateOf(_pin.text) != PinState.incomplete;
    if (!ok) {
      setState(() => _showErrors = true);
      return;
    }
    // Presentation only: nothing is stored.
    Navigator.of(context).maybePop();
  }

  void _showDeletionBlocked() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x99293040),
      isScrollControlled: true,
      builder: (_) => _DeletionBlockedSheet(property: widget.property),
    );
  }

  @override
  Widget build(BuildContext context) {
    const label = AppColors.onSurfaceVariant;
    return Scaffold(
      appBar: const SubPageTopBar(title: 'Edit Property', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _EditingBanner(property: widget.property),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(icon: Icons.apartment),
            title: 'Basic Information',
            gap: 12,
            firstGap: 16,
            children: [
              LabeledField(
                label: const FieldLabel(
                  'Property Name',
                  required: true,
                  color: label,
                  trailing: FieldNote('Max 60 chars', color: AppColors.outline),
                ),
                field: FormTextInput(
                  controller: _name,
                  shadow: false,
                  hintText: 'e.g. Palm Grove Enclave',
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  errorBorder: _missing(_name),
                ),
              ),
              LabeledField(
                label: const FieldLabel(
                  'Property Type',
                  required: true,
                  color: label,
                ),
                field: FormDropdown(
                  value: _type,
                  options: EditPropertyScreen.propertyTypes,
                  shadow: false,
                  icon: Icons.expand_more,
                  iconColor: AppColors.onSurfaceVariant,
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(icon: Icons.location_on_outlined),
            title: 'Location & Address',
            gap: 12,
            firstGap: 16,
            children: [
              LabeledField(
                label: const FieldLabel(
                  'Street Address / House Name',
                  required: true,
                  color: label,
                ),
                field: FormTextInput(
                  controller: _street,
                  shadow: false,
                  errorBorder: _missing(_street),
                ),
              ),
              LabeledField(
                label: const FieldLabel(
                  'Locality / Landmark',
                  required: true,
                  color: label,
                ),
                field: FormTextInput(
                  controller: _locality,
                  shadow: false,
                  errorBorder: _missing(_locality),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: const FieldLabel(
                        'City or Town',
                        required: true,
                        color: label,
                      ),
                      field: FormTextInput(
                        controller: _city,
                        shadow: false,
                        errorBorder: _missing(_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LabeledField(
                      label: const FieldLabel(
                        'District',
                        required: true,
                        color: label,
                      ),
                      field: FormDropdown(
                        value: _district,
                        options: EditPropertyScreen.districts,
                        shadow: false,
                        icon: Icons.expand_more,
                        iconColor: AppColors.onSurfaceVariant,
                        onChanged: (v) => setState(() => _district = v),
                      ),
                    ),
                  ),
                ],
              ),
              LabeledField(
                label: const FieldLabel(
                  'Postal PIN Code',
                  required: true,
                  color: label,
                ),
                field: FormTextInput(
                  controller: _pin,
                  shadow: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textStyle: AppTextStyles.bodyMd.copyWith(letterSpacing: 0.35),
                  errorBorder:
                      _showErrors &&
                      pinStateOf(_pin.text) == PinState.incomplete,
                  onChanged: (_) => setState(() {}),
                  suffix: pinStateOf(_pin.text) == PinState.incomplete
                      ? null
                      : const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: _ValidPinChip(),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(icon: Icons.description_outlined),
            title: 'Property Features & Description',
            gap: 12,
            firstGap: 16,
            children: [
              LabeledField(
                label: const FieldLabel('Description', color: label),
                field: FormTextInput(
                  controller: _description,
                  shadow: false,
                  minLines: 4,
                  textStyle: AppTextStyles.bodyMd.copyWith(
                    height: AppTextStyles.relaxed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Save Changes',
            leadingIcon: Icons.save_outlined,
            textStyle: AppTextStyles.labelLg,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 48,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.onSurface,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 28),
          _DangerZone(onDelete: _showDeletionBlocked),
        ],
      ),
    );
  }
}

class _EditingBanner extends StatelessWidget {
  const _EditingBanner({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 13,
                        color: AppColors.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'EDITING: ${property.registryId}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.name,
                  style: AppTextStyles.headlineSm.copyWith(
                    letterSpacing: -0.45,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(child: _BannerNote()),
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

class _BannerNote extends StatelessWidget {
  const _BannerNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Changes here update all unit listings and official rent receipt headers.',
      style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant),
    );
  }
}

class _ValidPinChip extends StatelessWidget {
  const _ValidPinChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            'Valid PIN',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Danger Zone', style: AppTextStyles.titleLg),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Deleting this property removes all historical registries, receipts, '
            'and association logs. This action cannot be undone.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Delete this Property',
            leadingIcon: Icons.delete_forever_outlined,
            iconSize: 18,
            height: 44,
            radius: 8,
            backgroundColor: AppColors.surfaceContainerLowest,
            foregroundColor: AppColors.error,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet from the design explaining why deletion is blocked.
class _DeletionBlockedSheet extends StatelessWidget {
  const _DeletionBlockedSheet({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final total = property.units.length;
    final occupied = property.occupiedCount;
    final filled = total == 0 ? 0 : (occupied * 100 / total).round();
    final row = AppTextStyles.labelMd.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_clock_outlined,
                    size: 28,
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Deletion Blocked',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: 8),
              Text(
                'Cannot delete property while active units have recorded tenants.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Active Leases', style: row)),
                        Text(
                          '$occupied Active Tenants',
                          style: row.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: Text('Occupancy Status', style: row)),
                        Text(
                          '$filled% Filled',
                          style: row.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To remove ${property.name}, please first terminate or '
                      'transfer active tenant agreements and clear pending rent '
                      'settlements.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Understood, Keep Property',
                height: 48,
                textStyle: AppTextStyles.labelLg,
                shadows: const [],
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
