import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/rent_tab.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

enum _MethodFilter {
  all('All', null),
  upi('UPI', PaymentMethod.upi),
  bank('Bank Transfer', PaymentMethod.bankTransfer),
  cash('Cash', PaymentMethod.cash);

  const _MethodFilter(this.label, this.method);

  final String label;
  final PaymentMethod? method;

  bool matches(RentPayment p) => method == null || p.method == method;
}

/// 27. Payment History — static October 2024 payments.
class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key, required this.onOpenSection});

  final ValueChanged<RentSection> onOpenSection;

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  final _search = TextEditingController();
  _MethodFilter _filter = _MethodFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(RentPayment p) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    final r = p.record;
    return [
      r.tenantName,
      r.property.name,
      r.unitLabel,
      p.receiptNo,
    ].any((s) => s.toLowerCase().contains(q));
  }

  void _reset() => setState(() {
    _search.clear();
    _filter = _MethodFilter.all;
  });

  @override
  Widget build(BuildContext context) {
    final payments = RentMockData.payments;
    final visible = payments
        .where((p) => _filter.matches(p) && _matchesQuery(p))
        .toList();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BackToOverviewButton(
            onPressed: () => widget.onOpenSection(RentSection.overview),
          ),
        ),
        const SizedBox(height: 12),
        const _InflowCard(),
        const SizedBox(height: 12),
        RentSearchField(
          controller: _search,
          hintText: 'Search tenant, unit, or receipt #...',
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final f in _MethodFilter.values) ...[
                RentFilterChip(
                  label: f.label,
                  count: payments.where(f.matches).length,
                  selected: f == _filter,
                  onTap: () => setState(() => _filter = f),
                ),
                const SizedBox(width: 8),
              ],
              // Only the October 2024 mock month exists.
              PopupMenuButton<String>(
                tooltip: 'Month',
                initialValue: RentMockData.cycleShort,
                color: AppColors.surfaceContainerLowest,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: RentMockData.cycleShort,
                    child: Text(RentMockData.cycleShort),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        RentMockData.cycleShort,
                        style: AppTextStyles.labelLg,
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Recent Receipts', style: AppTextStyles.headlineSm),
            const SizedBox(width: 8),
            RentTag('${visible.length} displayed'),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          _NoReceipts(onReset: _reset)
        else
          for (final (i, p) in visible.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            _ReceiptCard(payment: p),
          ],
        const SizedBox(height: 16),
        Text(
          'Showing ${visible.length} of ${payments.length} recorded '
          'transactions',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InflowCard extends StatelessWidget {
  const _InflowCard();

  @override
  Widget build(BuildContext context) {
    final soft = AppTextStyles.bodySm.copyWith(
      color: AppColors.onPrimaryContainer,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -16,
            child: Icon(
              Icons.receipt_long,
              size: 120,
              color: AppColors.onPrimary.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: AppColors.primaryFixedDim,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RentCaption(
                        'Gross Inflow',
                        color: AppColors.primaryFixedDim,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const StatusDot(color: AppColors.secondaryFixedDim),
                          const SizedBox(width: 6),
                          Text(
                            RentMockData.cycleShort,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    Text(
                      RentMockData.collected,
                      style: AppTextStyles.headlineLgMobile.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Collected',
                        style: AppTextStyles.labelLg.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: RentMockData.collectedFraction,
                    minHeight: 6,
                    backgroundColor: AppColors.onPrimary.withValues(
                      alpha: 0.15,
                    ),
                    color: AppColors.secondaryFixedDim,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '92% of total expected (${RentMockData.expected})',
                        style: soft,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      RentMockData.unitsCleared,
                      style: soft.copyWith(color: AppColors.secondaryFixed),
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

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.payment});

  final RentPayment payment;

  @override
  Widget build(BuildContext context) {
    final record = payment.record;
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.all(14),
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
              TenantAvatar(
                initials: record.initials,
                size: 40,
                textStyle: AppTextStyles.labelLg,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.tenantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLg,
                    ),
                    Text(
                      record.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.amount,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: payment.partial
                          ? AppColors.onSurface
                          : AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(payment.date, style: muted),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                RentTag(
                  payment.method.label,
                  icon: payment.method.icon,
                  background: payment.method == PaymentMethod.upi
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainerHigh,
                  color: payment.method == PaymentMethod.upi
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurface,
                ),
                if (payment.partial)
                  const RentTag(
                    'Partial Payment',
                    icon: Icons.pie_chart_outline,
                    background: AppColors.tertiaryFixed,
                    color: AppColors.onTertiaryFixedVariant,
                  )
                else
                  Text('Rent: ${RentMockData.cycleShort}', style: muted),
                Text(
                  payment.receiptNo,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: payment.partial
                    ? Text(
                        'Balance due: ${payment.balanceAfter}',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () =>
                              AppRoutes.openRentDetails(context, record),
                          child: Text(
                            'Rent Details',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                width: 176,
                child: AppButton(
                  label: 'View Receipt',
                  trailingIcon: Icons.arrow_forward,
                  iconSize: 16,
                  height: 36,
                  radius: 8,
                  backgroundColor: AppColors.surfaceContainer,
                  foregroundColor: AppColors.onSurface,
                  textStyle: AppTextStyles.labelLg,
                  shadows: const [],
                  onPressed: () => AppRoutes.openReceipt(context, payment),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoReceipts extends StatelessWidget {
  const _NoReceipts({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
          const SizedBox(height: 12),
          Text('No Receipts Found', style: AppTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(
            "We couldn't match any transaction with your current search "
            'query or active filter.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Reset Search & Filters',
            height: 44,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
