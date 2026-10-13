import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/property_form_fields.dart';

/// Arguments for the unit form. Without [unit] the form opens in Add mode.
class UnitFormArgs {
  const UnitFormArgs({required this.property, this.unit});

  final MockProperty property;
  final MockUnit? unit;
}

enum _Mode { add, edit }

/// 15. Add/Edit Unit — one form with the design's Add / Edit mode switch.
/// Values are local; saving only checks required fields and goes back.
class UnitFormScreen extends StatefulWidget {
  const UnitFormScreen({super.key, required this.args});

  final UnitFormArgs args;

  static const unitTypes = [
    'Residential 3 BHK',
    'Residential 2 BHK',
    'Residential 1 BHK / Studio',
    'Commercial Shop/Office',
    'Single Room / Annex',
  ];

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _name = TextEditingController();
  final _floor = TextEditingController();
  final _rent = TextEditingController();
  final _notes = TextEditingController();
  String _type = UnitFormScreen.unitTypes.first;
  late _Mode _mode = widget.args.unit == null ? _Mode.add : _Mode.edit;
  bool _showErrors = false;

  MockProperty get _property => widget.args.property;

  /// Unit used to prefill Edit mode (the design previews a vacant unit).
  MockUnit get _editUnit =>
      widget.args.unit ??
      _property.units.firstWhere(
        (u) => u.status == UnitStatus.vacant,
        orElse: () => _property.units.first,
      );

  static const _quickTags = [
    (Icons.bolt_outlined, 'KSEB 3-Phase', 'KSEB 3-Phase'),
    (Icons.water_drop_outlined, 'KWA Connection', 'KWA Water Meter'),
    (Icons.directions_car_outlined, 'Covered Parking', 'Covered Car Park'),
    (Icons.countertops_outlined, 'Modular Kitchen', 'Modular Kitchen'),
  ];

  @override
  void initState() {
    super.initState();
    _applyMode(_mode);
  }

