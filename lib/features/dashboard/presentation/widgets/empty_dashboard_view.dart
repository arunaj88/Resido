import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/utils/inr_format.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/app_card.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/dashboard/data/dashboard_mock_data.dart';

/// Dashboard state for a landlord with no properties yet
/// (Stitch "09. Empty Dashboard").
class EmptyDashboardView extends StatelessWidget {
  const EmptyDashboardView({super.key, required this.onExplorePreview});

  final VoidCallback onExplorePreview;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottom),
      children: [
        const _Welcome(),
        const SizedBox(height: 16),
        const _BaselineStrip(),
        const SizedBox(height: 16),
        _OnboardingCard(
          onAddProperty: () =>
              Navigator.of(context).pushNamed(AppRoutes.addProperty),
          onExplorePreview: onExplorePreview,
        ),
        const SizedBox(height: 16),
        const _LandlordDeskCard(),
      ],
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DashboardMockData.landlordFullName,
                style: AppTextStyles.headlineLgMobile.copyWith(
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const StatusDot(color: AppColors.secondary, size: 6),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Set up your landlord profile',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.275,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Decorative in the design: "0 notifications".
        Semantics(
          label: '0 notifications',
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _BaselineStrip extends StatelessWidget {
  const _BaselineStrip();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Portfolio Baseline', style: AppTextStyles.labelLg),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'No properties added yet',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _ZeroStat(value: '0', label: 'Properties'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _ZeroStat(value: '0', label: 'Active Units'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ZeroStat(
                  value: InrFormat.full(0),
                  label: 'Collected',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ZeroStat extends StatelessWidget {
  const _ZeroStat({
    required this.value,
    required this.label,
    this.valueColor = AppColors.onSurface,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.onAddProperty,
    required this.onExplorePreview,
  });

  final VoidCallback onAddProperty;
  final VoidCallback onExplorePreview;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      clip: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: -64,
            top: -64,
            child: _Glow(
              size: 176,
              color: AppColors.secondaryFixed,
              opacity: 0.4,
            ),
          ),
          const Positioned(
            left: -56,
            bottom: 8,
            child: _Glow(
              size: 144,
              color: AppColors.primaryFixed,
              opacity: 0.3,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(child: _RooflineBadge()),
              const SizedBox(height: 16),
              Text(
                "Let's add your first property",
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm.copyWith(letterSpacing: -0.45),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Resido organizes your rental properties, leases, tenant '
                  'records, and monthly rent collection in one secure place.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: AppTextStyles.relaxed,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _Step(
                number: 1,
                badge: AppColors.primaryContainer,
                badgeText: AppColors.onPrimary,
                title: 'Property Details',
                body: 'Apartment, Independent Villa, or Commercial Space',
              ),
              const SizedBox(height: 8),
              const _Step(
                number: 2,
                badge: AppColors.secondary,
                badgeText: AppColors.onPrimary,
                title: 'Tenant & Monthly Rent',
                body: 'Set payment dates, security deposit & tenant profile',
              ),
              const SizedBox(height: 8),
              const _Step(
                number: 3,
                badge: AppColors.surfaceContainerHighest,
                badgeText: AppColors.onSurface,
                title: 'Automate WhatsApp Alerts',
                body: 'Instant UPI payment receipts & smart gentle reminders',
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Add Your First Property',
                leadingIcon: Icons.add_circle_outline,
                iconSize: 22,
                radius: 8,
                onPressed: onAddProperty,
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Explore Dashboard Preview',
                leadingIcon: Icons.preview_outlined,
                iconSize: 18,
                height: 44,
                radius: 8,
                backgroundColor: AppColors.surfaceContainer,
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.labelLg,
                shadows: const [],
                onPressed: onExplorePreview,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

/// 80px badge with the Kerala roofline + key mark and a pulsing dot.
class _RooflineBadge extends StatelessWidget {
  const _RooflineBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: AppShadows.md,
            ),
            child: const Center(
              child: CustomPaint(
                size: Size.square(32),
                painter: _RooflinePainter(),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Pulse(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylized pitched roof over a house outline with a key (32×32 view box).
class _RooflinePainter extends CustomPainter {
  const _RooflinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    Paint stroke(double width) => Paint()
      ..color = AppColors.secondaryFixed
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(4, 14)
        ..lineTo(16, 5)
        ..lineTo(28, 14),
      stroke(2.2),
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, 11.5)
        ..lineTo(8, 23)
        ..cubicTo(8, 24.1, 8.9, 25, 10, 25)
        ..lineTo(22, 25)
        ..cubicTo(23.1, 25, 24, 24.1, 24, 23)
        ..lineTo(24, 11.5),
      stroke(1.8),
    );
    canvas.drawCircle(
      const Offset(16, 16),
      2.5,
      Paint()..color = AppColors.secondaryFixed,
    );
    canvas.drawLine(const Offset(16, 18.5), const Offset(16, 22), stroke(2));
    canvas.drawLine(const Offset(18, 20.5), const Offset(16, 20.5), stroke(2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.badge,
    required this.badgeText,
    required this.title,
    required this.body,
  });

  final int number;
  final Color badge;
  final Color badgeText;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: badge, shape: BoxShape.circle),
            child: Text(
              '$number',
              style: AppTextStyles.labelSm.copyWith(
                color: badgeText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLg.copyWith(height: 1.25),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
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

class _LandlordDeskCard extends StatelessWidget {
  const _LandlordDeskCard();

  @override
  Widget build(BuildContext context) {
    final link = AppTextStyles.labelMd;
    return AppCard(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Kerala Landlord Desk', style: AppTextStyles.labelLg),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.onSecondaryFixed,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Need assistance with tenancy contracts, NRI estate workflows, '
                  'or local rental agreements?',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.375,
                  ),
                ),
                const SizedBox(height: 10),
                // Display-only in this UI phase (no dialer / guide yet).
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _IconLabel(
                      icon: Icons.call_outlined,
                      label: 'Call Support',
                      style: link.copyWith(color: AppColors.secondary),
                    ),
                    _IconLabel(
                      icon: Icons.menu_book_outlined,
                      label: '2-Min Setup Guide',
                      style: link.copyWith(color: AppColors.onSurfaceVariant),
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

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: style.color),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
  }
}
