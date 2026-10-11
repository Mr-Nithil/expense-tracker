import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Money input for one currency. Reports [Money] (minor units) via [onChanged], never a double.
///
/// Shows the currency symbol, opens the decimal keyboard, accepts only as many decimals as the
/// currency has, and validates "required" and "greater than 0" (plus an optional [validator]).
class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.label,
    required this.currencyCode,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
  });

  final String label;
  final String currencyCode;
  final Money? initialValue;

  /// The parsed amount, or `null` while the input is empty or unreadable.
  final ValueChanged<Money?>? onChanged;

  /// Extra check on a readable, positive amount.
  final String? Function(Money value)? validator;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  TextEditingController? _controller;

  String get _locale => context.localeTag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs the locale, so it can't be created in initState.
    _controller ??= TextEditingController(
      text: widget.initialValue?.toInputString(locale: _locale, currencyCode: widget.currencyCode),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Money? _parse(String text) =>
      Money.tryParse(text, locale: _locale, currencyCode: widget.currencyCode);

  String? _validate(String? text) {
    if (Validators.required(text) case final error?) return error.toL10n(context);
    final amount = _parse(text!);
    if (amount == null || !amount.isPositive) return context.l10n.errorAmountInvalid;
    return widget.validator?.call(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: _controller,
      prefixText: '${Currencies.symbolOf(widget.currencyCode)} ',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: widget.textInputAction,
      inputFormatters: [
        AmountInputFormatter(
          decimalSeparator: NumberFormat.decimalPattern(_locale).symbols.DECIMAL_SEP,
          decimalDigits: Money.decimalDigitsFor(widget.currencyCode),
        ),
      ],
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onChanged: (text) => widget.onChanged?.call(_parse(text)),
      validator: _validate,
    );
  }
}

/// Allows digits and at most one [decimalSeparator] followed by at most [decimalDigits] digits.
/// Any edit that would break this is rejected (the old value stays).
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({required this.decimalSeparator, required this.decimalDigits});

  final String decimalSeparator;
  final int decimalDigits;

  /// Same limit as `Money.tryParse`, so everything typed can be parsed.
  static const maxIntegerDigits = 13;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final separator = RegExp.escape(decimalSeparator);
    final pattern = decimalDigits == 0
        ? RegExp('^\\d{0,$maxIntegerDigits}\$')
        : RegExp('^\\d{0,$maxIntegerDigits}($separator\\d{0,$decimalDigits})?\$');
    return pattern.hasMatch(text) ? newValue : oldValue;
  }
}
