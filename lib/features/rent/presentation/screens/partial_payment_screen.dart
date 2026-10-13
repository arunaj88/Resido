import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/receipt_screen.dart';
import 'package:resido/features/rent/presentation/screens/record_payment_screen.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';

/// 26. Partial Payment — layout only. The balance preview shows the static
/// ₹3,000 example from the design; nothing is calculated or saved.
class PartialPaymentScreen extends StatefulWidget {
  const PartialPaymentScreen({super.key, required this.record});

  final RentRecord record;

  static const presets = ['2,000', '3,000', '5,000'];

  @override
  State<PartialPaymentScreen> createState() => _PartialPaymentScreenState();
}

enum _Method {
  upi(
    'UPI',
    'Instant',
    Icons.account_balance_wallet_outlined,
    PaymentMethod.upi,
  ),
  bank(
    'NEFT/IMPS',
    'Direct',
    Icons.account_balance,
    PaymentMethod.bankTransfer,
  ),
  cash('Cash', 'Hand', Icons.payments_outlined, PaymentMethod.cash);

  const _Method(this.label, this.detail, this.icon, this.method);

  final String label;
  final String detail;
  final IconData icon;
  final PaymentMethod method;
}

class _PartialPaymentScreenState extends State<PartialPaymentScreen> {
  final _amount = TextEditingController(text: '3,000');
  final _reference = TextEditingController();
  DateTime _date = DateTime(2024, 10, 24);
  _Method _method = _Method.upi;

  RentRecord get _record => widget.record;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  void _save() {
    const example = RentMockData.partialPreview;
    final reference = _reference.text.trim();
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.receipt,
      arguments: ReceiptArgs(
        preview: true,
        payment: RentPayment(
          recordId: _record.id,
          receiptNo: example.receiptNo,
          amount: example.amount,
          date: rentDateLabel(_date),
          longDate: rentDateLabel(_date),
          time: '—',
          method: _method.method,
          channel: '${_method.label} ${_method.detail}',
          reference: reference.isEmpty ? 'Not provided' : reference,
          partial: true,
          balanceAfter: example.balanceAfter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prevPaid = _record.payments.isEmpty ? null : _record.payments.first;
    final fullPreset = _record.remaining.replaceAll('₹', '');
    final label = AppTextStyles.titleLg;

    return Scaffold(
      appBar: const SubPageTopBar(title: 'Partial Payment', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _TenantHeader(record: _record),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Rent Ledger Breakdown',
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                    const RentTag(
                      'Cycle 10/24',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _LedgerBar(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _LedgerTile(
                      label: 'Monthly Rent',
                      amount: '${_record.rent}.00',
                      background: AppColors.surfaceContainerLow,
                      color: AppColors.onSurface,
                    ),
                    const SizedBox(width: 8),
                    _LedgerTile(
                      label: 'Prev. Paid',
                      amount: '${_record.paid}.00',
                      note: prevPaid?.date.substring(0, 6),
                      background: AppColors.surfaceContainerLow,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _LedgerTile(
                      label: 'Current Due',
                      amount: '${_record.remaining}.00',
                      background: AppColors.errorContainer.withValues(
                        alpha: 0.6,
                      ),
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Amount Received', style: label)),
                    const RentTag(
                      'Partial Allocation',
                      icon: Icons.tune,
                      background: AppColors.tertiaryFixed,
                      color: AppColors.onTertiaryFixedVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AmountInputBox(
                  controller: _amount,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Presets:',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    for (final p in PartialPaymentScreen.presets)
                      _PresetChip(
                        label: '₹$p',
                        selected: _amount.text == p,
                        onTap: () => setState(() => _amount.text = p),
                      ),
                    _PresetChip(
                      label: 'Full (${_record.remaining})',
                      selected: _amount.text == fullPreset,
                      onTap: () => setState(() => _amount.text = fullPreset),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Payment Date', style: label),
                const SizedBox(height: 8),
                RentInputBox(
                  trailing: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
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
                Text('Payment Method', style: label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final (i, m) in _Method.values.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: PaymentMethodTile(
                          compact: true,
                          icon: m.icon,
                          label: m.label,
                          detail: m.detail,
                          selected: m == _method,
                          onTap: () => setState(() => _method = m),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Text('Transaction Reference', style: label),
                const SizedBox(height: 8),
                RentInputBox(
                  child: TextField(
                    controller: _reference,
                    style: AppTextStyles.bodyLg.copyWith(letterSpacing: 0.5),
                    decoration: InputDecoration.collapsed(
                      hintText: 'UPI-0192837465',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Optional UPI or bank reference',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _BalancePreview(record: _record, prevPaidDate: prevPaid?.date),
          const SizedBox(height: 20),
          AppButton(
            label:
                'Save Partial Payment (${RentMockData.partialPreview.amount})',
            leadingIcon: Icons.task_alt,
            shadows: AppShadows.md,
            onPressed: _save,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancel',
            height: 44,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.secondary,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

class _TenantHeader extends StatelessWidget {
  const _TenantHeader({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(record.tenantName, style: AppTextStyles.titleLg),
                    const RentTag('TENANT'),
                  ],
                ),
                Text(
                  record.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const RentCaption('Billing Period'),
              Text(
                shortPeriod(record.period),
                style: AppTextStyles.headlineSm.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paid / example payment / remaining bar, fixed to the design's example.
class _LedgerBar extends StatelessWidget {
  const _LedgerBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: const SizedBox(
        height: 10,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 4, child: ColoredBox(color: AppColors.secondary)),
            Expanded(
              flex: 3,
              child: ColoredBox(color: AppColors.tertiaryFixedDim),
            ),
            Expanded(
              flex: 5,
              child: ColoredBox(color: AppColors.surfaceContainerHighest),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({
    required this.label,
    required this.amount,
    required this.background,
    required this.color,
    this.note,
  });

  final String label;
  final String amount;
  final String? note;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: AppTextStyles.titleLg.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (note != null)
              Text(
                note!,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppColors.secondaryContainer
            : AppColors.surfaceContainer,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: selected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalancePreview extends StatelessWidget {
  const _BalancePreview({required this.record, this.prevPaidDate});

  final RentRecord record;
  final String? prevPaidDate;

  @override
  Widget build(BuildContext context) {
    const example = RentMockData.partialPreview;
    final muted = AppTextStyles.bodyMd.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    Widget row(String label, String value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style ?? muted)),
          Text(
            value,
            style: (style ?? AppTextStyles.bodyMd).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final since = prevPaidDate == null
        ? ''
        : ' (${prevPaidDate!.substring(0, 6)})';
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color: AppColors.secondary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Updated Balance Preview',
                  style: AppTextStyles.headlineSm,
                ),
              ),
              const RentStatusChip(status: RentStatus.partiallyPaid),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Shown for the ${example.amount} example.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                row('Gross Monthly Rent', '${record.rent}.00'),
                row('Less: Previously Paid$since', '- ${record.paid}.00'),
                row(
                  'Prior Outstanding Balance',
                  '${record.remaining}.00',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                row(
                  'Less: New Payment Received',
                  '- ${example.amount}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const Divider(color: AppColors.surfaceContainerHighest),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Outstanding Remaining',
                        style: AppTextStyles.titleLg,
                      ),
                    ),
                    Text(
                      example.balanceAfter,
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: This rent would stay Partially Paid with '
                    '${example.balanceAfter} still due before '
                    '${record.dueDate.substring(0, 6)}.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurface,
                      height: 1.4,
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
