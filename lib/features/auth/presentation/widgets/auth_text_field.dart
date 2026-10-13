import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';

/// 52px rounded input with a leading icon, as used by the auth forms.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.prefixIconColor = AppColors.outline,
    this.prefixInset = 14,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.textStyle,
    this.fillColor = AppColors.surfaceContainerLowest,
    this.focusedFillColor,
    this.shadows = AppShadows.sm,
    this.height = 52,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hintText;
  final IconData prefixIcon;
  final Color prefixIconColor;

  /// Distance from the field's left edge to the icon.
  final double prefixInset;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;
  final Color fillColor;
  final Color? focusedFillColor;
  final List<BoxShadow> shadows;
  final double height;
  final bool enabled;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? AppTextStyles.bodyMd;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: height,
            decoration: BoxDecoration(
              color: focused ? (focusedFillColor ?? fillColor) : fillColor,
              borderRadius: _radius,
              boxShadow: shadows,
              border: Border.all(
                color: focused
                    ? AppColors.primaryContainer
                    : AppColors.primaryContainer.withValues(alpha: 0),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Border is 2px, so inset the icon by the remainder.
                SizedBox(width: prefixInset - 2),
                Icon(prefixIcon, size: 20, color: prefixIconColor),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    autofillHints: autofillHints,
                    onChanged: onChanged,
                    style: style,
                    decoration: InputDecoration.collapsed(
                      hintText: hintText,
                      hintStyle: style.copyWith(
                        color: AppColors.outlineVariant,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  suffix!,
                  const SizedBox(width: 10),
                ] else
                  const SizedBox(width: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Round 32–36px icon button placed inside a field (clear / show password).
class FieldIconButton extends StatelessWidget {
  const FieldIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppColors.outline,
    this.iconSize = 20,
    this.size = 32,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;
  final double iconSize;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

/// Square check box from the designs (filled emerald when checked).
class AuthCheckbox extends StatelessWidget {
  const AuthCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.radius = 6,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius),
            border: value ? null : Border.all(color: AppColors.outlineVariant),
            boxShadow: AppShadows.sm,
          ),
          child: value
              ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
              : null,
        ),
      ),
    );
  }
}
