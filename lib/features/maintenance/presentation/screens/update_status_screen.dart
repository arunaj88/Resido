import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/widgets/maintenance_widgets.dart';
import 'package:resido/features/rent/presentation/screens/record_payment_screen.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';

/// 32. Update Status — status options and resolution fields. The selection
/// is temporary; "Save Changes" returns without changing the request.
class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key, required this.request});

  final MaintenanceRequest request;

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  late MaintenanceStatus _status = widget.request.status;
  late final _cost = TextEditingController(
    text: widget.request.cost?.replaceAll('₹', '') ?? '',
  );
  late final _notes = TextEditingController(
    text: widget.request.resolution ?? '',
  );
  DateTime _date = DateTime(2024, 10, 24);

  @override
  void dispose() {
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Preview only — the request status was not changed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );

    return Scaffold(
      appBar: const SubPageTopBar(
        title: 'Update Status',
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${r.id} · ${r.property.name}'.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusTag(status: r.status, prefix: 'Current: '),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    MaintenanceIconTile(icon: r.category.icon),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: AppTextStyles.titleLg),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  r.assignee == null
                                      ? 'Not yet assigned'
                                      : 'Assigned to ${r.assignee}'
                                            '${r.assignedSince == null ? '' : ' · ${r.assignedSince}'}',
                                  style: muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Update Work Status', style: AppTextStyles.titleLg),
          const SizedBox(height: 10),
          for (final s in MaintenanceStatus.values) ...[
            _StatusOption(
              status: s,
              selected: s == _status,
              onTap: () => setState(() => _status = s),
            ),
            const SizedBox(height: 10),
          ],
          if (_status == MaintenanceStatus.completed) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text('Resolution Details', style: AppTextStyles.labelLg),
              ],
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Completion Date', style: AppTextStyles.labelLg),
                  const SizedBox(height: 6),
                  RentInputBox(
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    onTap: () async {
                      final picked = await pickRentDate(context, _date);
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Text(
                      rentDateLabel(_date),
                      style: AppTextStyles.bodyLg,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Actual Cost / Expense',
                          style: AppTextStyles.labelLg,
                        ),
                      ),
                      Text('Optional', style: muted),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RentInputBox(
                    leading: Text(
                      '₹',
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    child: TextField(
                      controller: _cost,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: AppTextStyles.bodyLg,
                      decoration: InputDecoration.collapsed(
                        hintText: 'e.g. 1,450',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Resolution & Completion Notes',
                    style: AppTextStyles.labelLg,
                  ),
                  const SizedBox(height: 6),
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
                            'What was repaired or replaced, and how it was '
                            'checked...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Inspection Attachments', style: AppTextStyles.labelLg),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Expanded(child: _InactivePhotoSlot(label: 'Post Repair')),
                      SizedBox(width: 8),
                      Expanded(child: _InactivePhotoSlot(label: 'Bill Slip')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Photo upload is not available in this version.',
                    style: muted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.history,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'In this version, saving is a preview only — the request '
                    'status and activity log are not changed.',
                    style: muted.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save Changes',
            leadingIcon: Icons.save_outlined,
            shadows: AppShadows.md,
            onPressed: _save,
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
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final MaintenanceStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final trailing = switch (status) {
      MaintenanceStatus.open => Icons.hourglass_empty,
      MaintenanceStatus.inProgress => Icons.engineering_outlined,
      MaintenanceStatus.completed => Icons.task_alt,
    };
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          color: selected
              ? AppColors.secondaryContainer.withValues(alpha: 0.45)
              : AppColors.surfaceContainerLowest,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(status.label, style: AppTextStyles.titleLg),
                        Text(
                          status.description,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    trailing,
                    size: 22,
                    color: selected ? AppColors.secondary : AppColors.outline,
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

/// Attachment slot that is shown but inactive (no upload in this version).
class _InactivePhotoSlot extends StatelessWidget {
  const _InactivePhotoSlot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
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
            label,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
