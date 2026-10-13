import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/utils/inr_words.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/screens/tenancy_details_screen.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// Arguments for [AppRoutes.assignTenant]. Anything left null is chosen
/// inside the flow.
class AssignTenantArgs {
  const AssignTenantArgs({this.tenant, this.property, this.unit});

  final MockTenant? tenant;
  final MockProperty? property;
  final MockUnit? unit;
}

enum _Term {
  elevenMonths('11 Mo (Standard)', '11 Months Standard', 11),
  oneYear('1 Full Year', '1 Full Year', 12),
  openEnded('Open Ended', 'Open Ended', 0);

  const _Term(this.label, this.summary, this.months);

  final String label;
  final String summary;
  final int months;
}

/// 20. Assign Tenant — four steps (unit, terms, duration, notes) with
/// Back / Next. "Create Tenancy" opens a clearly labelled preview of the
/// tenancy; nothing is created or stored.
class AssignTenantScreen extends StatefulWidget {
  const AssignTenantScreen({super.key, this.args = const AssignTenantArgs()});

  final AssignTenantArgs args;

  static const dueDays = [
    '1st of every month',
    '5th of every month',
    '10th of every month',
    '15th of every month',
  ];

  @override
  State<AssignTenantScreen> createState() => _AssignTenantScreenState();
}

class _AssignTenantScreenState extends State<AssignTenantScreen> {
  static const _stepTitles = [
    'Property & Available Unit',
    'Commercial Terms',
    'Tenancy Duration',
    'Notes & Utility Readings',
  ];

  late MockTenant _tenant =
      widget.args.tenant ?? TenantMockData.unassigned.first;
  late MockProperty _property =
      widget.args.property ??
      PropertyMockData.properties.firstWhere(
        (p) => p.hasVacancies,
        orElse: () => PropertyMockData.properties.first,
      );
  late MockUnit? _unit = widget.args.unit ?? _vacantUnits.firstOrNull;
  late final _rent = TextEditingController(
    text: _unit == null ? '' : InrFormat.grouped(_unit!.rent),
  );
  final _deposit = TextEditingController();
  final _notes = TextEditingController();
  String _dueDay = AssignTenantScreen.dueDays.first;
  _Term _term = _Term.elevenMonths;

  /// Fixed mock start date (first of next month in the preview).
  DateTime _start = DateTime(2026, 11, 1);
  DateTime? _customEnd;
  int _step = 0;
  bool _showErrors = false;

  List<MockUnit> get _vacantUnits =>
      _property.units.where((u) => u.status == UnitStatus.vacant).toList();

  int get _rentValue => int.tryParse(_rent.text.replaceAll(',', '')) ?? 0;
  int get _depositValue => int.tryParse(_deposit.text.replaceAll(',', '')) ?? 0;

  DateTime? get _end {
    if (_customEnd != null) return _customEnd;
    if (_term == _Term.openEnded) return null;
    return DateTime(_start.year, _start.month + _term.months, _start.day - 1);
  }

  @override
  void dispose() {
    _rent.dispose();
    _deposit.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _stepValid => switch (_step) {
    0 => _unit != null,
    1 => _rentValue > 0 && _depositValue > 0,
    _ => true,
  };

  void _next() {
    if (!_stepValid) {
      setState(() => _showErrors = true);
      return;
    }
    if (_step < 3) {
      setState(() {
        _step++;
        _showErrors = false;
      });
    } else {
      _createPreview();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() {
        _step--;
        _showErrors = false;
      });
    }
  }

