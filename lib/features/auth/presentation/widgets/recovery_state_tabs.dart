import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/features/auth/presentation/screens/recovery_feedback_screen.dart';

/// Segmented switcher across the top of the recovery feedback screen.
class RecoveryStateTabs extends StatelessWidget {
  const RecoveryStateTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RecoveryFeedbackState selected;
  final ValueChanged<RecoveryFeedbackState> onSelected;

  static const _tabs = [
    (
      RecoveryFeedbackState.linkSent,
      Icons.mark_email_read,
      Icons.mark_email_read_outlined,
      'Link Sent',
    ),
    (RecoveryFeedbackState.failed, Icons.error, Icons.error_outline, 'Failed'),
    (
      RecoveryFeedbackState.verifyAccount,
      Icons.mail,
      Icons.mail_outline,
      'Verify Account',
    ),
    (RecoveryFeedbackState.submitting, Icons.sync, Icons.sync, 'Submitting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, tab) in _tabs.indexed) ...[
              if (i > 0) const SizedBox(width: 4),
              // Like the design's flex-1 tabs, a tab never gets narrower
              // than its longest word: "Submitting" keeps its own width.
              if (tab.$1 == RecoveryFeedbackState.submitting)
                _tabFor(tab, fitContent: true)
              else
                Expanded(child: _tabFor(tab)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabFor(
    (RecoveryFeedbackState, IconData, IconData, String) tab, {
    bool fitContent = false,
  }) {
    return _Tab(
      fitContent: fitContent,
      label: tab.$4,
      icon: tab.$1 == selected ? tab.$2 : tab.$3,
      selected: tab.$1 == selected,
      onTap: () => onSelected(tab.$1),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.fitContent = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool fitContent;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: AppTextStyles.labelMd.copyWith(color: color),
    );
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? AppShadows.sm : null,
          ),
          child: Row(
            mainAxisSize: fitContent ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              if (fitContent) text else Flexible(child: text),
            ],
          ),
        ),
      ),
    );
  }
}
