import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';

/// 11. Add Property. All fields are local state; "Save Property" only
/// checks required fields for presentation and returns to the list —
/// nothing is stored.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  static const propertyTypes = [
    'Apartment Building',
    'Independent House / Villa',
    'Commercial Property',
    'Traditional Tharavadu / Homestay',
  ];

  static const districts = [
    'Ernakulam',
    'Thiruvananthapuram',
    'Kozhikode',
    'Thrissur',
    'Kottayam',
    'Malappuram',
    'Alappuzha',
    'Palakkad',
    'Kannur',
    'Kollam',
    'Idukki',
    'Pathanamthitta',
    'Wayanad',
    'Kasaragod',
  ];

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  // Sample values shown in the approved design.
  final _name = TextEditingController(text: 'Palm Grove Heights');
  final _street = TextEditingController(text: 'Flat 4A, Marine View Road');
  final _locality = TextEditingController(
    text: 'Near Infopark Phase 1, Kakkanad',
  );
  final _city = TextEditingController(text: 'Kochi');
  final _pin = TextEditingController(text: '682030');
  final _notes = TextEditingController(
    text:
        '3-storey building with borewell & KWA water connection, 15kVA '
        'solar inverter backup, and reserved basement parking for all units.',
  );
  String _type = AddPropertyScreen.propertyTypes.first;
  String _district = 'Ernakulam';
  final _amenities = <String>{'KWA + Well', 'Solar Backup'};
  bool _showErrors = false;

  static const _amenityOptions = [
    (Icons.water_drop_outlined, 'KWA + Well'),
    (Icons.solar_power_outlined, 'Solar Backup'),
    (Icons.local_parking, 'Gated Parking'),
    (Icons.security, 'CCTV Installed'),
  ];

  @override
  void dispose() {
    for (final c in [_name, _street, _locality, _city, _pin, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _missing(TextEditingController c) =>
      _showErrors && c.text.trim().isEmpty;

  void _save() {
    final requiredFilled = [
      _name,
      _street,
      _locality,
      _city,
    ].every((c) => c.text.trim().isNotEmpty);
    final pinOk = pinStateOf(_pin.text) != PinState.incomplete;
    if (!requiredFilled || !pinOk) {
      setState(() => _showErrors = true);
      return;
    }
    // Presentation only: return to the Property List without storing.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SubPageTopBar(title: 'Add Property', showMore: true),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 40,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: _RegistryBanner(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _basicInfo(),
                const SizedBox(height: 20),
                _location(),
                const SizedBox(height: 20),
                _notesSection(),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Save Property',
                  leadingIcon: Icons.domain_verification,
                  iconSize: 22,
                  textStyle: AppTextStyles.headlineSm,
                  shadows: AppShadows.md,
                  onPressed: _save,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Cancel & Return',
                  height: 44,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: AppColors.onSurfaceVariant,
                  textStyle: AppTextStyles.labelLg,
                  shadows: const [],
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _basicInfo() {
    return FormSectionCard(
      leading: const Icon(Icons.apartment, size: 20, color: AppColors.primary),
      title: 'Basic Information',
      trailing: const SectionBadge('Step 1 of 3'),
      children: [
        LabeledField(
          label: const FieldLabel('Property Name', required: true),
          field: FormTextInput(
            controller: _name,
            hintText: 'e.g., Palm Grove Enclave or Green Valley Villa',
            errorBorder: _missing(_name),
            onChanged: (_) => setState(() {}),
            suffix: _name.text.trim().isEmpty
                ? null
                : const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
          ),
          helper: const FieldHelper(
            'Official registry identifier or estate display title',
            icon: Icons.info_outline,
          ),
        ),
        LabeledField(
          label: const FieldLabel('Property Type', required: true),
          field: FormDropdown(
            value: _type,
            options: AddPropertyScreen.propertyTypes,
            onChanged: (v) => setState(() => _type = v),
          ),
          helper: FieldHelper(
            'Optimizes unit numbering, floor plans & Kerala municipal rates',
            icon: Icons.home_work_outlined,
            color: AppColors.secondary,
            style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _location() {
    final pinState = pinStateOf(_pin.text);
    return FormSectionCard(
      leading: const Icon(
        Icons.pin_drop_outlined,
        size: 20,
        color: AppColors.primary,
      ),
      title: 'Location & Address',
      trailing: const SectionBadge(
        'Kerala Standard',
        background: AppColors.secondaryContainer,
        foreground: AppColors.onSecondaryContainer,
        bold: true,
      ),
      children: [
        LabeledField(
          label: const FieldLabel(
            'Street Address / House Name',
            required: true,
          ),
          field: FormTextInput(
            controller: _street,
            hintText: 'e.g., Flat 4A, Marine View Road',
            errorBorder: _missing(_street),
          ),
        ),
        LabeledField(
          label: const FieldLabel('Locality / Landmark', required: true),
          field: FormTextInput(
            controller: _locality,
            hintText: 'e.g., Near Infopark Phase 1',
            errorBorder: _missing(_locality),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledField(
                label: const FieldLabel('City / Town', required: true),
                field: FormTextInput(
                  controller: _city,
                  hintText: 'e.g., Kochi',
                  errorBorder: _missing(_city),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: const FieldLabel('District', required: true),
                field: FormDropdown(
                  value: _district,
                  options: AddPropertyScreen.districts,
                  onChanged: (v) => setState(() => _district = v),
                ),
              ),
            ),
          ],
        ),
        LabeledField(
          label: FieldLabel(
            'Postal PIN Code',
            required: true,
            trailing: _PinBadge(state: pinState),
          ),
          field: FormTextInput(
            controller: _pin,
            hintText: '6-digit PIN',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            errorBorder: _showErrors && pinState == PinState.incomplete,
            textStyle: AppTextStyles.headlineSm.copyWith(letterSpacing: 1.8),
            onChanged: (_) => setState(() {}),
            suffix: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: switch (pinState) {
                PinState.keralaValid => const Icon(
                  Icons.verified,
                  size: 22,
                  color: AppColors.secondary,
                ),
                PinState.indianNonKerala => const Icon(
                  Icons.check_circle_outline,
                  size: 22,
                  color: AppColors.onTertiaryContainer,
                ),
                PinState.incomplete => const Icon(
                  Icons.error_outline,
                  size: 22,
                  color: AppColors.outline,
                ),
              },
            ),
          ),
          helper: switch (pinState) {
            PinState.keralaValid => const FieldHelper(
              'Must be a 6-digit Indian PIN code (Kerala PINs start with 67, '
              '68, or 69).',
            ),
            PinState.indianNonKerala => const FieldHelper(
              'Valid 6-digit Indian PIN (outside Kerala Circle).',
            ),
            PinState.incomplete => const FieldHelper(
              'Must be exactly 6 numeric digits.',
              color: AppColors.error,
            ),
          },
        ),
        const _MapPreview(),
      ],
    );
  }

  Widget _notesSection() {
    return FormSectionCard(
      leading: const Icon(
        Icons.sticky_note_2_outlined,
        size: 20,
        color: AppColors.primary,
      ),
      title: 'Notes & Description',
      trailing: const FieldNote('Optional'),
      gap: 12,
      children: [
        LabeledField(
          label: const FieldLabel('Property Notes'),
          field: FormTextInput(
            controller: _notes,
            minLines: 3,
            hintText:
                'e.g., 3-storey building with borewell & KWA water '
                'connection, solar backup, gated parking.',
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            onChanged: (_) => setState(() {}),
            textStyle: AppTextStyles.bodyMd.copyWith(
              height: AppTextStyles.relaxed,
            ),
          ),
          helper: Row(
            children: [
              Expanded(
                child: Text(
                  'Include utility connections, water source & security features',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FieldNote('${_notes.text.length}/300', color: AppColors.outline),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUICK AMENITIES & HIGHLIGHTS',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (icon, label) in _amenityOptions)
                    _ToggleChip(
                      icon: icon,
                      label: label,
                      selected: _amenities.contains(label),
                      onTap: () => setState(() {
                        if (!_amenities.remove(label)) _amenities.add(label);
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RegistryBanner extends StatelessWidget {
  const _RegistryBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.domain_add,
              size: 20,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PORTFOLIO REGISTRY',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 0.55,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create a new property record in your Kerala portfolio. You '
                  'can add individual units and lease records after saving.',
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

class _PinBadge extends StatelessWidget {
  const _PinBadge({required this.state});

  final PinState state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (state) {
      PinState.keralaValid => (
        AppColors.secondaryContainer.withValues(alpha: 0.5),
        AppColors.secondary,
        Icons.check_circle,
        'Valid Kerala PIN',
      ),
      PinState.indianNonKerala => (
        AppColors.tertiaryFixed,
        AppColors.tertiaryContainer,
        Icons.info_outline,
        'Indian PIN (Non-Kerala)',
      ),
      PinState.incomplete => (
        AppColors.errorContainer.withValues(alpha: 0.5),
        AppColors.error,
        Icons.cancel_outlined,
        'Incomplete',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        height: 112,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.sm,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/add_property_map.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  const Icon(
                    Icons.share_location,
                    size: 16,
                    color: AppColors.primaryFixed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kakkanad, Kochi Region',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GPS Anchored',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.labelMd.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
