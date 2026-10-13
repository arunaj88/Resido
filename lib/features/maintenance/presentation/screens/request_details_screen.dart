import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/widgets/maintenance_widgets.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 31. Request Details — one maintenance request with its location,
/// contacts and activity log.
class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.request});

  final MaintenanceRequest request;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Request Details',
        showMore: true,
        showAvatar: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      request.id,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    PriorityTag(priority: request.priority, long: true),
                    StatusTag(status: request.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(request.title, style: AppTextStyles.headlineMd),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      request.category.icon,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${request.categoryLabel} · ${request.reportedLong}',
                        style: muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _LocationCard(request: request),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(child: RentCaption('Issue Description')),
                    if (request.attachments.isNotEmpty)
                      Text(
                        '${request.attachments.length} Image Attached',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request.description,
                  style: AppTextStyles.bodyMd.copyWith(height: 1.5),
                ),
                for (final a in request.attachments) ...[
                  const SizedBox(height: 12),
                  PhotoPlaceholder(label: a, height: 140),
                ],
              ],
            ),
          ),
          if (request.assignee != null) ...[
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RentCaption('Assigned Handyman'),
                  const SizedBox(height: 10),
                  _PersonRow(
                    initials: request.assignee!.substring(0, 1),
                    name: request.assignee!,
                    role: request.assigneeRole,
                    phone: request.assigneePhone,
                    actions: const [
                      InactiveCircleButton(
                        icon: Icons.phone_in_talk_outlined,
                        tooltip: 'Call',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (request.status == MaintenanceStatus.completed) ...[
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RentCaption('Resolution'),
                  const SizedBox(height: 8),
                  Text(request.resolution ?? '', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 8),
                  Text(
                    'Completed ${request.completedOn} · '
                    'Cost recorded: ${request.cost}',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('Activity Log', style: AppTextStyles.headlineSm),
              ),
              RentTag(
                '${request.log.length} '
                '${request.log.length == 1 ? 'Entry' : 'Entries'}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final (i, e) in request.log.indexed)
                  _LogEntry(entry: e, last: i == request.log.length - 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Update Status',
            trailingIcon: Icons.arrow_forward,
            shadows: AppShadows.md,
            onPressed: () => AppRoutes.openUpdateStatus(context, request),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Edit Request Details',
            leadingIcon: Icons.edit_note,
            height: 48,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () =>
                AppRoutes.openMaintenanceForm(context, request: request),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.request});

  final MaintenanceRequest request;

  @override
  Widget build(BuildContext context) {
    final p = request.property;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MaintenanceIconTile(icon: Icons.apartment),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RentCaption('Estate Location'),
                    Text(p.name, style: AppTextStyles.headlineSm),
                    Text(
                      '${request.unitDetail} · ${p.shortLocality}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const InactiveCircleButton(
                icon: Icons.near_me_outlined,
                tooltip: 'Directions',
              ),
            ],
          ),
          if (request.tenantName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _PersonRow(
                initials: request.tenantName!
                    .replaceAll('Dr. ', '')
                    .split(' ')
                    .map((w) => w[0])
                    .take(2)
                    .join(),
                name: request.tenantName!,
                role: 'Tenant',
                phone: request.tenantPhone,
                actions: const [
                  InactiveCircleButton(
                    icon: Icons.call_outlined,
                    tooltip: 'Call',
                  ),
                  SizedBox(width: 8),
                  InactiveCircleButton(
                    icon: Icons.chat_outlined,
                    tooltip: 'Chat',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.initials,
    required this.name,
    required this.actions,
    this.role,
    this.phone,
  });

  final String initials;
  final String name;
  final String? role;
  final String? phone;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TenantAvatar(
          initials: initials.toUpperCase(),
          size: 40,
          background: AppColors.secondaryContainer,
          color: AppColors.onSecondaryContainer,
          textStyle: AppTextStyles.labelLg,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: name,
                  children: [
                    if (role != null)
                      TextSpan(
                        text: '  ($role)',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
                style: AppTextStyles.titleLg,
              ),
              if (phone != null)
                Text(
                  phone!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ...actions,
      ],
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.entry, required this.last});

  final MaintenanceLogEntry entry;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final current = entry.current;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: current
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.surfaceContainerHigh,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: AppTextStyles.labelLg.copyWith(
                            color: current
                                ? AppColors.secondary
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        entry.time,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.note,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurface,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.by,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
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
