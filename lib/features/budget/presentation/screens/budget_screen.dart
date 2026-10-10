import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Placeholder for the budget tab. Built in M4.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.budgetTitle,
      body: EmptyState(
        icon: Icons.savings_outlined,
        title: l10n.commonComingSoonTitle,
        message: l10n.commonComingSoonMessage,
      ),
    );
  }
}
