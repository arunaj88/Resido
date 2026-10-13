import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/widgets/rent_widgets.dart';

/// Arguments for [AppRoutes.receipt].
class ReceiptArgs {
  const ReceiptArgs({required this.payment, this.preview = false});

  final RentPayment payment;

  /// Shown after Record / Partial Payment: a labelled, unsaved preview.
  final bool preview;
}

/// 28. Receipt — landlord-recorded payment receipt (mock data). No download,
/// print or sharing.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.args});

  final ReceiptArgs args;

  void _done(BuildContext context) => Navigator.of(
    context,
  ).popUntil((r) => r.settings.name == AppRoutes.home || r.isFirst);

  @override
  Widget build(BuildContext context) {
    final payment = args.payment;
    final record = payment.record;
    final settled = payment.balanceAfter == '₹0.00';

    return Scaffold(
      appBar: const SubPageTopBar(title: 'Payment Receipt', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          if (args.preview)
            const PreviewNotice(
              message:
                  'This receipt layout shows how the entry would look. The '
                  'payment has not been saved.',
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Landlord-recorded entry',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ReceiptHeading(payment: payment, preview: args.preview),
                      const SizedBox(height: 16),
                      _PropertyBanner(record: record),
                      const SizedBox(height: 16),
                      _InfoGrid(payment: payment, record: record),
                      const SizedBox(height: 16),
                      const RentCaption('Financial Breakdown'),
                      const SizedBox(height: 8),
                      _Breakdown(
                        payment: payment,
                        record: record,
                        settled: settled,
                      ),
                      const SizedBox(height: 16),
                      const _DashedDivider(),
                      const SizedBox(height: 16),
                      _Declaration(payment: payment, preview: args.preview),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Done · Return to Rent',
            leadingIcon: Icons.arrow_back,
            height: 48,
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.labelLg,
            shadows: const [],
            onPressed: () => _done(context),
          ),
        ],
      ),
    );
  }
}

class _ReceiptHeading extends StatelessWidget {
  const _ReceiptHeading({required this.payment, required this.preview});

  final RentPayment payment;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.domain_verification,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RentCaption(
                      'Resido Kerala · Landlord Record',
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('RENT PAYMENT RECEIPT', style: AppTextStyles.headlineSm),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'VOUCHER ID',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  RentTag(
                    payment.receiptNo,
                    background: AppColors.surfaceContainer,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: preview ? AppColors.tertiaryFixed : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                preview ? Icons.visibility_outlined : Icons.check_circle,
                size: 22,
                color: preview
                    ? AppColors.onTertiaryFixedVariant
                    : AppColors.secondaryFixed,
              ),
              const SizedBox(height: 2),
              Text(
                preview ? 'PREVIEW' : 'RECORDED',
                style: AppTextStyles.labelSm.copyWith(
                  color: preview
                      ? AppColors.onTertiaryFixedVariant
                      : AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PropertyBanner extends StatelessWidget {
  const _PropertyBanner({required this.record});

  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    final image = record.property.cardImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(image, fit: BoxFit.cover)
            else
              const ColoredBox(color: AppColors.primaryContainer),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  const Icon(
                    Icons.apartment,
                    size: 18,
                    color: AppColors.secondaryFixed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
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

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.payment, required this.record});

  final RentPayment payment;
  final RentRecord record;

  @override
  Widget build(BuildContext context) {
    Widget field(String label, Widget value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [RentCaption(label), const SizedBox(height: 2), value],
    );
    final valueStyle = AppTextStyles.titleLg;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: field(
                  'Payment Date',
                  Text(payment.longDate, style: valueStyle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: field(
                  'Period Covered',
                  Text(record.period, style: valueStyle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          field(
            'Tenant Name',
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(record.tenantName, style: valueStyle)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          field(
            'Premises Location',
            Text(
              '${record.unitLabel}, ${record.property.addressLine}',
              style: AppTextStyles.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.payment,
    required this.record,
    required this.settled,
  });

  final RentPayment payment;
  final RentRecord record;
  final bool settled;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.bodyMd.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: muted)),
          const SizedBox(width: 8),
          Flexible(child: value),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            'Scheduled Rent Obligation',
            Text(
              '${record.rent}.00',
              textAlign: TextAlign.end,
              style: AppTextStyles.titleLg,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: AppColors.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total Amount Received',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
                Text(
                  payment.amount,
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onSecondaryFixedVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          row(
            'Settlement Channel',
            Text(
              payment.channel,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelLg,
            ),
          ),
          row(
            'Transaction Ref / UTR',
            Text(
              payment.reference,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMd.copyWith(letterSpacing: 0.5),
            ),
          ),
          row(
            'Outstanding Balance',
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  payment.balanceAfter,
                  style: AppTextStyles.titleLg.copyWith(
                    color: settled ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                settled
                    ? const RentTag(
                        'SETTLED',
                        background: AppColors.secondaryContainer,
                        color: AppColors.onSecondaryContainer,
                      )
                    : const RentTag(
                        'DUE',
                        background: AppColors.errorContainer,
                        color: AppColors.error,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 10).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++)
              Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: AppColors.outlineVariant,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Declaration extends StatelessWidget {
  const _Declaration({required this.payment, required this.preview});

  final RentPayment payment;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.bodySm.copyWith(color: AppColors.onSurface);
    final bold = body.copyWith(fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.all(12),
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
                Icons.verified_user_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Landlord Declaration',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Recorded by: ', style: bold),
                const TextSpan(text: RentMockData.landlordName),
              ],
            ),
            style: body,
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Recorded on: ', style: bold),
                TextSpan(
                  text: preview
                      ? 'Not saved (preview)'
                      : '${payment.date}, ${payment.time}',
                ),
              ],
            ),
            style: body,
          ),
          const SizedBox(height: 8),
          Text(
            'Landlord-recorded entry for reference. Not a bank-verified '
            'record or tax invoice.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