  @override
  void dispose() {
    for (final c in [_name, _floor, _rent, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyMode(_Mode mode) {
    _mode = mode;
    _showErrors = false;
    if (mode == _Mode.add) {
      _name.clear();
      _floor.clear();
      _rent.clear();
      _notes.clear();
      _type = UnitFormScreen.unitTypes.first;
      return;
    }
    final unit = _editUnit;
    _name.text = unit.name;
    _floor.text = unit.floor;
    _rent.text = InrFormat.grouped(unit.rent);
    _notes.text = unit.notes;
    _type = _typeFor(unit.layout);
  }

  static String _typeFor(String layout) {
    final l = layout.toLowerCase();
    if (l.contains('annex')) return 'Single Room / Annex';
    if (l.contains('showroom') || l.contains('office') || l.contains('shop')) {
      return 'Commercial Shop/Office';
    }
    if (l.contains('2 bhk')) return 'Residential 2 BHK';
    if (l.contains('1 bhk')) return 'Residential 1 BHK / Studio';
    return 'Residential 3 BHK';
  }

  int get _rentValue => int.tryParse(_rent.text.replaceAll(',', '')) ?? 0;

  void _appendTag(String tag) {
    final current = _notes.text.trim();
    if (current.contains(tag)) return;
    setState(() => _notes.text = current.isEmpty ? tag : '$current, $tag');
  }

  void _save() {
    if (_name.text.trim().isEmpty || _rentValue <= 0) {
      setState(() => _showErrors = true);
      return;
    }
    // Presentation only: nothing is stored.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = _mode == _Mode.edit;
    final nameError = _showErrors && _name.text.trim().isEmpty;
    final rentError = _showErrors && _rentValue <= 0;

    return Scaffold(
      appBar: SubPageTopBar(
        title: editing ? 'Edit Unit' : 'Add Unit',
        showMore: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 40,
        ),
        children: [
          _ParentProperty(property: _property),
          const SizedBox(height: 8),
          _ModeSwitch(
            mode: _mode,
            onChanged: (m) => setState(() => _applyMode(m)),
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(
              icon: Icons.meeting_room_outlined,
              size: 32,
              background: AppColors.primaryFixed,
              color: Color(0xFF002117),
            ),
            headerGap: 4,
            title: editing ? 'Edit Specifications' : 'Unit Specifications',
            subtitle: 'Core identifiers and floor allocation',
            trailing: SectionBadge(
              editing ? 'EDITING #${_editUnit.number}' : 'CREATING',
              background: editing
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerHigh,
              foreground: editing
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            gap: 12,
            children: [
              LabeledField(
                label: const FieldLabel(
                  'Unit Number or Name',
                  required: true,
                  color: AppColors.onSurface,
                  trailing: FieldNote('Required'),
                ),
                field: FormTextInput(
                  controller: _name,
                  shadow: false,
                  hintText: 'e.g., Flat 3B, Villa Annex, Shop #2',
                  errorBorder: nameError,
                  onChanged: (_) => setState(() {}),
                ),
                helper: nameError
                    ? const FieldHelper(
                        'Please provide an identifier for this unit.',
                        icon: Icons.error_outline,
                        color: AppColors.error,
                      )
                    : null,
              ),
              LabeledField(
                label: const FieldLabel(
                  'Unit Type',
                  required: true,
                  color: AppColors.onSurface,
                ),
                field: FormDropdown(
                  value: _type,
                  options: UnitFormScreen.unitTypes,
                  shadow: false,
                  icon: Icons.expand_more,
                  iconColor: AppColors.onSurfaceVariant,
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
              LabeledField(
                label: const FieldLabel(
                  'Floor Level',
                  color: AppColors.onSurface,
                  trailing: FieldNote('Optional'),
                ),
                field: FormTextInput(
                  controller: _floor,
                  shadow: false,
                  hintText: 'e.g., Ground Floor, 1st Floor, 2nd Floor',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(
              icon: Icons.currency_rupee,
              size: 32,
              background: AppColors.secondaryContainer,
              color: AppColors.onSecondaryContainer,
            ),
            headerGap: 4,
            title: 'Lease & Commercials',
            subtitle: 'Monthly realization and security expectations',
            gap: 12,
            children: [
              LabeledField(
                label: const FieldLabel(
                  'Monthly Rent (₹)',
                  required: true,
                  color: AppColors.onSurface,
                  trailing: FieldNote('Per calendar month'),
                ),
                field: FormTextInput(
                  controller: _rent,
                  shadow: false,
                  hintText: 'e.g., 20000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    _IndianGroupingFormatter(),
                  ],
                  errorBorder: rentError,
                  textStyle: AppTextStyles.headlineSm,
                  onChanged: (_) => setState(() {}),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Text(
                      '₹',
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                helper: rentError
                    ? const FieldHelper(
                        'Please enter a valid monthly rent amount in ₹.',
                        icon: Icons.error_outline,
                        color: AppColors.error,
                      )
                    : const FieldHelper(
                        'Expected monthly rent in Indian Rupees excluding '
                        'maintenance charges.',
                      ),
              ),
              const _DepositGuidance(),
            ],
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            leading: const SectionIconTile(
              icon: Icons.notes,
              size: 32,
              background: AppColors.surfaceContainerHigh,
              color: AppColors.onSurfaceVariant,
            ),
            headerGap: 4,
            title: 'Unit Description & Utility Specs',
            subtitle: 'Metering tags, furnishings, and parking slots',
            gap: 12,
            children: [
              LabeledField(
                label: const FieldLabel(
                  'Unit Description / Notes',
                  color: AppColors.onSurface,
                  trailing: FieldNote('Optional'),
                ),
                field: FormTextInput(
                  controller: _notes,
                  shadow: false,
                  minLines: 4,
                  hintText:
                      'e.g., East facing, semi-furnished with modular '
                      'kitchen, KSEB consumer #4829103, 1 car parking slot.',
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUICK TAGS',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (icon, label, tag) in _quickTags)
                        _QuickTag(
                          icon: icon,
                          label: label,
                          onTap: () => _appendTag(tag),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: editing ? 'Save Changes' : 'Save Unit',
            leadingIcon: Icons.save_outlined,
            backgroundColor: AppColors.primary,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: AppColors.surfaceContainerLowest,
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

class _ParentProperty extends StatelessWidget {
  const _ParentProperty({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.apartment, size: 20, color: AppColors.secondary),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PARENT PROPERTY',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${property.name}, ${property.shortLocality}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              property.city,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.mode, required this.onChanged});

  final _Mode mode;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(_Mode value, IconData icon, String label) {
      final selected = value == mode;
      final fg = selected ? AppColors.primary : AppColors.onSurfaceVariant;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.surfaceContainerLowest
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: selected ? AppShadows.sm : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLg.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          button(_Mode.add, Icons.add_circle_outline, 'Add Unit Mode'),
          button(_Mode.edit, Icons.edit_note, 'Edit Unit (Prefilled)'),
        ],
      ),
    );
  }
}

/// Static Kerala deposit guidance (no amounts are calculated).
class _DepositGuidance extends StatelessWidget {
  const _DepositGuidance();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Security Deposit Guidance',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SectionBadge(
                '3-10 Months',
                background: AppColors.secondaryFixed,
                foreground: AppColors.onSecondaryFixed,
                bold: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kerala standard is typically 3 to 10 months rent. For long-term '
            'residential leases in Ernakulam, landlords commonly collect 3-6 '
            'months advance.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTag extends StatelessWidget {
  const _QuickTag({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formats typed rupee digits with Indian grouping (20000 → 20,000).
class _IndianGroupingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = InrFormat.grouped(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
