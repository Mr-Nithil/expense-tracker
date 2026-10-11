import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/core/widgets/swipe_to_delete.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_grouping.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_list_controller.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_day_header.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_filter_bar.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The transactions tab: month/type/category filters above the matching transactions, grouped
/// by day with daily subtotals. The + button adds one; tapping a row opens its detail page; swiping
/// left deletes it (with Undo).
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  /// Keeps the last row clear of the floating button.
  static const _fabClearance = AppSpacing.xxl + AppSpacing.xl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(transactionFilterControllerProvider);
    final today = AppDateUtils.dateOnly(ref.watch(clockProvider).now());

    return AppScaffold(
      title: l10n.transactionsTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.transactionsAdd,
        onPressed: () => TransactionFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const TransactionFilterBar(),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(currencyCodeProvider),
              // The currency comes from the profile; reload that.
              onRetry: () => ref.invalidate(profileProvider),
              data: (currencyCode) => AsyncValueView(
                value: ref.watch(transactionDaysProvider(filter)),
                onRetry: () => ref.invalidate(transactionsProvider(filter)),
                data: (days) => days.isNotEmpty
                    ? _DayList(days: days, today: today, currencyCode: currencyCode)
                    : filter.isNarrowed
                    ? EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: l10n.transactionsNoMatchesTitle,
                        message: l10n.transactionsNoMatchesMessage,
                        actionLabel: l10n.transactionsClearFilters,
                        onAction: ref
                            .read(transactionFilterControllerProvider.notifier)
                            .clearFilters,
                      )
                    : EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.transactionsEmptyTitle(
                          AppDateUtils.formatMonthYear(filter.month, context.localeTag),
                        ),
                        message: l10n.transactionsEmptyMessage,
                        actionLabel: l10n.transactionsAdd,
                        onAction: () => TransactionFormSheet.show(context),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayList extends ConsumerStatefulWidget {
  const _DayList({required this.days, required this.today, required this.currencyCode});

  final List<TransactionDay> days;
  final DateTime today;
  final String currencyCode;

  @override
  ConsumerState<_DayList> createState() => _DayListState();
}

class _DayListState extends ConsumerState<_DayList> {
  /// Swiped away and being deleted: hidden at once, since a dismissed row must leave the tree
  /// before the database stream catches up.
  final _hidden = <String>{};

  /// Bumped whenever a row is shown again (failed delete, undo), so it gets a fresh Dismissible
  /// instead of reusing the dismissed one (which Flutter rejects).
  final _revisions = <String, int>{};

  void _show(String id) {
    _hidden.remove(id);
    _revisions.update(id, (revision) => revision + 1, ifAbsent: () => 1);
  }

  @override
  void didUpdateWidget(_DayList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the data no longer has them, there is nothing left to hide.
    final present = {for (final day in widget.days) ...day.transactions.map((t) => t.id)};
    _hidden.removeWhere((id) => !present.contains(id));
  }

  Future<void> _delete(Transaction transaction) async {
    final l10n = context.l10n;
    // Read once: deleting the month's last row swaps this list for the empty state (disposing
    // it), and Undo must still work then. The controller is kept alive, so it stays valid.
    final controller = ref.read(transactionListControllerProvider.notifier);
    setState(() => _hidden.add(transaction.id));
    final result = await controller.delete(transaction.id);
    if (!mounted) return;
    switch (result) {
      case Success():
        context.showUndoSnack(
          l10n.transactionDeleted,
          onUndo: () => _undo(controller, transaction.id),
        );
      case Failure(:final failure):
        setState(() => _show(transaction.id));
        context.showSnack(failure.toL10n(context));
    }
  }

  /// Runs even if this list is gone; the restored row comes back through the stream.
  Future<void> _undo(TransactionListController controller, String id) async {
    final result = await controller.restore(id);
    if (!mounted) return;
    setState(() => _show(id));
    if (result case Failure(:final failure)) context.showSnack(failure.toL10n(context));
  }

  @override
  Widget build(BuildContext context) {
    final days = _hidden.isEmpty
        ? widget.days
        : groupTransactionsByDay([
            for (final day in widget.days)
              for (final transaction in day.transactions)
                if (!_hidden.contains(transaction.id)) transaction,
          ]);
    // Headers and rows in one lazy list.
    final items = <Object>[
      for (final day in days) ...[day, ...day.transactions],
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: TransactionsScreen._fabClearance),
      itemCount: items.length,
      itemBuilder: (context, index) => switch (items[index]) {
        final TransactionDay day => TransactionDayHeader(
          day: day,
          today: widget.today,
          currencyCode: widget.currencyCode,
        ),
        final Transaction transaction => SwipeToDelete(
          itemKey: ValueKey((transaction.id, _revisions[transaction.id] ?? 0)),
          onDelete: () => _delete(transaction),
          child: TransactionTile(
            transaction: transaction,
            currencyCode: widget.currencyCode,
            onTap: () => context.pushNamed(
              Routes.transactionDetail,
              pathParameters: {Routes.transactionIdParam: transaction.id},
            ),
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
