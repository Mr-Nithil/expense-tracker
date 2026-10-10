import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// [AppTextField] for passwords with a show/hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String> autofillHints;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      prefixIcon: Icons.lock_outline,
      obscureText: _obscure,
      suffix: IconButton(
        tooltip: _obscure ? l10n.authShowPassword : l10n.authHidePassword,
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
    );
  }
}
