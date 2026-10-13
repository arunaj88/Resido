import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';

/// Property card from Stitch "10. Property List". Properties with a photo
/// get the image header; others use the compact icon header.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onOpen,
    required this.onManageUnits,
  });

  final MockProperty property;
  final VoidCallback onOpen;
  final VoidCallback onManageUnits;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.sm),
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (property.cardImage != null) _ImageHeader(property: property),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (property.cardImage == null) ...[
                      _IconHeader(property: property),
                      const SizedBox(height: 12),
                    ],
                    AddressLine(property.addressLine),
                    const SizedBox(height: 12),
                    _MetricStrip(metrics: property.cardMetrics),
                    const SizedBox(height: 16),
                    _Footer(property: property, onManageUnits: onManageUnits),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: property.cardImageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(property.cardImage!, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _FrostedTypeChip(property.typeLabel),
                OccupancyChip(property: property, pulse: true),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.regionLabel.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primaryFixed,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  property.name,
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.onPrimary,
                    height: 1.375,
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

class _FrostedTypeChip extends StatelessWidget {
  const _FrostedTypeChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

/// "2 Vacant" (amber) or "100% Occupied" (emerald) status chip.
class OccupancyChip extends StatelessWidget {
  const OccupancyChip({
    super.key,
    required this.property,
    this.pulse = false,
    this.compact = false,
    this.vacantLabel = 'Vacant',
  });

  final MockProperty property;
  final bool pulse;

  /// Smaller vertical padding for the icon-header cards.
  final bool compact;
  final String vacantLabel;

  @override
  Widget build(BuildContext context) {
    final vacant = property.hasVacancies;
    final bg = vacant ? AppColors.tertiaryFixed : AppColors.secondaryContainer;
    final fg = vacant
        ? AppColors.onTertiaryFixed
        : AppColors.onSecondaryContainer;
    final dot = vacant ? AppColors.onTertiaryContainer : AppColors.secondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: compact ? null : AppShadows.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: dot, size: 6, pulsing: pulse && vacant),
          const SizedBox(width: 4),
          Text(
            vacant ? '${property.vacantCount} $vacantLabel' : '100% Occupied',
            style: AppTextStyles.labelMd.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _IconHeader extends StatelessWidget {
  const _IconHeader({required this.property});

  final MockProperty property;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      property.typeLabel,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  OccupancyChip(property: property, compact: true),
                ],
              ),
              const SizedBox(height: 4),
              Text(property.name, style: AppTextStyles.headlineSm),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            property.icon,
            size: 24,
            color: AppColors.primaryContainer,
          ),
        ),
      ],
    );
  }
}

/// Location pin + address line.
class AddressLine extends StatelessWidget {
  const AddressLine(
    this.address, {
    super.key,
    this.iconSize = 18,
    this.relaxed = true,
  });

  final String address;
  final double iconSize;
  final bool relaxed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.location_on_outlined,
            size: iconSize,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: relaxed ? AppTextStyles.relaxed : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics});

  final List<CardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, m) in metrics.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.value,
                    style: AppTextStyles.labelLg.copyWith(
                      color: m.emphasis
                          ? AppColors.secondary
                          : AppColors.onSurface,
                      fontWeight: m.emphasis ? FontWeight.w700 : null,
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

class _Footer extends StatelessWidget {
  const _Footer({required this.property, required this.onManageUnits});

  final MockProperty property;
  final VoidCallback onManageUnits;

  @override
  Widget build(BuildContext context) {
    final color = switch (property.cardNoteTone) {
      CardNoteTone.attention => AppColors.onTertiaryContainer,
      CardNoteTone.positive => AppColors.secondary,
      CardNoteTone.neutral => AppColors.onSurfaceVariant,
    };
    return Row(
      children: [
        Icon(property.cardNoteIcon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            property.cardNote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onManageUnits,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manage Units',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
