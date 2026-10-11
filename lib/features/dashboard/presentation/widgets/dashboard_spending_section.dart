import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/spending_breakdown.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// "Spending by category": the month's expenses per category, largest first, as labelled rows
/// with one-color bars (share of the month's spending). Smaller categories fold into one row.
class DashboardSpendingSection extends ConsumerWidget {
  const DashboardSpendingSection({super.key, required this.month, required this.currencyCode});

  final DateTime month;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final muted = context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.dashboardSpendingTitle),
        switch (ref.watch(spendingBreakdownProvider(month))) {
          AsyncData(value: final breakdown) when breakdown.isEmpty => Text(
            l10n.dashboardSpendingEmpty(AppDateUtils.formatMonthYear(month, context.localeTag)),
            style: muted,
          ),
          AsyncData(value: final breakdown) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final share in breakdown.shares)
                _SpendingRow(
                  key: ValueKey(share.categoryId),
                  share: share,
                  currencyCode: currencyCode,
                ),
            ],
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
                onPressed: () => ref.invalidate(spendingBreakdownProvider(month)),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
      ],
    );
  }
}

/// One category's (or the folded categories') amount, share bar and percent, read out together.
class _SpendingRow extends ConsumerWidget {
  const _SpendingRow({super.key, required this.share, required this.currencyCode});

  final SpendingShare share;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoryId = share.categoryId;
    final category = categoryId == null ? null : ref.watch(categoryByIdProvider(categoryId));
    final name = switch (category) {
      null => l10n.dashboardSpendingOther(share.foldedCategories),
      AsyncData(value: final c?) => c.isArchived ? l10n.categoryChipArchived(c.name) : c.name,
      AsyncData() => l10n.categoryUnknown,
      // Still loading: no flash of "Unknown category".
      _ => '',
    };
    final found = category?.value;
    final percent = share.percent == 0 && share.amount.isPositive
        ? l10n.dashboardSpendingPercentTiny
        : l10n.dashboardSpendingPercent(share.percent);

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CategoryIcon(
              iconKey: found?.icon ?? '',
              color: found?.color ?? context.colorScheme.outline.toARGB32(),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The amount moves under the name when both don't fit on one line.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: AppSpacing.sm,
                    children: [
                      Text(name, style: context.text.bodyLarge),
                      AmountText(
                        share.amount,
                        currencyCode: currencyCode,
                        style: context.text.bodyLarge,
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: ExcludeSemantics(child: ProgressBar(value: share.fraction)),
                      ),
                      const Gap(AppSpacing.sm),
                      Text(
                        percent,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
