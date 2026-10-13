import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/widgets/maintenance_widgets.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';

enum _Filter {
  all('All', null),
  open('Open', MaintenanceStatus.open),
  inProgress('In Progress', MaintenanceStatus.inProgress),
  completed('Completed', MaintenanceStatus.completed);

  const _Filter(this.label, this.status);

  final String label;
  final MaintenanceStatus? status;

  bool matches(MaintenanceRequest r) => status == null || r.status == status;
}

/// 29. Maintenance — static request list with search, status filters and
/// an empty-state preview.
class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;
  bool _previewEmpty = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(MaintenanceRequest r) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      r.title,
      r.categoryLabel,
      r.property.name,
      r.locationLabel,
      r.summary,
    ].any((s) => s.toLowerCase().contains(q));
  }

  void _create() => AppRoutes.openMaintenanceForm(context);

  @override
  Widget build(BuildContext context) {
    const all = MaintenanceMockData.requests;
    final visible = _previewEmpty
        ? const <MaintenanceRequest>[]
        : all.where((r) => _filter.matches(r) && _matchesQuery(r)).toList();

    return Scaffold(
      appBar: const SubPageTopBar(title: 'Maintenance', showAvatar: false),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          Row(
            children: [
              const StatusDot(color: AppColors.error, pulsing: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  MaintenanceMockData.activeSummary,
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 164,
                child: AppButton(
                  label: 'New Request',
                  leadingIcon: Icons.add_circle_outline,
                  iconSize: 18,
                  height: 44,
                  radius: 10,
                  textStyle: AppTextStyles.labelLg,
                  onPressed: _create,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RentSearchField(
            controller: _search,
            hintText: 'Search tap leak, motor, electrical...',
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final (i, f) in _Filter.values.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  RentFilterChip(
                    label: f.label,
                    count: all.where(f.matches).length,
                    selected: f == _filter,
                    onTap: () => setState(() {
                      _filter = f;
                      _previewEmpty = false;
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            _EmptyState(onCreate: _create)
          else
            for (final (i, r) in visible.indexed) ...[
              if (i > 0) const SizedBox(height: 14),
              _RequestCard(request: r),
            ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.tune,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              const Expanded(child: RentCaption('Preview Empty State')),
              Switch(
                value: _previewEmpty,
                onChanged: (v) => setState(() => _previewEmpty = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final MaintenanceRequest request;

  @override
  Widget build(BuildContext context) {
    final completed = request.status == MaintenanceStatus.completed;
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.surfaceContainerLow
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: completed ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final tags = [
                PriorityTag(priority: request.priority),
                StatusTag(status: request.status),
              ];
              // One line of tags when there is room (390 px); on very narrow
              // screens they may wrap instead of overflowing.
              final roomy = constraints.maxWidth >= 300;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaintenanceIconTile(
                    icon: request.category.icon,
                    color: completed ? AppColors.outline : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RentCaption(request.categoryLabel),
                        Text(request.reported, style: muted),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (roomy)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [tags[0], const SizedBox(width: 4), tags[1]],
                    )
                  else
                    Flexible(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 4,
                        runSpacing: 4,
                        children: tags,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            request.title,
            style: AppTextStyles.headlineSm.copyWith(
              decoration: completed ? TextDecoration.lineThrough : null,
              color: completed ? AppColors.onSurfaceVariant : null,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: completed ? AppColors.outline : AppColors.secondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.location,
                  style: AppTextStyles.labelLg.copyWith(
                    color: completed
                        ? AppColors.onSurfaceVariant
                        : AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.surfaceContainerLowest
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  request.summaryIcon,
                  size: 18,
                  color: completed
                      ? AppColors.secondary
                      : request.priority == MaintenancePriority.high
                      ? AppColors.error
                      : AppColors.onTertiaryFixedVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.summary,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                request.footerIcon,
                size: 16,
                color: completed ? AppColors.secondary : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.footer,
                  maxLines: 2,
                  style: AppTextStyles.labelMd.copyWith(
                    color: completed
                        ? AppColors.secondary
                        : AppColors.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () =>
                    AppRoutes.openMaintenanceDetails(context, request),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      completed ? 'View Log' : 'View Details',
                      style: AppTextStyles.labelLg.copyWith(
                        color: completed
                            ? AppColors.onSurfaceVariant
                            : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      completed ? Icons.history : Icons.arrow_forward,
                      size: 16,
                      color: completed
                          ? AppColors.onSurfaceVariant
                          : AppColors.secondary,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_repair_service_outlined,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text('No Maintenance Requests', style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(
            'All properties and units are in good working order. When issues '
            'arise, log them here to track repairs.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Create Request',
            leadingIcon: Icons.add_circle_outline,
            height: 48,
            textStyle: AppTextStyles.labelLg,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
