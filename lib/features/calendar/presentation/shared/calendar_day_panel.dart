import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One day's transactions: its date (optional), "Add transaction" (on that date) and its
/// transactions; a row opens its detail page unless [onTransactionTap] says otherwise.
class CalendarDayPanel extends ConsumerWidget {
  const CalendarDayPanel({
    super.key,
    required this.day,
    required this.currencyCode,
    this.showDate = true,
    this.onTransactionTap,
  });

  /// The day (local midnight).
  final DateTime day;
  final String currencyCode;

  /// Off when the date is already shown around the panel (e.g. a sheet title).
  final bool showDate;

  /// Replaces opening the detail page (e.g. to close a sheet first).
  final ValueChanged<Transaction>? onTransactionTap;

  void _openDetail(BuildContext context, Transaction transaction) => context.goNamed(
    Routes.transactionDetail,
    pathParameters: {Routes.transactionIdParam: transaction.id},
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final date = AppDateUtils.formatLongDate(day, context.localeTag);
    final filter = TransactionFilter(month: AppDateUtils.monthStart(day));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The button moves under the date when both don't fit on one line.
        Wrap(
          alignment: showDate ? WrapAlignment.spaceBetween : WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (showDate) Text(date, style: context.text.titleMedium),
            AppButton.text(
              label: l10n.transactionsAdd,
              icon: Icons.add,
              onPressed: () => TransactionFormSheet.show(context, initialDate: day),
            ),
          ],
        ),
        switch (ref.watch(transactionDaysProvider(filter))) {
          AsyncData(value: final days) => switch ([
            for (final d in days)
              if (d.date == day) d,
          ]) {
            [final selected] => AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final transaction in selected.transactions)
                    TransactionTile(
                      key: ValueKey(transaction.id),
                      transaction: transaction,
                      currencyCode: currencyCode,
                      onTap: () => (onTransactionTap ?? (t) => _openDetail(context, t))(
                        transaction,
                      ),
                    ),
                ],
              ),
            ),
            _ => Text(
              l10n.calendarNoTransactionsOn(date),
              style: context.text.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          },
          AsyncError(:final error) => Row(
            children: [
              Expanded(
                child: Text(
                  errorMessageOf(error, context),
                  style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
                ),
              ),
              AppButton.text(
                label: l10n.commonRetry,
                // The day list is derived from the month's transactions; reload those.
                onPressed: () => ref.invalidate(transactionsProvider(filter)),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}
