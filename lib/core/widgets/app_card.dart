import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';

/// White, 12px-radius surface with the Tailwind `shadow-sm` used for most
/// cards in the Stitch designs. Becomes tappable when [onTap] is set.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surfaceContainerLowest,
    this.radius = 12,
    this.onTap,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  /// Clips children to the rounded corners (e.g. for edge-to-edge images).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: color,
        borderRadius: borderRadius,
        clipBehavior: clip || onTap != null ? Clip.antiAlias : Clip.none,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
