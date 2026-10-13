import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/unit_visuals.dart';

enum _UnitFilter { all, occupied, vacant }

/// 14. Unit List for the selected property. Search, filter and the empty
/// preview switch are local UI state over the property's mock units.
class UnitListScreen extends StatefulWidget {
  const UnitListScreen({super.key, required this.property});

  final MockProperty property;

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  final _search = TextEditingController();
  _UnitFilter _filter = _UnitFilter.all;
  bool _previewEmpty = false;

  MockProperty get _property => widget.property;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(MockUnit u) {
    final byFilter = switch (_filter) {
      _UnitFilter.all => true,
      _UnitFilter.occupied => u.status == UnitStatus.occupied,
      _UnitFilter.vacant => u.status == UnitStatus.vacant,
    };
    final q = _search.text.trim().toLowerCase();
    final byQuery =
        q.isEmpty ||
        [
          u.number,
          u.floor,
          u.layout,
          u.tenant ?? '',
        ].any((f) => f.toLowerCase().contains(q));
    return byFilter && byQuery;
  }

  void _addUnit() => AppRoutes.openUnitForm(context, _property);

  @override
  Widget build(BuildContext context) {
    final units = _property.units.where(_matches).toList();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: const SubPageTopBar(title: 'Unit List', showMore: true),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 96),
            children: [
              _Heading(property: _property),
              const SizedBox(height: 8),
              _RentRollCard(property: _property),
              const SizedBox(height: 16),
              _SearchField(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              _Segmented(
                selected: _filter,
                counts: {
                  _UnitFilter.all: _property.units.length,
                  _UnitFilter.occupied: _property.occupiedCount,
                  _UnitFilter.vacant: _property.vacantCount,
                },
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: 16),
              if (_previewEmpty)
                _NoUnitsYet(onCreate: _addUnit)
              else if (units.isEmpty)
                const _NoMatchingUnits()
              else
                for (final (i, unit) in units.indexed) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _UnitCard(
                    unit: unit,
                    onEdit: () =>
                        AppRoutes.openUnitForm(context, _property, unit: unit),
                    onAssignTenant: () => AppRoutes.openComingSoon(
                      context,
                      'Assign Tenant',
                      Icons.person_add_alt_outlined,
                    ),
                  ),
                ],
              const SizedBox(height: 24),
              _EmptyPreviewToggle(
                value: _previewEmpty,
                onChanged: (v) => setState(() => _previewEmpty = v),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset + 16,
            child: AppButton(
              label: 'Add Unit',
              leadingIcon: Icons.add,
              iconSize: 22,
              textStyle: AppTextStyles.titleLg.copyWith(
                fontWeight: FontWeight.w700,
              ),
              shadows: AppShadows.lg,
              onPressed: _addUnit,
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconText(
                icon: Icons.apartment,
                iconSize: 14,
                text: '${property.shortLocality}, ${property.city}'
                    .toUpperCase(),
                color: AppColors.secondary,
                style: AppTextStyles.labelMd.copyWith(letterSpacing: 0.55),
              ),
              const SizedBox(height: 2),
              Text(
                'Units in ${property.name}',
                style: AppTextStyles.headlineMd,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            boxShadow: AppShadows.sm,
          ),
          child: const Icon(
            Icons.domain_verification,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _RentRollCard extends StatelessWidget {
  const _RentRollCard({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final total = property.units.length;
    final occupied = property.occupiedCount;
    final vacant = property.vacantCount;
    final occupancy = total == 0 ? 0 : (occupied * 100 / total).round();

    Widget stat(String label, int value, Color color, {Color? dot}) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dot != null) ...[
                  StatusDot(color: dot, size: 6),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: dot == null ? AppColors.onSurfaceVariant : color,
                  ),
                ),
              ],
            ),
            Text(
              '$value',
              style: AppTextStyles.titleLg.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
            right: -24,
            bottom: -24,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Potential Rent Roll',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.outline,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$occupancy% Occupancy',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      InrFormat.full(property.monthlyYield),
                      style: AppTextStyles.currencyDisplayMobile.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ month',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconText(
                          icon: Icons.trending_up,
                          iconSize: 14,
                          text: '${InrFormat.full(property.received)} realized',
                          color: AppColors.secondary,
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          gap: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (occupied > 0)
                          Expanded(
                            flex: occupied,
                            child: const ColoredBox(
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        if (vacant > 0)
                          Expanded(
                            flex: vacant,
                            child: const ColoredBox(
                              color: AppColors.onTertiaryContainer,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    stat('Total Units', total, AppColors.onSurface),
                    const SizedBox(width: 8),
                    stat(
                      'Occupied',
                      occupied,
                      AppColors.secondary,
                      dot: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    stat(
                      'Vacant',
                      vacant,
                      AppColors.tertiary,
                      dot: AppColors.onTertiaryContainer,
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 20, color: AppColors.outline),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration.collapsed(
                hintText: 'Search unit #, tenant, or floor...',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                controller.clear();
                onChanged();
              },
              icon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final _UnitFilter selected;
  final Map<_UnitFilter, int> counts;
  final ValueChanged<_UnitFilter> onSelected;

  static const _labels = {
    _UnitFilter.all: 'All',
    _UnitFilter.occupied: 'Occupied',
    _UnitFilter.vacant: 'Vacant',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final (i, f) in _UnitFilter.values.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _SegmentButton(
                label: _labels[f]!,
                count: counts[f] ?? 0,
                selected: f == selected,
                onTap: () => onSelected(f),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? AppShadows.sm : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(color: fg),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelMd.copyWith(
                    color: fg,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.onEdit,
    required this.onAssignTenant,
  });

  final MockUnit unit;
  final VoidCallback onEdit;
  final VoidCallback onAssignTenant;

  @override
  Widget build(BuildContext context) {
    final overdue = unit.condition == UnitCondition.overdue;
    final occupied = unit.status == UnitStatus.occupied;
    final area = InrFormat.grouped(unit.areaSqFt);
    final body = AppTextStyles.bodySm;

    final (
      IconData statusIcon,
      String statusTitle,
      Color statusColor,
      String statusNote,
      Color noteColor,
    ) = switch (unit.condition) {
      UnitCondition.settled => (
        Icons.event_available_outlined,
        'Lease active',
        AppColors.secondary,
        'Next due: ${unit.nextDue}',
        AppColors.onSurfaceVariant,
      ),
      UnitCondition.overdue => (
        Icons.warning_amber,
        'Overdue (${unit.overdueDays} days)',
        AppColors.error,
        '${InrFormat.full(unit.pendingAmount ?? 0)} pending',
        AppColors.error,
      ),
      UnitCondition.ready => (
        Icons.check_circle_outline,
        'Ready to Move',
        AppColors.secondary,
        'Inspected ${unit.inspectedOn}',
        AppColors.onSurfaceVariant,
      ),
      UnitCondition.refreshing => (
        Icons.format_paint_outlined,
        'Refreshing',
        AppColors.onTertiaryContainer,
        'Painting & touch-ups',
        AppColors.onSurfaceVariant,
      ),
    };

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnitNumberTile(
                number: unit.number,
                background: AppColors.surfaceContainerLow,
                color: AppColors.primary,
                textStyle: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.name, style: AppTextStyles.titleLg),
                    Text(
                      '${unit.floor} · ${unit.layout} ($area sq.ft)',
                      style: body.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(style: UnitBadgeStyle.forList(unit)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: overdue
                  ? AppColors.errorContainer.withValues(alpha: 0.4)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occupied ? 'MONTHLY RENT' : 'TARGET RENT',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              InrFormat.full(unit.rent),
                              style: AppTextStyles.currencyDisplayMobile,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ mo',
                              style: body.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconText(
                      icon: statusIcon,
                      iconSize: 14,
                      text: statusTitle,
                      color: statusColor,
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: overdue ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      statusNote,
                      style: body.copyWith(
                        color: noteColor,
                        fontWeight: overdue ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _footerLead(body)),
              ..._footerActions(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLead(TextStyle body) {
    if (unit.status == UnitStatus.occupied) {
      return Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              unit.tenantInitials,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              unit.tenant ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }
    if (unit.condition == UnitCondition.ready) {
      return Text(
        'No tenant assigned',
        style: body.copyWith(
          color: AppColors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return Text(
      'Maintenance status: ${unit.maintenanceProgress}%',
      style: body.copyWith(color: AppColors.onSurfaceVariant),
    );
  }

  List<Widget> _footerActions() {
    // "View unit details" has no approved destination yet: display only.
    const details = _RoundAction(
      icon: Icons.chevron_right,
      tooltip: 'View unit details',
      color: AppColors.primary,
    );
    switch (unit.condition) {
      case UnitCondition.settled:
        return [
          _RoundAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit ${unit.name}',
            color: AppColors.onSurfaceVariant,
            onTap: onEdit,
          ),
          const SizedBox(width: 4),
          details,
        ];
      case UnitCondition.overdue:
        return [
          // Reminders need a messaging service: display only.
          Material(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: IconText(
                  icon: Icons.send_outlined,
                  iconSize: 14,
                  text: 'Remind',
                  color: AppColors.onErrorContainer,
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          details,
        ];
      case UnitCondition.ready:
        return [
          SizedBox(
            height: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppShadows.sm,
              ),
              child: Material(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onAssignTenant,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: IconText(
                        icon: Icons.person_add_alt_outlined,
                        text: 'Assign Tenant',
                        color: AppColors.onPrimary,
                        style: AppTextStyles.labelLg.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      case UnitCondition.refreshing:
        return [details];
    }
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.surfaceContainerLow,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onTap ?? () {},
          icon: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _NoMatchingUnits extends StatelessWidget {
  const _NoMatchingUnits();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 28,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text('No matching units', style: AppTextStyles.titleLg),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              'Try adjusting your search criteria or switch filter tabs to view '
              'available units.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoUnitsYet extends StatelessWidget {
  const _NoUnitsYet({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Pulse(
                  child: Container(
                    width: 123,
                    height: 123,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.roofing,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.sm,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No units added yet',
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Add your first unit to start managing tenant leases, tracking '
              'utility meters, and collecting rent seamlessly.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: AppTextStyles.relaxed,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Create Unit 101 Now',
            leadingIcon: Icons.add_circle_outline,
            height: 48,
            radius: 8,
            backgroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLg,
            shadows: AppShadows.md,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _EmptyPreviewToggle extends StatelessWidget {
  const _EmptyPreviewToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.developer_mode,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Preview Empty State',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            height: 24,
            child: FittedBox(
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primaryContainer,
                inactiveTrackColor: AppColors.outlineVariant,
                inactiveThumbColor: Colors.white,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
