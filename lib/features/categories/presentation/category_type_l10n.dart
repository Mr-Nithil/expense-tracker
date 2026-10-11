import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:flutter/widgets.dart';

extension CategoryTypeL10n on CategoryType {
  /// "Expense" / "Income", for tabs and toggles.
  String label(BuildContext context) => switch (this) {
    CategoryType.expense => context.l10n.commonExpense,
    CategoryType.income => context.l10n.commonIncome,
  };
}
