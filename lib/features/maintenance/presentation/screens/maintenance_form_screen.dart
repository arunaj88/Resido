import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/widgets/maintenance_widgets.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/record_payment_screen.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';

/// 30. Create Maintenance Request — also used, prefilled, for "Edit Request
/// Details". Fields hold temporary values only; nothing is created or saved.
class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({super.key, this.request});

  /// Set when editing an existing request.
  final MaintenanceRequest? request;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  late final MaintenanceRequest? _source = widget.request;
  late MockProperty _property = _source?.property ?? PropertyMockData.palmGrove;
  late MockUnit? _unit = _initialUnit();
  late bool _entireProperty = _source?.entireProperty ?? false;
  late final _title = TextEditingController(text: _source?.title ?? '');
  late final _notes = TextEditingController(text: _source?.description ?? '');
  late MaintenanceCategory? _category = _source?.category;
  late MaintenancePriority? _priority = _source?.priority;
  DateTime _date = DateTime(2024, 10, 24);

  bool get _editing => _source != null;

  MockUnit? _initialUnit() {
    final label = _source?.locationLabel;
    if (label == null) return null;
    for (final u in _property.units) {
      if (label.startsWith(u.name) || label.startsWith(u.number)) return u;
    }
    return null;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _finish() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _editing
              ? 'Preview only — the request was not changed.'
              : 'Preview only — the request was not saved.',
        ),
      ),
    );
  }

  String _unitLabel(MockUnit u) => '${u.name} (${u.tenant ?? 'Vacant'})';

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    final dateText = rentDateLabel(_date);

    return Scaffold(
      appBar: SubPageTopBar(
        title: _editing ? 'Edit Request' : 'Create Request',
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          Row(
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RentCaption(
                  _editing ? 'Editing ${_source!.id}' : 'Internal Log',
                  color: AppColors.secondary,
                ),
              ),
              Text('Step 1 of 1', style: muted),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              height: 4,
              width: double.infinity,
              child: ColoredBox(color: AppColors.primaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            icon: Icons.apartment,
            title: 'Target Asset',
            subtitle: 'Assign location in your Kerala portfolio',
            children: [
              _Label('Property', required: true),
              _Dropdown<MockProperty>(
                icon: Icons.location_on_outlined,
                value: _property,
                items: PropertyMockData.properties,
                labelOf: (p) => '${p.name}, ${p.shortLocality}',
                onChanged: (p) => setState(() {
                  _property = p;
                  _unit = null;
                }),
              ),
              const SizedBox(height: 14),
              _Label('Assigned Unit', optional: true),
              Opacity(
                opacity: _entireProperty ? 0.5 : 1,
                child: IgnorePointer(
                  ignoring: _entireProperty,
                  child: _Dropdown<MockUnit?>(
                    icon: Icons.door_front_door_outlined,
                    value: _unit,
                    items: [null, ..._property.units],
                    labelOf: (u) =>
                        u == null ? 'No unit selected' : _unitLabel(u),
                    onChanged: (u) => setState(() => _unit = u),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Leave blank or toggle below if the fault impacts the whole '
                'estate (gate, overhead tank, well motor).',
                style: muted,
              ),
              const SizedBox(height: 10),
              Material(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                child: CheckboxListTile(
                  value: _entireProperty,
                  onChanged: (v) => setState(() => _entireProperty = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    'Applies to entire property / common areas',
                    style: AppTextStyles.labelLg,
                  ),
                  subtitle: Text(
                    'Overhead tank, security cabin, boundary wall, rain gutters',
                    style: muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            icon: Icons.report_problem_outlined,
            title: 'Issue Details',
            subtitle: 'Define fault classification and breakdown',
            children: [
              Row(
                children: [
                  Expanded(child: _Label('Request Title', required: true)),
                  Text('${_title.text.length} / 80', style: muted),
                ],
              ),
              RentInputBox(
                child: TextField(
                  controller: _title,
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration.collapsed(
                    hintText: 'e.g. Submersible pump burning smell',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _Label('Category', required: true),
              LayoutBuilder(
                builder: (context, constraints) {
                  final half = (constraints.maxWidth - 8) / 2;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in MaintenanceCategory.values)
                        SizedBox(
                          width: c == MaintenanceCategory.other
                              ? constraints.maxWidth
                              : half,
                          child: _CategoryTile(
                            category: c,
                            selected: c == _category,
                            onTap: () => setState(() => _category = c),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              _Label('Detailed Observations & Tenant Notes'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _notes,
                  minLines: 4,
                  maxLines: null,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration.collapsed(
                    hintText:
                        'Describe the fault, symptoms, tenant notes, or '
                        'access restrictions...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Private note for your records', style: muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            icon: Icons.emergency_outlined,
            title: 'Urgency & Schedule',
            subtitle: 'Set urgency level for resolution tracking',
            children: [
              _Label('Priority Level', required: true),
              Row(
                children: [
                  for (final (i, p) in MaintenancePriority.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _PriorityTile(
                        priority: p,
                        selected: p == _priority,
                        onTap: () => setState(() => _priority = p),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              _Label('Date Logged'),
              RentInputBox(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.secondary,
                ),
                trailing: const Icon(
                  Icons.edit_calendar_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: () async {
                  final picked = await pickRentDate(context, _date);
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(
                  dateText == MaintenanceMockData.today
                      ? '$dateText (Today)'
                      : dateText,
                  style: AppTextStyles.bodyLg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            icon: Icons.photo_camera_outlined,
            title: 'Visual Attachments',
            subtitle: 'Documentation for vendor / plumber reference',
            trailing: RentTag('${_source?.attachments.length ?? 0} of 3'),
            children: [
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _slot(i)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Photo upload is not available in this version.',
                      style: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MaintenanceIconTile(
                  icon: Icons.menu_book_outlined,
                  size: 32,
                  background: AppColors.secondaryContainer,
                  color: AppColors.onSecondaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Landlord Operational Record',
                        style: AppTextStyles.labelLg,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Repairs are arranged directly by the property owner; '
                        'Resido does not dispatch vendors or settle '
                        'contractor bills. In this version, requests are not '
                        'saved.',
                        style: muted.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: _editing ? 'Save Request Details' : 'Create Request',
            leadingIcon: Icons.assignment_turned_in_outlined,
            shadows: AppShadows.md,
            onPressed: _finish,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.onSurfaceVariant,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _slot(int i) {
    final attachments = _source?.attachments ?? const <String>[];
    if (i < attachments.length) return PhotoPlaceholder(label: attachments[i]);
    if (i == attachments.length) {
      // Uploading needs device storage access: shown, but inactive.
      return Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: AppColors.outline),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, color: AppColors.outlineVariant),
          Text(
            'Slot ${i + 1}',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaintenanceIconTile(icon: icon, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headlineSm),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.required = false, this.optional = false});

  final String text;
  final bool required;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            if (optional)
              TextSpan(
                text: '  Optional',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        style: AppTextStyles.labelLg,
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final IconData icon;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
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
                icon: const Icon(
                  Icons.unfold_more,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                dropdownColor: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                items: [
                  for (final item in items)
                    DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        labelOf(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => onChanged(v as T),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final MaintenanceCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final fg = selected ? AppColors.onPrimary : AppColors.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: category == MaintenanceCategory.other
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: selected
                      ? AppColors.secondaryFixed
                      : AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLg.copyWith(color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final MaintenancePriority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final high = priority == MaintenancePriority.high;
    final (bg, fg) = selected
        ? priorityColors(priority)
        : (AppColors.surfaceContainerLow, AppColors.onSurface);
    final radius = BorderRadius.circular(10);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                Icon(
                  priority.icon,
                  size: 20,
                  color: high && selected ? AppColors.error : fg,
                ),
                const SizedBox(height: 4),
                Text(
                  high ? 'Urgent' : priority.label,
                  style: AppTextStyles.labelLg.copyWith(color: fg),
                ),
                Text(
                  priority.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: selected ? fg : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