  void _createPreview() {
    final end = _end;
    final tenancy = MockTenancy(
      reference: '#TNC-PREVIEW',
      property: _property,
      unit: _unit!,
      rent: _rentValue,
      deposit: _depositValue,
      dueDay: _dueDay.replaceFirst(' every', ''),
      startDate: formatDate(_start),
      endDate: end == null ? '' : formatDate(end),
      termLabel: _customEnd != null ? 'Custom Term' : _term.summary,
      activeSince: formatMonth(_start),
      elapsedMonths: 0,
      totalMonths: _term.months,
    );
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.tenancyDetails,
      arguments: TenancyDetailsArgs(
        tenant: _tenant,
        tenancy: tenancy,
        preview: true,
      ),
    );
  }

  Future<void> _chooseTenant() async {
    final options = {_tenant, ...TenantMockData.unassigned}.toList();
    final picked = await showModalBottomSheet<MockTenant>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Choose Tenant', style: AppTextStyles.headlineSm),
            ),
            for (final t in options)
              ListTile(
                leading: TenantAvatar(initials: t.initials, size: 40),
                title: Text(t.name, style: AppTextStyles.titleLg),
                subtitle: Text(
                  t.displayPhone,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                trailing: t.id == _tenant.id
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryContainer,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(t),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _tenant = picked);
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : (_end ?? _start);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _customEnd = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = _step == 3;
    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Assign Tenant',
        showEdit: true,
        showMore: true,
        showAvatar: false,
      ),
      body: Column(
        children: [
          _ProgressStrip(step: _step),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                _TenantCard(tenant: _tenant, onChange: _chooseTenant),
                const SizedBox(height: 16),
                _StepCard(
                  number: _step + 1,
                  title: _stepTitles[_step],
                  trailing: switch (_step) {
                    0 || 2 => Text(
                      '* Required',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    1 => Text(
                      'Entered by landlord',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    _ => Text(
                      'Optional',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  },
                  child: switch (_step) {
                    0 => _unitStep(),
                    1 => _termsStep(),
                    2 => _durationStep(),
                    _ => _notesStep(),
                  },
                ),
                if (last) ...[
                  const SizedBox(height: 16),
                  _Summary(
                    tenant: _tenant,
                    property: _property,
                    unit: _unit!,
                    start: formatDate(_start),
                    rent: _rentValue,
                    deposit: _depositValue,
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: last ? 'Create Tenancy' : 'Next',
                  leadingIcon: last ? Icons.person_add_alt_outlined : null,
                  trailingIcon: last ? null : Icons.arrow_forward,
                  textStyle: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  shadows: AppShadows.md,
                  onPressed: _next,
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: _step == 0 ? 'Cancel & Discard' : 'Back',
                  leadingIcon: _step == 0 ? null : Icons.arrow_back,
                  height: 48,
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.onSurfaceVariant,
                  textStyle: AppTextStyles.labelLg,
                  shadows: const [],
                  onPressed: _back,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _unitStep() {
    final occupied = _property.units
        .where((u) => u.status == UnitStatus.occupied)
        .map((u) => u.number)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Target Property', style: AppTextStyles.labelLg),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      _property.addressLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _SelectBox<MockProperty>(
          icon: Icons.apartment,
          value: _property,
          items: PropertyMockData.properties,
          labelOf: (p) => '${p.name}, ${p.shortLocality}',
          onChanged: (p) => setState(() {
            _property = p;
            _unit = _vacantUnits.firstOrNull;
            if (_unit != null) _rent.text = InrFormat.grouped(_unit!.rent);
          }),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text('Select Vacant Unit', style: AppTextStyles.labelLg),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_vacantUnits.length} '
                '${_vacantUnits.length == 1 ? 'Unit' : 'Units'} Vacant',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_vacantUnits.isEmpty)
          _InfoNote(
            icon: Icons.info_outline,
            text:
                'No vacant units in ${_property.name}. Choose another property.',
            color: _showErrors ? AppColors.error : AppColors.onSurfaceVariant,
          )
        else
          for (final (i, u) in _vacantUnits.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            _UnitOption(
              unit: u,
              selected: _unit?.number == u.number,
              onTap: () => setState(() {
                _unit = u;
                _rent.text = InrFormat.grouped(u.rent);
              }),
            ),
          ],
        if (occupied.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InfoNote(
            icon: Icons.info_outline,
            text:
                'Units ${occupied.join(' & ')} are currently occupied and '
                'not shown.',
          ),
        ],
      ],
    );
  }

  Widget _termsStep() {
    final rentError = _showErrors && _rentValue <= 0;
    final depositError = _showErrors && _depositValue <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabelRow('Agreed Monthly Rent *', note: 'Excludes Maintenance'),
        const SizedBox(height: 6),
        _AmountField(
          controller: _rent,
          suffix: 'INR / MONTH',
          error: rentError,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 6),
        _HelperLine(
          rentError
              ? 'Enter the agreed monthly rent in ₹.'
              : InrWords.of(_rentValue),
          error: rentError,
        ),
        const SizedBox(height: 16),
        _FieldLabelRow('Security Deposit *'),
        const SizedBox(height: 6),
        _AmountField(
          controller: _deposit,
          suffix: 'REFUNDABLE',
          error: depositError,
          hint: 'Enter amount',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 6),
        _HelperLine(
          depositError
              ? 'Enter the security deposit in ₹.'
              : _depositValue > 0
              ? InrWords.of(_depositValue)
              : 'Refundable · entered by landlord',
          error: depositError,
        ),
        const SizedBox(height: 16),
        _FieldLabelRow('Rent Due Schedule *'),
        const SizedBox(height: 6),
        _SelectBox<String>(
          icon: Icons.calendar_month_outlined,
          value: _dueDay,
          items: AssignTenantScreen.dueDays,
          labelOf: (d) => d,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '5-Day Grace Period',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          onChanged: (d) => setState(() => _dueDay = d),
        ),
      ],
    );
  }

  Widget _durationStep() {
    final end = _end;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'AGREEMENT TERM PRESET',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.55,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final (i, t) in _Term.values.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _PresetButton(
                  label: t.label,
                  selected: _customEnd == null && t == _term,
                  onTap: () => setState(() {
                    _term = t;
                    _customEnd = null;
                  }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DateBox(
                label: 'Start Date *',
                value: formatDate(_start),
                icon: Icons.calendar_today_outlined,
                onTap: () => _pickDate(start: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateBox(
                label: 'End Date (Optional)',
                value: end == null ? 'Not set' : formatDate(end),
                icon: Icons.event_repeat,
                onTap: () => _pickDate(start: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _InfoNote(
          icon: Icons.verified_user_outlined,
          text: 'End date is optional for open-ended tenancies.',
          background: AppColors.surfaceContainer,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _notesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Handover Notes & Meter Details', style: AppTextStyles.labelMd),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _notes,
            minLines: 3,
            maxLines: null,
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.bodyMd,
            decoration: InputDecoration.collapsed(
              hintText:
                  'Add KSEB meter reading, water meter units, key sets '
                  'handover details...',
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Useful for handover records',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              '${_notes.text.length}/300 chars',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "01 Nov 2026".
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

/// "Nov 2026".
String formatMonth(DateTime d) => '${_months[d.month - 1]} ${d.year}';

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              const StatusDot(color: AppColors.secondary, pulsing: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'TENANCY ALLOTMENT FLOW',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
              Text(
                'STEP ${step + 1} OF 4',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.55,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.surfaceContainerHighest),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.centerLeft,
                    widthFactor: (step + 1) / 4,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({required this.tenant, required this.onChange});

  final MockTenant tenant;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
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
            right: -24,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    TenantAvatar(
                      initials: tenant.initials,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLg.copyWith(
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 15,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  tenant.displayPhone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onChange,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.swap_horiz,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Change',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const StatusDot(color: AppColors.tertiaryFixedDim),
                      const SizedBox(width: 8),
                      Text(
                        'Profile Status:',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ready for Assignment',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.trailing,
    required this.child,
  });

  final int number;
  final String title;
  final Widget trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyles.headlineSm)),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Dropdown styled as the design's tinted select button.
class _SelectBox<T> extends StatelessWidget {
  const _SelectBox({
    required this.icon,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.trailing,
  });

  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?trailing,
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                dropdownColor: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                items: [
                  for (final item in items)
                    DropdownMenuItem(
                      value: item,
                      child: Text(
                        labelOf(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.unit,
    required this.selected,
    required this.onTap,
  });

  final MockUnit unit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = unit.condition == UnitCondition.ready;
    final area = InrFormat.grouped(unit.areaSqFt);
    final radius = BorderRadius.circular(12);
    return Semantics(
      selected: selected,
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: selected ? AppShadows.sm : null,
        ),
        child: Material(
          color: selected
              ? AppColors.secondaryContainer.withValues(alpha: 0.2)
              : AppColors.surfaceContainerLow,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: AppColors.onPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  unit.name,
                                  style: AppTextStyles.titleLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ready
                                        ? AppColors.secondaryContainer
                                        : AppColors.tertiaryFixed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    ready
                                        ? 'READY TO MOVE'
                                        : 'TOUCHUPS IN PROGRESS',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: ready
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.onTertiaryFixed,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${unit.floor} · ${unit.layout} ($area sq.ft)',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text.rich(
                        TextSpan(
                          text: InrFormat.compact(unit.rent),
                          children: [
                            TextSpan(
                              text: '/mo',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        style: AppTextStyles.labelLg.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ready ? Icons.key_outlined : Icons.schedule,
                          size: 14,
                          color: ready
                              ? AppColors.secondary
                              : AppColors.tertiaryFixedDim,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ready
                                ? 'Ready to move · Inspected ${unit.inspectedOn}'
                                : 'Painting & touch-ups in progress',
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 11,
                              color: ready
                                  ? AppColors.secondary
                                  : AppColors.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.icon,
    required this.text,
    this.color = AppColors.onSurfaceVariant,
    this.background = AppColors.surfaceContainerLow,
    this.iconColor = AppColors.outline,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(color: color, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabelRow extends StatelessWidget {
  const _FieldLabelRow(this.label, {this.note});

  final String label;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.labelLg)),
        if (note != null)
          Text(
            note!,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _HelperLine extends StatelessWidget {
  const _HelperLine(this.text, {this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: AppTextStyles.bodySm.copyWith(
          color: error ? AppColors.error : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ₹ amount input with Indian digit grouping.
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.suffix,
    required this.onChanged,
    this.error = false,
    this.hint = '0',
  });

  final TextEditingController controller;
  final String suffix;
  final VoidCallback onChanged;
  final bool error;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: error ? Border.all(color: AppColors.error, width: 1.5) : null,
      ),
      child: Row(
        children: [
          Text(
            '₹',
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                _GroupingFormatter(),
              ],
              onChanged: (_) => onChanged(),
              style: AppTextStyles.currencyDisplayMobile.copyWith(fontSize: 20),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outlineVariant,
                ),
              ),
            ),
          ),
          Text(
            suffix,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupingFormatter extends TextInputFormatter {
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

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMd.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.labelMd),
        const SizedBox(height: 6),
        Material(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(icon, size: 20, color: AppColors.secondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.tenant,
    required this.property,
    required this.unit,
    required this.start,
    required this.rent,
    required this.deposit,
  });

  final MockTenant tenant;
  final MockProperty property;
  final MockUnit unit;
  final String start;
  final int rent;
  final int deposit;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSm.copyWith(
            fontSize: 11,
            color: AppColors.onPrimaryContainer,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final shortName = property.name.split(' ').take(2).join(' ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in_outlined,
                size: 22,
                color: AppColors.primaryFixed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assignment Summary',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$shortName #${unit.number}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cell('Tenant', tenant.name)),
              const SizedBox(width: 8),
              Expanded(child: cell('Effective Date', start)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: cell('Rent / Mo', InrFormat.full(rent))),
              const SizedBox(width: 8),
              Expanded(
                child: cell('Security Advance', InrFormat.full(deposit)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
