import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Placeholder for the transactions tab. Built in M2.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.transactionsTitle,
      body: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.commonComingSoonTitle,
        message: l10n.commonComingSoonMessage,
      ),
    );
  }
}
