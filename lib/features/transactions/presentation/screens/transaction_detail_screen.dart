import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_chip_of.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_list_controller.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// One transaction: amount, type, category, date and note, with Edit and Delete (undoable).
/// Follows the database, so edits show at once.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // Read before awaiting: this page closes, and Undo must still work afterwards.
    final controller = ref.read(transactionListControllerProvider.notifier);
    final result = await controller.delete(id);
    if (!context.mounted) return;
    switch (result) {
      case Success():
        // Shown before closing: the scaffold messenger carries it over to the list.
        context.showUndoSnack(l10n.transactionDeleted, onUndo: () => controller.restore(id));
        context.pop();
      case Failure(:final failure):
        context.showSnack(failure.toL10n(context));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(transactionByIdProvider(id));
    final transaction = value.value;
    final exists = transaction != null && !transaction.isDeleted;

    return AppScaffold(
      title: l10n.transactionDetailTitle,
      actions: exists
          ? [
              IconButton(
                tooltip: l10n.commonEdit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => TransactionFormSheet.show(context, transaction: transaction),
              ),
              IconButton(
                tooltip: l10n.commonDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ]
          : null,
      body: AsyncValueView(
        value: ref.watch(currencyCodeProvider),
        // The currency comes from the profile; reload that.
        onRetry: () => ref.invalidate(profileProvider),
        data: (currencyCode) => AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(transactionByIdProvider(id)),
          data: (transaction) => transaction == null || transaction.isDeleted
              ? EmptyState(
                  icon: Icons.search_off_outlined,
                  title: l10n.transactionNotFoundTitle,
                  message: l10n.transactionNotFoundMessage,
                )
              : _Details(transaction: transaction, currencyCode: currencyCode),
        ),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.transaction, required this.currencyCode});

  final Transaction transaction;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));
    final note = transaction.note;
    final (amountType, typeLabel) = switch (transaction.type) {
      TransactionType.expense => (AmountType.expense, l10n.commonExpense),
      TransactionType.income => (AmountType.income, l10n.commonIncome),
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Center(
          child: AmountText(
            transaction.amount,
            currencyCode: currencyCode,
            type: amountType,
            showSign: true,
            style: context.text.headlineMedium,
          ),
        ),
        Center(
          child: Text(
            typeLabel,
            style: context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
        const Gap(AppSpacing.lg),
        _Field(
          label: l10n.transactionFormCategoryLabel,
          // Nothing while loading, so "Unknown category" never flashes.
          child: category.hasValue
              ? Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: categoryChipOf(category.value),
                )
              : const SizedBox.shrink(),
        ),
        _Field(
          label: l10n.transactionFormDateLabel,
          child: Text(AppDateUtils.formatLongDate(transaction.occurredOn, context.localeTag)),
        ),
        if (note != null) _Field(label: l10n.transactionDetailNoteLabel, child: Text(note)),
      ],
    );
  }
}

/// A label above its value.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: context.text.labelMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          const Gap(AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}
