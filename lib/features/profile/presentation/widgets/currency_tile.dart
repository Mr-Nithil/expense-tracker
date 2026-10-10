import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:flutter/material.dart';

/// One selectable currency: symbol, code, an example amount, and an optional "Suggested" label.
class CurrencyTile extends StatelessWidget {
  const CurrencyTile({
    super.key,
    required this.currencyCode,
    required this.selected,
    required this.onTap,
    this.suggested = false,
  });

  /// Shown as the example amount, in whole units.
  static const exampleMajor = 1234;

  final String currencyCode;
  final bool selected;
  final bool suggested;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final example = Money.fromMajor(
      exampleMajor,
      currencyCode: currencyCode,
    ).format(locale: context.localeTag, currencyCode: currencyCode);

    return ListTile(
      selected: selected,
      onTap: onTap,
      leading: SizedBox(
        width: AppSizes.iconLg,
        child: Center(
          child: Text(Currencies.symbolOf(currencyCode), style: context.text.titleMedium),
        ),
      ),
      title: Text(currencyCode),
      subtitle: Text(
        suggested
            ? l10n.onboardingCurrencySuggestedExample(example)
            : l10n.onboardingCurrencyExample(example),
      ),
      trailing: selected ? const Icon(Icons.check_circle) : null,
    );
  }
}
