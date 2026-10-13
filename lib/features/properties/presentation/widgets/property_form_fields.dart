import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resido/app/theme/app_colors.dart';
import 'package:resido/app/theme/app_text_styles.dart';

/// White form section card with a header row (leading icon, title,
/// optional subtitle and trailing badge) followed by its fields.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    this.padding = 16,
    this.gap = 16,
    this.headerGap = 8,
    this.firstGap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final double padding;
  final double gap;
  final double headerGap;

  /// Space between the header and the first field (defaults to [gap]).
  final double? firstGap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
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
              leading,
              SizedBox(width: headerGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleLg),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          for (final (i, child) in children.indexed) ...[
            SizedBox(height: i == 0 ? (firstGap ?? gap) : gap),
            child,
          ],
        ],
      ),
    );
  }
}

/// Small rounded icon tile used as a section header leading.
class SectionIconTile extends StatelessWidget {
  const SectionIconTile({
    super.key,
    required this.icon,
    this.size = 28,
    this.background = AppColors.surfaceContainer,
    this.color = AppColors.primaryContainer,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// Small rounded-full badge in a section header ("Step 1 of 3").
class SectionBadge extends StatelessWidget {
  const SectionBadge(
    this.label, {
    super.key,
    this.background = AppColors.surfaceContainer,
    this.foreground = AppColors.onSurfaceVariant,
    this.bold = false,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: foreground,
          fontWeight: bold ? FontWeight.w600 : null,
        ),
      ),
    );
  }
}

/// Field label with an optional red required marker and trailing note.
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.trailing,
    this.color = AppColors.softCharcoal,
    this.weight = FontWeight.w600,
  });

  final String text;
  final bool required;
  final Widget? trailing;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.labelLg.copyWith(
      color: color,
      fontWeight: weight,
    );
    final text = Text.rich(
      TextSpan(
        text: this.text,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: style.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (trailing == null) return text;
    return Row(
      children: [
        Expanded(child: text),
        const SizedBox(width: 8),
        trailing!,
      ],
    );
  }
}

/// Trailing note next to a field label ("Optional", "Max 60 chars").
class FieldNote extends StatelessWidget {
  const FieldNote(
    this.text, {
    super.key,
    this.color = AppColors.onSurfaceVariant,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelSm.copyWith(color: color));
  }
}

/// Label above a field with the design's 6px gap.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.field,
    this.helper,
  });

  final Widget label;
  final Widget field;
  final Widget? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label,
        const SizedBox(height: 6),
        field,
        if (helper != null) ...[const SizedBox(height: 6), helper!],
      ],
    );
  }
}

/// Helper line under a field, with an optional leading icon.
class FieldHelper extends StatelessWidget {
  const FieldHelper(
    this.text, {
    super.key,
    this.icon,
    this.color = AppColors.onSurfaceVariant,
    this.style,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = (style ?? AppTextStyles.bodySm).copyWith(color: color);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(child: Text(text, style: textStyle)),
      ],
    );
  }
}

/// 48px rounded text input (or multi-line area). White fill that turns
/// to the low surface tint on focus, as in the Stitch forms.
class FormTextInput extends StatefulWidget {
  const FormTextInput({
    super.key,
    required this.controller,
    this.hintText,
    this.shadow = true,
    this.minLines,
    this.textStyle,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.errorBorder = false,
    this.radius = 8,
    this.fillColor = AppColors.surfaceContainerLowest,
    this.focusedFillColor = AppColors.surfaceContainerLow,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool shadow;

  /// Set for a multi-line text area.
  final int? minLines;
  final TextStyle? textStyle;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Highlights the field in the error colour (presentation-only feedback).
  final bool errorBorder;
  final double radius;
  final Color fillColor;
  final Color focusedFillColor;

  @override
  State<FormTextInput> createState() => _FormTextInputState();
}

class _FormTextInputState extends State<FormTextInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiline = widget.minLines != null;
    final style = widget.textStyle ?? AppTextStyles.bodyMd;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: BoxConstraints(minHeight: multiline ? 0 : 48),
      decoration: BoxDecoration(
        color: _focus.hasFocus ? widget.focusedFillColor : widget.fillColor,
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.shadow ? AppShadows.sm : null,
        border: widget.errorBorder
            ? Border.all(color: AppColors.error, width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.prefix == null ? 14 : 0,
                vertical: multiline ? 14 : 0,
              ).copyWith(right: widget.suffix == null ? 14 : 0),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                minLines: widget.minLines,
                maxLines: multiline ? null : 1,
                keyboardType: multiline
                    ? TextInputType.multiline
                    : widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                onChanged: widget.onChanged,
                style: style,
                decoration: InputDecoration.collapsed(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );
  }
}

/// 48px dropdown styled like [FormTextInput] with a chevron.
class FormDropdown extends StatelessWidget {
  const FormDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.shadow = true,
    this.icon = Icons.keyboard_arrow_down,
    this.iconColor = AppColors.outline,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool shadow;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadow ? AppShadows.sm : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          icon: Icon(icon, size: 22, color: iconColor),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: AppColors.surfaceContainerLowest,
          style: AppTextStyles.bodyMd,
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(option, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Kerala PIN presentation check from the designs (format only; no lookup).
enum PinState { keralaValid, indianNonKerala, incomplete }

PinState pinStateOf(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 6) return PinState.incomplete;
  return RegExp(r'^(67|68|69)').hasMatch(digits)
      ? PinState.keralaValid
      : PinState.indianNonKerala;
}
