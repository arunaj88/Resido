import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// 24. Rent Details — one rent record with its balance and payments.
class RentDetailsScreen extends StatelessWidget {
  const RentDetailsScreen({super.key, required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final tenancyTenant = record.tenant?.tenancy == null ? null : record.tenant;

    return Scaffold(
      appBar: const SubPageTopBar(title: 'Rent Details', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _HeaderCard(record: record),
          const SizedBox(height: 16),
          _BalanceCard(record: record),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Transactions',
                  style: AppTextStyles.headlineSm,
                ),
              ),
              RentTag('${record.payments.length} Recorded'),
            ],
          ),
          const SizedBox(height: 10),
          if (record.payments.isEmpty)
            AppCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No payments recorded for this period yet.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final (i, p) in record.payments.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              _TransactionCard(payment: p),
            ],
          const SizedBox(height: 20),
          if (status == RentStatus.partiallyPaid)
            AppButton(
              label: 'Record Partial Payment',
              leadingIcon: Icons.add_circle_outline,
              shadows: AppShadows.md,
              onPressed: () => AppRoutes.openPartialPayment(context, record),
            )
          else if (status != RentStatus.paid)
            AppButton(
              label: 'Record Payment (${record.remaining})',
              leadingIcon: Icons.add_circle_outline,
              shadows: AppShadows.md,
              onPressed: () => AppRoutes.openRecordPayment(context, record),
            ),
          if (tenancyTenant != null) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'View Tenancy Terms & Agreement',
              leadingIcon: Icons.description_outlined,
              height: 48,
              backgroundColor: AppColors.surfaceContainerLow,
              foregroundColor: AppColors.onSurface,
              textStyle: AppTextStyles.labelLg,
              shadows: const [],
              onPressed: () =>
                  AppRoutes.openTenancyDetails(context, tenancyTenant),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TenantAvatar(initials: record.initials, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.tenantName, style: AppTextStyles.headlineMd),
                    Text(
                      '${record.unitLabel} · ${record.property.name}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RentStatusChip(
                status: status,
                label: status == RentStatus.overdue ? 'Overdue (4D)' : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    record.property.shortLocality,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(record.period, style: AppTextStyles.labelLg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    final status = record.status;
    final outstandingColor = switch (status) {
      RentStatus.overdue => AppColors.error,
      RentStatus.partiallyPaid => AppColors.tertiaryFixedDim,
      _ => AppColors.surfaceContainerHighest,
    };
    final (pendingTint, pendingFg) = rentStatusColors(status);
    final muted = AppTextStyles.labelMd.copyWith(
      color: AppColors.onSurfaceVariant,
    );

    Widget tile(String label, String amount, String note, Color bg, Color fg) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: muted.copyWith(color: fg)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(note, style: muted.copyWith(color: fg)),
              ],
            ),
          ),
        );

    final (dueTitle, dueIcon) = switch (status) {
      RentStatus.paid => (
        'Rent settled for ${record.period}',
        Icons.event_available,
      ),
      RentStatus.upcoming => (
        'Rent is due on ${record.dueDate}',
        Icons.event_outlined,
      ),
      _ => ('Rent was due on ${record.dueDate}', Icons.event_busy),
    };

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: RentCaption('Balance Breakdown')),
              const RentTag('INR (₹)'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              tile(
                'Total Rent',
                record.rent,
                'Base rental',
                AppColors.surfaceContainerLow,
                AppColors.onSurface,
              ),
              const SizedBox(width: 8),
              tile(
                'Paid So Far',
                record.paid,
                record.paidPercent,
                AppColors.surfaceContainerLow,
                AppColors.secondary,
              ),
              const SizedBox(width: 8),
              tile(
                'Pending',
                record.remaining,
                status == RentStatus.paid ? 'Settled' : status.label,
                status == RentStatus.paid
                    ? AppColors.surfaceContainerLow
                    : pendingTint.withValues(alpha: 0.6),
                status == RentStatus.paid ? AppColors.onSurface : pendingFg,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SplitProgressBar(
            fraction: record.paidFraction,
            restColor: outstandingColor,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Legend(
                  color: AppColors.secondary,
                  text: 'Settled (${record.paid})',
                ),
              ),
              _Legend(
                color: outstandingColor,
                text: 'Outstanding (${record.remaining})',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  dueIcon,
                  size: 20,
                  color: status == RentStatus.overdue
                      ? AppColors.error
                      : AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dueTitle, style: AppTextStyles.titleLg),
                      if (record.dueNote.isNotEmpty)
                        Text(
                          record.dueNote,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
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

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.payment});

  final RentPayment payment;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.labelMd.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 22,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          payment.amount,
                          style: AppTextStyles.headlineMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        RentTag(
                          payment.partial ? 'Part Payment' : 'Full Payment',
                        ),
                      ],
                    ),
                    Text(
                      '${payment.date} · ${payment.time}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gateway / Channel', style: muted),
                      Text(payment.channel, style: AppTextStyles.labelLg),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reference ID', style: muted),
                      Text(
                        payment.reference,
                        style: AppTextStyles.labelLg.copyWith(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Receipt ${payment.receiptNo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ),
              TextButton(
                onPressed: () => AppRoutes.openReceipt(context, payment),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Receipt',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.secondary,
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
