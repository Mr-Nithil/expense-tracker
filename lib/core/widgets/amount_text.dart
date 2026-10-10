import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter/material.dart';

/// How an amount is colored and signed.
enum AmountType {
  /// Money in: income color, `+` when signed.
  income,

  /// Money out: expense color, `-` when signed.
  expense,

  /// A balance or total: expense color only when negative.
  neutral,
}

/// Displays [money] formatted for the current locale and [currencyCode].
///
/// Use instead of formatting money in widgets. [money] is a magnitude for income/expense and a
/// signed value for neutral.
class AmountText extends StatelessWidget {
  const AmountText(
    this.money, {
    super.key,
    required this.currencyCode,
    this.type = AmountType.neutral,
    this.showSign = false,
    this.style,
  });

  final Money money;
  final String currencyCode;
  final AmountType type;

  /// Prefix with `+`/`-` for income/expense.
  final bool showSign;

  /// Base style. Defaults to `bodyLarge`. The color is always set from [type].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = switch (type) {
      AmountType.income => money.abs(),
      AmountType.expense => showSign ? -money.abs() : money.abs(),
      AmountType.neutral => money,
    };
    final color = switch (type) {
      AmountType.income => colors.income,
      AmountType.expense => colors.expense,
      AmountType.neutral => money.isNegative ? colors.expense : null,
    };
    final text = value.format(
      locale: context.localeTag,
      currencyCode: currencyCode,
      signed: showSign && type == AmountType.income,
    );

    return Text(text, style: (style ?? context.text.bodyLarge)?.copyWith(color: color));
  }
}
