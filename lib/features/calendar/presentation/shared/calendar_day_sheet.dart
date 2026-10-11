import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/features/calendar/presentation/shared/calendar_day_panel.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Everything about one day, as a pop-up: its income, expenses and net, "Add transaction" on that
/// date, and its transactions (a row closes the pop-up and opens its detail page).
class CalendarDaySheet extends ConsumerWidget {
  const CalendarDaySheet({super.key, required this.day, required this.currencyCode});

  /// The day (local midnight).
  final DateTime day;
  final String currencyCode;

  static Future<void> show(
    BuildContext context, {
    required DateTime day,
    required String currencyCode,
  }) => AppBottomSheet.show<void>(
    context,
    title: AppDateUtils.formatLongDate(day, context.localeTag),
    child: CalendarDaySheet(day: day, currencyCode: currencyCode),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final totals = ref.watch(monthDailyTotalsProvider(AppDateUtils.monthStart(day))).value?[day];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Total(
              label: l10n.commonIncome,
              money: totals?.income ?? Money.zero,
              currencyCode: currencyCode,
              type: AmountType.income,
            ),
            _Total(
              label: l10n.commonExpense,
              money: totals?.expense ?? Money.zero,
              currencyCode: currencyCode,
              type: AmountType.expense,
            ),
            _Total(
              label: l10n.calendarDayNet,
              money: totals?.net ?? Money.zero,
              currencyCode: currencyCode,
              type: AmountType.neutral,
            ),
          ],
        ),
        const Gap(AppSpacing.md),
        CalendarDayPanel(
          day: day,
          currencyCode: currencyCode,
          showDate: false,
          onTransactionTap: (transaction) {
            // Read before closing: this sheet's context is gone afterwards.
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.goNamed(
              Routes.transactionDetail,
              pathParameters: {Routes.transactionIdParam: transaction.id},
            );
          },
        ),
      ],
    );
  }
}

/// A label above an amount, read out together.
class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.money,
    required this.currencyCode,
    required this.type,
  });

  final String label;
  final Money money;
  final String currencyCode;
  final AmountType type;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: AmountText(
                money,
                currencyCode: currencyCode,
                type: type,
                style: context.text.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
