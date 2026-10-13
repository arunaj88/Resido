import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';



/// The Resido app logo (house + keyhole) exported from Stitch.
class ResidoLogo extends StatelessWidget {
  const ResidoLogo({super.key, this.size = 28, this.borderRadius = 0});

  static const assetPath = 'assets/images/resido_logo.png';

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Resido logo',
    );
    if (borderRadius == 0) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}

/// 40px rounded tile holding the logo, used on Welcome and Sign In.
class ResidoLogoTile extends StatelessWidget {
  const ResidoLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.sm,
      ),
      child: const ResidoLogo(),
    );
  }
}
