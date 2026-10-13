import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/sub_page_top_bar.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/widgets/unit_visuals.dart';

/// 12. Property Details for the selected mock property.
class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key, required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SubPageTopBar(title: 'Property Details', showMore: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.paddingOf(context).bottom + 40,
        ),
        children: [
          _Hero(property: property),
          const SizedBox(height: 12),
          _Identity(property: property),
          const SizedBox(height: 16),
          _Metrics(property: property),
          const SizedBox(height: 8),
          _YieldCard(property: property),
          const SizedBox(height: 24),
          _UnitsSection(property: property),
          const SizedBox(height: 24),
          _Specifications(property: property),
          const SizedBox(height: 36),
          _DeleteGuard(property: property),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final image = property.heroImage ?? property.cardImage;
    return Container(
      height: 256,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.md,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.asset(image, fit: BoxFit.cover)
          else
            Center(
              child: Icon(
                property.icon,
                size: 72,
                color: AppColors.primaryContainer,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _Frosted(
                    radius: 999,
                    opacity: 0.95,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.apartment,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            property.typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _VacancyPill(property: property),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: ${property.registryId}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
                if (property.verifiedTitle) ...[
                  const SizedBox(width: 8),
                  _Frosted(
                    radius: 6,
                    opacity: 0.8,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text('Verified Title', style: AppTextStyles.labelSm),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Frosted extends StatelessWidget {
  const _Frosted({
    required this.child,
    required this.radius,
    required this.opacity,
    required this.padding,
  });

  final Widget child;
  final double radius;
  final double opacity;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          color: AppColors.surfaceContainerLowest.withValues(alpha: opacity),
          child: child,
        ),
      ),
    );
  }
}

class _VacancyPill extends StatelessWidget {
  const _VacancyPill({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final vacant = property.hasVacancies;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: vacant ? AppColors.tertiaryFixed : AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(
            color: vacant ? AppColors.onTertiaryContainer : AppColors.secondary,
            size: 6,
            pulsing: vacant,
          ),
          const SizedBox(width: 4),
          Text(
            vacant
                ? '${property.vacantCount} '
                      '${property.vacantCount == 1 ? 'Vacancy' : 'Vacancies'}'
                : '100% Occupied',
            style: AppTextStyles.labelMd.copyWith(
              color: vacant
                  ? AppColors.onTertiaryFixed
                  : AppColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    Widget square(IconData icon, String tooltip, {bool dot = false}) =>
        SizedBox(
          width: 44,
          height: 44,
          child: Material(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              // Documents / sharing are not designed yet: display only.
              onTap: () {},
              child: Tooltip(
                message: tooltip,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
                    if (dot)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.name,
          style: AppTextStyles.headlineMd.copyWith(letterSpacing: -0.55),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.addressLine,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: Material(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => AppRoutes.openEditProperty(context, property),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Property',
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            square(Icons.folder_open_outlined, 'Property Documents', dot: true),
            const SizedBox(width: 8),
            square(Icons.share_outlined, 'Share Property Details'),
          ],
        ),
      ],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final total = property.units.length;
    final occupied = property.occupiedCount;
    final activePercent = total == 0 ? 0 : (occupied * 100 / total).round();

    Widget tile({
      required Color background,
      required String label,
      required Color labelColor,
      required String value,
      required Color valueColor,
      required Widget footer,
    }) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: labelColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.currencyDisplayMobile.copyWith(
                color: valueColor,
              ),
            ),
            footer,
          ],
        ),
      ),
    );

    final small = AppTextStyles.labelSm;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile(
            background: AppColors.surfaceContainerLowest,
            label: 'Units',
            labelColor: AppColors.onSurfaceVariant,
            value: '$total',
            valueColor: AppColors.onSurface,
            footer: Text(
              'Total',
              style: small.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 4),
          tile(
            background: AppColors.secondaryContainer.withValues(alpha: 0.2),
            label: 'Occupied',
            labelColor: AppColors.secondary,
            value: '$occupied',
            valueColor: AppColors.secondary,
            footer: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StatusDot(color: AppColors.secondary, size: 6),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '$activePercent% Active',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: small.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          tile(
            background: AppColors.tertiaryFixed.withValues(alpha: 0.3),
            label: 'Vacant',
            labelColor: AppColors.onTertiaryContainer,
            value: '${property.vacantCount}',
            valueColor: AppColors.onTertiaryContainer,
            footer: Text(
              property.hasVacancies ? 'Ready to lease' : 'Fully let',
              style: small.copyWith(color: AppColors.onTertiaryFixedVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _YieldCard extends StatelessWidget {
  const _YieldCard({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    final label = AppTextStyles.bodySm.copyWith(
      color: AppColors.onSurfaceVariant,
    );
    Widget legend(Color dot, String name, int amount, Color amountColor) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatusDot(color: dot, size: 10),
        const SizedBox(width: 6),
        Text('$name:', style: label),
        const SizedBox(width: 6),
        Text(
          InrFormat.full(amount),
          style: AppTextStyles.titleLg.copyWith(color: amountColor),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Est. Monthly Yield',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                InrFormat.full(property.monthlyYield),
                style: AppTextStyles.currencyDisplayMobile.copyWith(
                  color: AppColors.primary,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (property.received > 0)
                    Expanded(
                      flex: property.received,
                      child: const ColoredBox(color: AppColors.secondary),
                    ),
                  if (property.pending > 0)
                    Expanded(
                      flex: property.pending,
                      child: const ColoredBox(
                        color: AppColors.tertiaryFixedDim,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              legend(
                AppColors.secondary,
                'Received',
                property.received,
                AppColors.secondary,
              ),
              legend(
                AppColors.tertiaryFixedDim,
                'Pending',
                property.pending,
                AppColors.onTertiaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitsSection extends StatelessWidget {
  const _UnitsSection({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Units', style: AppTextStyles.titleLg),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${property.units.length}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => AppRoutes.openUnitList(context, property),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Units',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: Material(
            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => AppRoutes.openUnitForm(context, property),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Unit',
                    style: AppTextStyles.titleLg.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final (i, unit) in property.units.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          _UnitSummaryCard(
            unit: unit,
            onTap: () => AppRoutes.openUnitForm(context, property, unit: unit),
          ),
        ],
      ],
    );
  }
}

class _UnitSummaryCard extends StatelessWidget {
  const _UnitSummaryCard({required this.unit, required this.onTap});

  final MockUnit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = UnitBadgeStyle.forDetails(unit);
    final ready = unit.condition == UnitCondition.ready;
    final refreshing = unit.condition == UnitCondition.refreshing;
    final occupied = unit.status == UnitStatus.occupied;
    final subtitle = AppTextStyles.bodySm;

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnitNumberTile(
                number: unit.number,
                background: ready
                    ? AppColors.tertiaryFixed.withValues(alpha: 0.4)
                    : AppColors.surfaceContainer,
                color: ready
                    ? AppColors.onTertiaryContainer
                    : refreshing
                    ? AppColors.onSurfaceVariant
                    : AppColors.primary,
                radius: 8,
                textStyle: AppTextStyles.titleLg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(unit.name, style: AppTextStyles.titleLg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            unit.shortFloor,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (occupied)
                      Text.rich(
                        TextSpan(
                          text: 'Tenant: ',
                          children: [
                            TextSpan(
                              text: unit.tenant,
                              style: subtitle.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        style: subtitle.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      )
                    else
                      IconText(
                        icon: ready
                            ? Icons.key_outlined
                            : Icons.format_paint_outlined,
                        text: ready
                            ? 'Ready for Tenant'
                            : 'Painting & Carpentry',
                        color: ready
                            ? AppColors.secondary
                            : AppColors.onTertiaryContainer,
                        iconSize: 14,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(style: status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: switch (unit.condition) {
                  UnitCondition.settled => const IconText(
                    icon: Icons.check_circle_outline,
                    text: 'Oct Rent Settled',
                    color: AppColors.onSurfaceVariant,
                    iconColor: AppColors.secondary,
                    gap: 8,
                  ),
                  UnitCondition.overdue => const IconText(
                    icon: Icons.pending_outlined,
                    text: 'Payment Overdue',
                    color: AppColors.error,
                  ),
                  _ => Text(
                    'Expected Yield',
                    style: subtitle.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                },
              ),
              if (unit.condition == UnitCondition.overdue) ...[
                // Reminders need a messaging service: display only.
                Material(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Send Reminder',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              MonthlyAmount(
                amount: unit.rent,
                color: occupied ? AppColors.primary : AppColors.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Specifications extends StatelessWidget {
  const _Specifications({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    Widget fact(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.labelLg),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Specifications & Details', style: AppTextStyles.titleLg),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                property.description,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: AppTextStyles.relaxed,
                ),
              ),
              const SizedBox(height: 22),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fact('Property Type', property.typeLabel),
                    const SizedBox(width: 12),
                    fact(
                      'District & PIN',
                      '${property.district} - ${property.pinCode}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Key Utilities & Amenities',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (icon, label) in property.amenities)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconText(
                        icon: icon,
                        text: label,
                        color: AppColors.onSurface,
                        iconColor: AppColors.secondary,
                        iconSize: 16,
                        gap: 6,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Delete Property" link with the inline confirmation card. Deleting is
/// not available in the UI-only phase, so confirming only closes the card.
class _DeleteGuard extends StatefulWidget {
  const _DeleteGuard({required this.property});

  final MockProperty property;

  @override
  State<_DeleteGuard> createState() => _DeleteGuardState();
}

class _DeleteGuardState extends State<_DeleteGuard> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    if (!_confirming) {
      return Center(
        child: TextButton.icon(
          onPressed: () => setState(() => _confirming = true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(
            'Delete Property',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
          ),
        ),
      );
    }
    final units = widget.property.units.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 20, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delete ${widget.property.name}?',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This action cannot be undone. All active lease registers, payment '
            'history, and utility logs for $units units will be archived '
            'permanently.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GuardButton(
                  label: 'Cancel',
                  background: AppColors.surfaceContainerLowest,
                  foreground: AppColors.onSurface,
                  onTap: () => setState(() => _confirming = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GuardButton(
                  label: 'Confirm Delete',
                  background: AppColors.error,
                  foreground: AppColors.onError,
                  onTap: () => setState(() => _confirming = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuardButton extends StatelessWidget {
  const _GuardButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLg.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
