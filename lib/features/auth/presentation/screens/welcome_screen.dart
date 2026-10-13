import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/app_button.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/core/widgets/resido_logo.dart';
import 'package:resido/features/auth/presentation/widgets/info_pill.dart';

/// 01. Welcome Screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _BrandHeader(),
              const SizedBox(height: 8),
              const _HeroImage(),
              const SizedBox(height: 16),
              const _Headline(),
              const SizedBox(height: 12),
              const _ValueChips(),
              const SizedBox(height: 16),
              AppButton(
                label: 'Create Account',
                trailingIcon: Icons.arrow_forward,
                iconSize: 18,
                shadows: AppShadows.md,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createAccount),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Sign In',
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.onSurface,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signIn),
              ),
              const SizedBox(height: 12),
              const _NriFootnote(),
              const SizedBox(height: 12),
              const _LegalNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          const ResidoLogoTile(),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resido',
                  style: AppTextStyles.headlineSm.copyWith(
                    color: AppColors.primary,
                    height: 1.25,
                    letterSpacing: -0.45,
                  ),
                ),
                Text(
                  'Property Management for India',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.outline,
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

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/welcome_hero.jpg',
              fit: BoxFit.cover,
              semanticLabel: 'Contemporary Kerala villa at twilight',
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _RegionBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted strip over the hero: regions on the left, estates badge right.
class _RegionBar extends StatelessWidget {
  const _RegionBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              const StatusDot(
                color: AppColors.secondary,
                size: 10,
                pulsing: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kochi • Malabar • Travancore',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd,
                ),
              ),
              const SizedBox(width: 8),
              InfoPill(
                label: '1,200+ Estates',
                uppercase: false,
                background: AppColors.secondaryContainer,
                foreground: AppColors.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                textStyle: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final headline = AppTextStyles.headlineLgMobile.copyWith(height: 1.25);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Effortless property management for ',
            children: [
              TextSpan(
                text: 'Indian landlords.',
                style: headline.copyWith(color: AppColors.primaryContainer),
              ),
            ],
          ),
          style: headline,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage Kerala rental homes, commercial shops, and apartment flats '
          'with automated rent tracking, tenant records, and maintenance logs '
          'in one unified app.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            height: AppTextStyles.relaxed,
          ),
        ),
      ],
    );
  }
}

class _ValueChips extends StatelessWidget {
  const _ValueChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _ValueChip(
            leading: Text(
              '₹',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            label: 'Indian Rupee Native',
          ),
          const SizedBox(width: 8),
          const _ValueChip(
            leading: Icon(Icons.gavel, size: 14, color: AppColors.secondary),
            label: 'Kerala Tenancy Norms',
          ),
          const SizedBox(width: 8),
          const _ValueChip(
            leading: Icon(
              Icons.public,
              size: 14,
              color: AppColors.primaryContainer,
            ),
            label: 'Multi-Unit & NRI Ready',
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.leading, required this.label});

  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMd),
        ],
      ),
    );
  }
}

class _NriFootnote extends StatelessWidget {
  const _NriFootnote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trusted by NRIs across GCC & UK',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd,
                ),
                Text(
                  'Instant WhatsApp rent slips & KSEB bill logs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.bodySm.copyWith(
      color: AppColors.outline,
      height: 1.25,
    );
    final link = base.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );
    // Terms / Privacy pages are not part of Batch 01, so the links are
    // styled per the design but have no destination yet.
    return Text.rich(
      TextSpan(
        text: "By continuing, you agree to Resido's ",
        children: [
          TextSpan(text: 'Terms of Service', style: link),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: link),
          const TextSpan(text: '.'),
        ],
      ),
      style: base,
      textAlign: TextAlign.center,
    );
  }
}
