import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_text_styles.dart';



/// Rounded-full tag with an optional leading icon (status / section badges).
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.iconSize = 14,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.gap = 6,
    this.uppercase = true,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double iconSize;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final double gap;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final style = (textStyle ??
            AppTextStyles.labelSm.copyWith(letterSpacing: 0.5))
        .copyWith(color: foreground);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: foreground),
            SizedBox(width: gap),
          ],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
