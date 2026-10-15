import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Standard text input (Sprout design): label above, filled 54 px field with a 2 px border
/// (line, primary when focused, danger on error), and the design's error row. Use instead of a
/// raw [TextField].
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.prefixText,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final TextEditingController? controller;

  /// Only used when [controller] is null.
  final String? initialValue;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;

  /// Text before the input, e.g. a currency symbol.
  final String? prefixText;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.colors;
    final explicitError = errorText;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: color, width: AppSizes.chunkyBorder),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The field announces its label itself (below); this is the visible copy.
        ExcludeSemantics(
          child: Text.rich(
            TextSpan(text: label),
            style: context.text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const Gap(AppSpacing.s6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            // Invisible: keeps the field's screen-reader label without showing it twice.
            labelText: label,
            labelStyle: const TextStyle(color: ColorTokens.transparent),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            prefixText: prefixText,
            suffixIcon: suffix,
            filled: true,
            fillColor: explicitError == null ? colors.field : colors.dangerSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: border(colors.line),
            enabledBorder: border(colors.line),
            disabledBorder: border(colors.line),
            focusedBorder: border(scheme.primary),
            errorBorder: border(scheme.error),
            focusedErrorBorder: border(scheme.error),
            error: explicitError == null ? null : _ErrorRow(explicitError),
          ),
          errorBuilder: (_, message) => _ErrorRow(message),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          obscureText: obscureText,
          enabled: enabled,
          autofocus: autofocus,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
        ),
      ],
    );
  }
}

/// The design's error line: a filled error icon and the message in danger.
class _ErrorRow extends StatelessWidget {
  const _ErrorRow(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.error;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(Icons.error_rounded, size: AppSizes.iconSm, color: color),
        ),
        const Gap(AppSpacing.s6),
        Expanded(
          child: Text(
            message,
            style: context.text.labelMedium?.copyWith(color: color, fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}
