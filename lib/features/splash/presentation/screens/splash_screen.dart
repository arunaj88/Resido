import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:resido/app/router/app_routes.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';
import 'package:resido/core/widgets/pulse.dart';
import 'package:resido/features/splash/presentation/widgets/splash_painters.dart';



/// 00. Splash Screen — presentation only. The progress bar is a timed
/// animation; nothing is loaded or checked before moving on to Welcome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the splash stays up before handing over to Welcome.
  static const displayDuration = Duration(milliseconds: 2600);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: SplashScreen.displayDuration,
  );

  @override
  void initState() {
    super.initState();
    _progress.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.28),
            radius: 1.47,
            colors: [
              Color(0xB3ECFDF5),
              Color(0xF2F8FAFC),
              Color(0xFFF8FAFC),
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Backdrop(),
            SafeArea(
              child: Column(
                children: [
                  const Expanded(child: _BrandBlock()),
                  _LoadingFooter(progress: _progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lattice watermark and the two soft colour blooms behind the brand.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          const Opacity(
            opacity: 0.1,
            child: OverflowBox(
              maxWidth: 580,
              maxHeight: 580,
              child: CustomPaint(
                size: Size.square(580),
                painter: SplashLatticePainter(),
              ),
            ),
          ),
          Positioned(
            top: -96,
            child: _Bloom(
              width: 320,
              height: 320,
              color: AppColors.secondaryContainer,
            ),
          ),
          Positioned(
            bottom: 80,
            child: _Bloom(width: 384, height: 192, color: AppColors.tertiaryFixed),
          ),
        ],
      ),
    );
  }
}

class _Bloom extends StatelessWidget {
  const _Bloom({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.elliptical(width / 2, height / 2)),
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _LogoMark(),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Resido',
                style: AppTextStyles.headlineLg.copyWith(
                  height: 1.25,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  color: AppColors.warmAmber,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.sm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'KERALA ESTATE & TENANCY SUITE',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 4),
          Opacity(
            opacity: 0.75,
            child: Text(
              'NRI & Resident Property Wealth Management',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 96px emerald tile with the painted brand mark and a soft glow.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      height: 144,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 144,
              height: 144,
              decoration: const BoxDecoration(
                color: Color(0x1A10B981),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x3334D399)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33022C22),
                  offset: Offset(0, 20),
                  blurRadius: 25,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Color(0x33022C22),
                  offset: Offset(0, 8),
                  blurRadius: 10,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CustomPaint(
                    size: Size.square(56),
                    painter: SplashMarkPainter(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final footnoteStyle = AppTextStyles.labelSm.copyWith(
      color: AppColors.outline,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StatusDot(color: AppColors.secondary, pulsing: true),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Securing cloud vault · Kochi & Pan-Kerala',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.275,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ProgressTrack(progress: progress),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'BANK-GRADE SECURITY · 256-BIT ENCRYPTED',
                  textAlign: TextAlign.center,
                  style: footnoteStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Institutional Vault for High-Value Kerala Estates · v1.4.2',
            textAlign: TextAlign.center,
            style: footnoteStyle.copyWith(
              color: AppColors.outline.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// 176×4 track with the emerald → amber → emerald gradient fill.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.progress});

  final Animation<double> progress;

  // The design starts the bar at 28% and steps up to 100%.
  static const _start = 0.28;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 4,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xCCE2E8F0),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final value = _start + (1 - _start) * Curves.easeOut.transform(progress.value);
          return FractionallySizedBox(
            widthFactor: value,
            heightFactor: 1,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(2)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.warmAmber,
                    AppColors.secondary,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
