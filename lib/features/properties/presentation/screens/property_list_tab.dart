import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/property_card.dart';

enum _Filter {
  all('All'),
  apartments('Apartments'),
  villas('Villas & Houses'),
  commercial('Commercial'),
  occupied('Fully Occupied'),
  vacancies('Has Vacancies');

  const _Filter(this.label);

  final String label;

  bool matches(MockProperty p) => switch (this) {
    _Filter.all => true,
    _Filter.apartments => p.category == PropertyCategory.apartments,
    _Filter.villas => p.category == PropertyCategory.villas,
    _Filter.commercial => p.category == PropertyCategory.commercial,
    _Filter.occupied => !p.hasVacancies,
    _Filter.vacancies => p.hasVacancies,
  };

  /// Category chips show a count, status chips do not (per design).
  bool get showsCount => index <= _Filter.commercial.index;
}

/// 10. Property List — the Properties tab. Search, chips and the empty
/// preview are local UI state over mock data.
class PropertyListTab extends StatefulWidget {
  const PropertyListTab({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;

  @override
  State<PropertyListTab> createState() => _PropertyListTabState();
}

class _PropertyListTabState extends State<PropertyListTab> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;
  bool _previewEmpty = false;

  static const _properties = PropertyMockData.properties;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(MockProperty p) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      p.name,
      p.shortLocality,
      p.city,
      p.district,
      p.pinCode,
    ].any((field) => field.toLowerCase().contains(q));
  }

  void _resetFilters() {
    setState(() {
      _search.clear();
      _filter = _Filter.all;
      _previewEmpty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _previewEmpty
        ? const <MockProperty>[]
        : _properties
              .where((p) => _filter.matches(p) && _matchesQuery(p))
              .toList();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: HomeTopBar(
        eyebrow: 'Resido Kerala',
        section: 'Property List',
        hasUnread: false,
        onNotifications: widget.onOpenNotifications,
        onAvatar: widget.onOpenProfile,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 88),
            children: [
              _SearchRow(controller: _search, onChanged: () => setState(() {})),
              const SizedBox(height: 16),
              _FilterChips(
                selected: _filter,
                countFor: (f) => _properties.where(f.matches).length,
                onSelected: (f) => setState(() {
                  _filter = f;
                  _previewEmpty = false;
                }),
              ),
              const SizedBox(height: 16),
              _PortfolioHealth(
                previewingEmpty: _previewEmpty,
                onTogglePreview: () =>
                    setState(() => _previewEmpty = !_previewEmpty),
              ),
              const SizedBox(height: 16),
              if (visible.isEmpty)
                _NoMatches(onClear: _resetFilters)
              else
                for (final (i, p) in visible.indexed) ...[
                  if (i > 0) const SizedBox(height: 16),
                  PropertyCard(
                    property: p,
                    onOpen: () => AppRoutes.openPropertyDetails(context, p),
                    onManageUnits: () => AppRoutes.openUnitList(context, p),
                  ),
                ],
            ],
          ),
          Positioned(
            right: 16,
            bottom: bottomInset + 16,
            child: _AddPropertyButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.addProperty),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final box = BoxDecoration(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppShadows.sm,
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: box,
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, size: 20, color: AppColors.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (_) => onChanged(),
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search property name, locality, PIN...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        controller.clear();
                        onChanged();
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Filter drawer is not part of the approved designs yet.
        Container(
          width: 48,
          height: 48,
          decoration: box,
          child: IconButton(
            tooltip: 'Filter options',
            onPressed: () {},
            icon: const Icon(
              Icons.tune,
              size: 22,
              color: AppColors.primaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  final _Filter selected;
  final int Function(_Filter) countFor;
  final ValueChanged<_Filter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, f) in _Filter.values.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            _Chip(
              label: f.showsCount ? '${f.label} (${countFor(f)})' : f.label,
              selected: f == selected,
              onTap: () => onSelected(f),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.sm,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: selected
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioHealth extends StatelessWidget {
  const _PortfolioHealth({
    required this.previewingEmpty,
    required this.onTogglePreview,
  });

  final bool previewingEmpty;
  final VoidCallback onTogglePreview;

  @override
  Widget build(BuildContext context) {
    const props = PropertyMockData.properties;
    final units = props.fold(0, (sum, p) => sum + p.units.length);
    final occupied = props.fold(0, (sum, p) => sum + p.occupiedCount);
    final label = AppTextStyles.labelSm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    Widget stat(
      String name,
      String value, [
      Color color = AppColors.onSurface,
    ]) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: label),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.headlineSm.copyWith(color: color)),
        ],
      ),
    );

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
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PORTFOLIO HEALTH',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.55,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${PropertyMockData.occupancyPercent}% Occupancy',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat('Properties', '${props.length}'),
              const SizedBox(width: 8),
              stat('Total Units', '$units'),
              const SizedBox(width: 8),
              stat('Occupied', '$occupied', AppColors.secondary),
              const SizedBox(width: 8),
              stat(
                'Vacant',
                '${units - occupied}',
                AppColors.onTertiaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text('Filter view simulator', style: label)),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onTogglePreview,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          previewingEmpty
                              ? 'Show Properties'
                              : 'Preview Empty State',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.tune,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                      ],
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

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cottage_outlined,
              size: 42,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No properties match your filter',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSm,
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              "We couldn't locate any estates or units matching those search "
              'terms in your Kerala registry.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onClear,
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'Clear All Filters',
                      style: AppTextStyles.labelLg,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPropertyButton extends StatelessWidget {
  const _AddPropertyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59064E3B),
            offset: Offset(0, 4),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20, color: AppColors.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Add Property',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onPrimary,
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
