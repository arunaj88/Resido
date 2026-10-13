import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/receipt_screen.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';
import 'package:resido/features/tenants/presentation/widgets/tenant_widgets.dart';

/// "24 Oct 2024".
String rentDateLabel(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} '
      '${d.year}';
}

/// "October 2024" → "Oct 2024".
String shortPeriod(String period) =>
    '${period.substring(0, 3)} ${period.split(' ').last}';

/// Opens the date picker around the mock "today" (24 Oct 2024).
Future<DateTime?> pickRentDate(BuildContext context, DateTime current) =>
    showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025, 12, 31),
    );

/// 25. Record Payment — form layout only. Fields hold temporary values;
/// "Save Payment" opens a static receipt preview and stores nothing.
class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key, required this.record});

  final RentRecord record;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime(2024, 10, 24);
  PaymentMethod _method = PaymentMethod.upi;

  RentRecord get _record => widget.record;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final reference = _reference.text.trim();
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.receipt,
      arguments: ReceiptArgs(
        preview: true,
        payment: RentPayment(
          recordId: _record.id,
          receiptNo: '#REC-PREVIEW',
          amount: '${_record.remaining}.00',
          date: rentDateLabel(_date),
          longDate: rentDateLabel(_date),
          time: '—',
          method: _method,
          channel: _method.label,
          reference: reference.isEmpty ? 'Not provided' : reference,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    return Scaffold(
      appBar: const SubPageTopBar(title: 'Record Payment', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _BalanceHeader(record: _record),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Amount Received',
            required: true,
            trailing: Text(
              'Max: ${_record.remaining}.00',
              style: AppTextStyles.labelMd,
            ),
            children: [
              AmountInputBox(controller: _amount, hint: '0.00'),
              const SizedBox(height: 8),
              Text(
                'Enter the amount received, up to ${_record.remaining}.00.',
                style: muted,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.onSecondaryContainer,
                  ),
                  label: Text(
                    'Pay Full Balance (${_record.remaining})',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: AppColors.secondaryContainer,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  onPressed: () => setState(
                    () => _amount.text = _record.remaining
                        .replaceAll('₹', '')
                        .replaceAll(',', ''),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Payment Date',
            required: true,
            children: [
              RentInputBox(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.secondary,
                ),
                trailing: const Icon(
                  Icons.edit_calendar_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                onTap: () async {
                  final picked = await pickRentDate(context, _date);
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(rentDateLabel(_date), style: AppTextStyles.bodyLg),
              ),
              const SizedBox(height: 8),
              Text('Default set to ${RentMockData.asOfDate}', style: muted),
            ],
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Payment Method',
            required: true,
            trailing: Text(
              'Selected: ${_method.label}',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.secondary),
            ),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.45,
                children: [
                  for (final m in PaymentMethod.values)
                    PaymentMethodTile(
                      icon: m.icon,
                      label: m.label,
                      detail: m.detail,
                      selected: m == _method,
                      onTap: () => setState(() => _method = m),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Transaction Reference',
            trailing: Text('Optional', style: AppTextStyles.labelMd),
            children: [
              RentInputBox(
                leading: const Icon(
                  Icons.pin_outlined,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                child: TextField(
                  controller: _reference,
                  style: AppTextStyles.bodyLg,
                  decoration: InputDecoration.collapsed(
                    hintText: 'e.g. UPI Ref / Bank UTR Number',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional 12-digit UPI UTR or bank transaction reference',
                style: muted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Internal Landlord Notes',
            trailing: Text('Private', style: AppTextStyles.labelMd),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _notes,
                  minLines: 3,
                  maxLines: null,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)],
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Add memo or payment verification details...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Private note for your records.', style: muted),
            ],
          ),
          const SizedBox(height: 16),
          const ManualRecordDeclaration(),
          const SizedBox(height: 20),
          AppButton(
            label: 'Save Payment',
            leadingIcon: Icons.check,
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

/// Note that Resido does not process payments and nothing is saved here.
class ManualRecordDeclaration extends StatelessWidget {
  const ManualRecordDeclaration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 18,
              color: AppColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manual Record Declaration', style: AppTextStyles.labelLg),
                const SizedBox(height: 2),
                Text(
                  'Resido does not process or verify bank transactions. In '
                  'this version the payment is not saved — saving shows a '
                  'receipt preview only.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
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

/// ₹ amount box used by Record and Partial Payment.
class AmountInputBox extends StatelessWidget {
  const AmountInputBox({
    super.key,
    required this.controller,
    this.hint = '0',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '₹',
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(12),
              ],
              style: AppTextStyles.headlineLgMobile,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: AppTextStyles.headlineLgMobile.copyWith(
                  color: AppColors.outlineVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
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
                        'ACTIVE LEASE',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.secondaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Billing Period: ${shortPeriod(record.period)}',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TenantAvatar(
                  initials: record.initials,
                  size: 48,
                  background: AppColors.primaryFixed,
                  color: AppColors.primary,
                  textStyle: AppTextStyles.titleLg,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.tenantName,
                        style: AppTextStyles.headlineMd.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      Text(
                        record.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RentCaption(
                          'Outstanding Balance',
                          color: AppColors.primaryFixedDim,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${record.remaining}.00',
                            style: AppTextStyles.headlineLgMobile.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  RentTag(
                    'Due ${record.dueDate.substring(0, 6)}',
                    background: AppColors.errorContainer,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White form section with a title row.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.children,
    this.required = false,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final bool required;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: title,
                    children: [
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: AppColors.error),
                        ),
                    ],
                  ),
                  style: AppTextStyles.headlineSm,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
