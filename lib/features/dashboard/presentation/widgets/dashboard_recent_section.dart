import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_card.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Recent transactions": the month's latest few, newest first. "See all" opens the Transactions
/// tab on the same month (filters cleared); a row opens its detail page.
class DashboardRecentSection extends ConsumerWidget {
  const DashboardRecentSection({super.key, required this.month, required this.currencyCode});

  final DateTime month;
  final String currencyCode;

  /// Rows shown here; the rest are on the Transactions tab.
  static const maxItems = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = TransactionFilter(month: month);

    void seeAll() {
      ref.read(transactionFilterControllerProvider.notifier)
        ..clearFilters()
        ..setMonth(month);
      context.goNamed(Routes.transactions);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.dashboardRecentTitle,
          actionLabel: l10n.commonSeeAll,
          onAction: seeAll,
        ),
        switch (ref.watch(transactionsProvider(filter))) {
          AsyncData(value: final transactions) when transactions.isEmpty => Text(
            l10n.dashboardRecentEmpty(AppDateUtils.formatMonthYear(month, context.localeTag)),
            style: context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
          AsyncData(value: final transactions) => AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final transaction in transactions.take(maxItems))
                  TransactionTile(
                    key: ValueKey(transaction.id),
                    transaction: transaction,
                    currencyCode: currencyCode,
                    onTap: () => context.goNamed(
                      Routes.transactionDetail,
                      pathParameters: {Routes.transactionIdParam: transaction.id},
                    ),
                  ),
              ],
            ),
          ),
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
