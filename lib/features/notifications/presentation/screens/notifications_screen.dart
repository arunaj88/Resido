import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/notifications/data/notifications_mock_data.dart';
import 'package:resido/features/notifications/presentation/widgets/notification_card.dart';

enum _Filter {
  all('All', null),
  rent('Rent Dues', NotificationCategory.rent),
  maintenance('Maintenance', NotificationCategory.maintenance),
  system('System', NotificationCategory.system);

  const _Filter(this.label, this.category);

  final String label;
  final NotificationCategory? category;

  bool matches(MockNotification n) =>
      category == null || n.category == category;
}

/// 08. Notifications. Read state and filters are local UI state only; no
/// notification service or persistence is involved.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _items = NotificationsMockData.items;
  final _read = <String>{};
  _Filter _filter = _Filter.all;
  bool _showEmptyPreview = false;

  bool _isUnread(MockNotification n) => n.unread && !_read.contains(n.id);

  int get _unreadCount => _items.where(_isUnread).length;

  void _markAllRead() => setState(() => _read.addAll(_items.map((n) => n.id)));

  void _open(MockNotification n) {
    setState(() => _read.add(n.id));
    if (n.category == NotificationCategory.maintenance) {
      Navigator.of(context).pushNamed(AppRoutes.maintenance);
      return;
    }
    final (title, icon) = switch (n.category) {
      NotificationCategory.rent => ('Rent Details', Icons.currency_rupee),
      NotificationCategory.maintenance => (
        'Maintenance Request',
        Icons.build_outlined,
      ),
      NotificationCategory.system => ('Tenant Details', Icons.group_outlined),
    };
    AppRoutes.openComingSoon(context, title, icon);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where(_filter.matches).toList();
    final today = visible
        .where((n) => n.section == NotificationSection.today)
        .toList();
    final earlier = visible
        .where((n) => n.section == NotificationSection.earlierThisWeek)
        .toList();

    return Scaffold(
      appBar: const _NotificationsTopBar(),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 16,
        ),
        children: [
          _UnreadBar(
            unread: _unreadCount,
            onMarkAllRead: _unreadCount == 0 ? null : _markAllRead,
          ),
          _FilterPills(
            selected: _filter,
            counts: {
              for (final f in _Filter.values) f: _items.where(f.matches).length,
            },
            onSelected: (f) => setState(() => _filter = f),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (today.isNotEmpty) ...[
                  _Section(
                    title: 'Today',
                    showDot: true,
                    items: today,
                    isUnread: _isUnread,
                    onOpen: _open,
                  ),
                  const SizedBox(height: 24),
                ],
                if (earlier.isNotEmpty) ...[
                  _Section(
                    title: 'Earlier This Week',
                    items: earlier,
                    isUnread: _isUnread,
                    onOpen: _open,
                  ),
                  const SizedBox(height: 24),
                ],
                _EmptyStatePreview(
                  expanded: _showEmptyPreview,
                  onToggle: () =>
                      setState(() => _showEmptyPreview = !_showEmptyPreview),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationsTopBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x0A064E3B),
            offset: Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: ColoredBox(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: IconButton(
                          tooltip: 'Back',
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifications',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleLg.copyWith(
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBar extends StatelessWidget {
  const _UnreadBar({required this.unread, required this.onMarkAllRead});

  final int unread;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final done = onMarkAllRead == null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$unread',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.onPrimary),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text('Unread alerts', style: AppTextStyles.labelLg)),
          TextButton(
            onPressed: onMarkAllRead,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              done ? 'All Caught Up' : 'Mark all as read',
              style: AppTextStyles.labelLg.copyWith(
                color: done ? AppColors.secondary : AppColors.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final _Filter selected;
  final Map<_Filter, int> counts;
  final ValueChanged<_Filter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          for (final (i, f) in _Filter.values.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            _Pill(
              label: f.label,
              count: counts[f] ?? 0,
              selected: f == selected,
              onTap: () => onSelected(f),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected ? AppShadows.sm : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.labelLg.copyWith(color: fg)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.secondary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSm.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.isUnread,
    required this.onOpen,
    this.showDot = false,
  });

  final String title;
  final List<MockNotification> items;
  final bool Function(MockNotification) isUnread;
  final ValueChanged<MockNotification> onOpen;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyles.titleLg),
            if (showDot) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const Spacer(),
            Text(
              '${items.length} ${items.length == 1 ? 'update' : 'updates'}',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (i, item) in items.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          NotificationCard(
            item: item,
            unread: isUnread(item),
            onTap: () => onOpen(item),
            // WhatsApp needs an external service: shown, no effect yet.
            onAction: item.action == NotificationAction.viewReceipt
                ? () => AppRoutes.openComingSoon(
                    context,
                    'Receipt',
                    Icons.receipt_long_outlined,
                  )
                : null,
          ),
        ],
      ],
    );
  }
}

/// The design's "Inbox Status Preview" drawer with the empty state card.
class _EmptyStatePreview extends StatelessWidget {
  const _EmptyStatePreview({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                Icons.spa_outlined,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Inbox Status Preview',
                  style: AppTextStyles.labelLg,
                ),
              ),
              Material(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(999),
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Text(
                      expanded ? 'Hide Preview' : 'Preview Empty State',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      size: 40,
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Column(
                      children: [
                        Text(
                          'All Caught Up!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineSm,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "No new notifications. You're completely up to date "
                          'with your properties and rent collections.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Kerala State RERA Compliant Logs',
                            style: AppTextStyles.labelSm.copyWith(
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
        ],
      ),
    );
  }
}
