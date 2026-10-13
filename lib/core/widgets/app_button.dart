import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';


/// The 52px, 12px-radius action button used across the Stitch designs.
///
/// Defaults to the Deep Emerald primary style; pass colours for the white
/// (Welcome "Sign In") or tinted (recovery "Back to Sign In") variants.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.iconSize = 20,
    this.textStyle,
    this.backgroundColor = AppColors.primaryContainer,
    this.foregroundColor = AppColors.onPrimary,
    this.shadows = AppShadows.sm,
    this.leading,
    this.height = defaultHeight,
    this.radius = 12,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double iconSize;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final Color foregroundColor;
  final List<BoxShadow> shadows;

  /// Custom leading widget (e.g. a spinner); takes precedence over [leadingIcon].
  final Widget? leading;
  final double height;
  final double radius;

  static const defaultHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final style = (textStyle ?? AppTextStyles.titleLg).copyWith(
      color: foregroundColor,
    );
    final leadingWidget = leading ??
        (leadingIcon == null
            ? null
            : Icon(leadingIcon, size: iconSize, color: foregroundColor));

    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingWidget != null) ...[
                    leadingWidget,
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: iconSize, color: foregroundColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
