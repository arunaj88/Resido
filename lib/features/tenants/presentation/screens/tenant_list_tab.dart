import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/home/presentation/widgets/home_top_bar.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

enum _Filter {
  all('All'),
  active('Active'),
  unassigned('Unassigned'),
  past('Past Leases');

  const _Filter(this.label);

  final String label;

  bool matches(MockTenant t) => switch (this) {
    _Filter.all => true,
    _Filter.active => t.status == TenantStatus.active,
    _Filter.unassigned => t.status == TenantStatus.unassigned,
    _Filter.past => t.status == TenantStatus.past,
  };
}

/// 16. Tenant List — the Tenants tab. Search, filters and the empty
/// preview are local UI state over mock tenants.
class TenantListTab extends StatefulWidget {
  const TenantListTab({
    super.key,
    required this.onOpenNotifications,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenProfile;

  @override
  State<TenantListTab> createState() => _TenantListTabState();
}

class _TenantListTabState extends State<TenantListTab> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;
  bool _demoEmpty = false;

  List<MockTenant> get _tenants => TenantMockData.tenants;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(MockTenant t) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    final tenancy = t.tenancy;
    return [
      t.name,
      t.phone,
      t.displayPhone,
      t.occupation,
      if (tenancy != null) ...[
        tenancy.property.name,
        tenancy.unit.name,
        tenancy.unit.floor,
      ],
    ].any((field) => field.toLowerCase().contains(q));
  }

  void _addTenant() => Navigator.of(context).pushNamed(AppRoutes.addTenant);

  @override
  Widget build(BuildContext context) {
    final visible = _demoEmpty
        ? const <MockTenant>[]
        : _tenants
              .where((t) => _filter.matches(t) && _matchesQuery(t))
              .toList();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: HomeTopBar(
        eyebrow: 'Resido Kerala',
        section: 'Tenants',
        hasUnread: false,
        onNotifications: widget.onOpenNotifications,
        onAvatar: widget.onOpenProfile,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 88),
            children: [
              _Heading(
                demoEmpty: _demoEmpty,
                onToggleDemo: () => setState(() => _demoEmpty = !_demoEmpty),
              ),
              const SizedBox(height: 12),
              _KpiStrip(tenants: _tenants),
              const SizedBox(height: 12),
              _SearchField(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 8),
              _FilterChips(
                selected: _filter,
                countFor: (f) => _tenants.where(f.matches).length,
                onSelected: (f) => setState(() {
                  _filter = f;
                  _demoEmpty = false;
                }),
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                _EmptyState(onAdd: _addTenant)
              else
                for (final (i, t) in visible.indexed) ...[
                  if (i > 0) const SizedBox(height: 14),
                  TenantCard(
                    tenant: t,
                    onOpenProfile: () =>
                        AppRoutes.openTenantDetails(context, t),
                    onOpenLease: () => AppRoutes.openTenancyDetails(context, t),
                    onAssignUnit: () =>
                        AppRoutes.openAssignTenant(context, tenant: t),
                  ),
                ],
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset + 16,
            child: AppButton(
              label: 'Add Tenant',
              leadingIcon: Icons.person_add_alt_outlined,
              height: 48,
              shadows: AppShadows.lg,
              onPressed: _addTenant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.demoEmpty, required this.onToggleDemo});

  final bool demoEmpty;
  final VoidCallback onToggleDemo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DIRECTORY & LEASES',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 0.55,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tenants Directory',
                style: AppTextStyles.headlineMd.copyWith(letterSpacing: -0.55),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: demoEmpty
              ? AppColors.secondaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onToggleDemo,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    demoEmpty ? 'Show List' : 'Demo Empty',
                    style: AppTextStyles.labelMd.copyWith(
                      color: demoEmpty
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.tenants});

  final List<MockTenant> tenants;

  @override
  Widget build(BuildContext context) {
    int count(TenantStatus s) => tenants.where((t) => t.status == s).length;
    Widget tile(String label, int value, {Color? dot, bool accent = false}) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: accent
                        ? AppColors.secondary
                        : AppColors.onSurfaceVariant,
                    fontWeight: accent ? FontWeight.w600 : null,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (dot != null) ...[
                      StatusDot(color: dot),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '$value',
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          tile('Total', tenants.length),
          const SizedBox(width: 8),
          tile(
            'Active',
            count(TenantStatus.active),
            dot: AppColors.secondary,
            accent: true,
          ),
          const SizedBox(width: 8),
          tile(
            'Unassigned',
            count(TenantStatus.unassigned),
            dot: AppColors.outlineVariant,
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
          const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration.collapsed(
                hintText: 'Search by name, phone, or unit...',
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
                size: 14,
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
    (Color, Color) badge(_Filter f) => switch (f) {
      _Filter.all => (AppColors.secondary, AppColors.onPrimary),
      _Filter.active => (
        AppColors.secondaryContainer,
        AppColors.onSecondaryContainer,
      ),
      _Filter.unassigned => (
        AppColors.surfaceContainerHighest,
        AppColors.onSurface,
      ),
      _Filter.past => (
        AppColors.surfaceContainerHigh,
        AppColors.onSurfaceVariant,
      ),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (final (i, f) in _Filter.values.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Semantics(
              selected: f == selected,
              button: true,
              child: GestureDetector(
                onTap: () => onSelected(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: f == selected
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.label,
                        style: AppTextStyles.labelMd.copyWith(
                          color: f == selected
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: f == selected
                              ? AppColors.secondary
                              : badge(f).$1,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${countFor(f)}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: f == selected
                                ? AppColors.onPrimary
                                : badge(f).$2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
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
              Icons.groups,
              size: 40,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'READY FOR LEASES',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.secondary,
              letterSpacing: 0.55,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No tenants found',
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Add your first tenant to keep their contact details in one place '
              'and link them to a unit in your portfolio.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: AppButton(
              label: 'Add First Tenant',
              leadingIcon: Icons.person_add_alt_outlined,
              height: 48,
              textStyle: AppTextStyles.labelLg,
              shadows: AppShadows.md,
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}
