import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One transaction in a list: its category (archived ones included), note and signed amount.
class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyCode,
    this.onTap,
  });

  final Transaction transaction;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final title = switch (category) {
      AsyncData(value: final c?) => c.isArchived ? l10n.categoryChipArchived(c.name) : c.name,
      AsyncData() => l10n.categoryUnknown,
      // Still loading: no flash of "Unknown category".
      _ => '',
    };
    final found = category.value;
    final note = transaction.note;

    return ListTile(
      leading: CategoryIcon(
        iconKey: found?.icon ?? '',
        color: found?.color ?? context.colorScheme.outline.toARGB32(),
      ),
      title: Text(title),
      subtitle: note == null ? null : Text(note, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: AmountText(
        transaction.amount,
        currencyCode: currencyCode,
        type: switch (transaction.type) {
          TransactionType.income => AmountType.income,
          TransactionType.expense => AmountType.expense,
        },
        showSign: true,
      ),
      onTap: onTap,
    );
  }
}
