import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/features/notifications/data/notifications_mock_data.dart';



/// One notification: tinted icon tile, title with unread dot, two-line
/// body, time + status line and an optional action chip.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.unread,
    required this.onTap,
    this.onAction,
  });

  final MockNotification item;
  final bool unread;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final (tileBg, tileFg, icon, statusColor) = switch (item.tone) {
      NotificationTone.critical => (
          AppColors.tertiaryFixed,
          AppColors.tertiary,
          Icons.warning_amber,
          AppColors.error,
        ),
      NotificationTone.success => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
          Icons.check_circle_outline,
          AppColors.secondary,
        ),
      NotificationTone.info => (
          AppColors.surfaceContainerHigh,
          AppColors.primaryContainer,
          Icons.plumbing,
          AppColors.onSurface,
        ),
      NotificationTone.upcoming => (
          AppColors.surfaceContainer,
          AppColors.secondary,
          Icons.event_outlined,
          AppColors.tertiaryContainer,
        ),
      NotificationTone.compliant => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
          Icons.verified_user_outlined,
          AppColors.secondary,
        ),
    };

    final meta = AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant);

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: tileFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleLg,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 4),
                          Container(
                            key: const ValueKey('unread-dot'),
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(item.timeAgo, style: meta),
                        const SizedBox(width: 4),
                        Text('•', style: meta),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.statusLabel.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSm.copyWith(
                              color: statusColor,
                              letterSpacing: 0.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.action != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _ActionChip(action: item.action!, onTap: onAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action, this.onTap});

  final NotificationAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (action) {
      NotificationAction.whatsAppReminder => (
          AppColors.secondaryFixed,
          AppColors.onSecondaryFixed,
          Icons.chat_outlined,
          'Send WhatsApp Reminder',
        ),
      NotificationAction.viewReceipt => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurface,
          Icons.receipt_long_outlined,
          'View Receipt',
        ),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.labelLg.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
