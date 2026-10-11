import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/error_view.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/core/widgets/month_selector.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_chip_of.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/category_type_of.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Month, type and category filters for the transaction list. All changes go through
/// [TransactionFilterController].
class TransactionFilterBar extends ConsumerWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(transactionFilterControllerProvider);
    final controller = ref.read(transactionFilterControllerProvider.notifier);
    final bounds = TransactionFilterController.monthBounds(ref.watch(clockProvider).now());
    final categoryId = filter.categoryId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MonthSelector(
            month: filter.month,
            firstMonth: bounds.first,
            lastMonth: bounds.last,
            onChanged: controller.setMonth,
          ),
          SegmentedButton<TransactionType?>(
            segments: [
              ButtonSegment(value: null, label: Text(l10n.commonAll)),
              ButtonSegment(value: TransactionType.expense, label: Text(l10n.commonExpense)),
              ButtonSegment(value: TransactionType.income, label: Text(l10n.commonIncome)),
            ],
            selected: {filter.type},
            onSelectionChanged: (selection) => controller.setType(selection.first),
          ),
          const Gap(AppSpacing.sm),
          Row(
            children: [
              if (categoryId == null)
                ActionChip(
                  avatar: const Icon(Icons.category_outlined),
                  label: Text(l10n.transactionsFilterAllCategories),
                  onPressed: () => _pickCategory(context, filter.type),
                )
              else ...[
                Flexible(
                  child: switch (ref.watch(categoryByIdProvider(categoryId))) {
                    // Only once loaded, so "Unknown category" never flashes.
                    final category when category.hasValue => categoryChipOf(
                      category.value,
                      selected: true,
                      onTap: () => _pickCategory(context, filter.type),
                    ),
                    _ => const SizedBox(height: AppSizes.minTapTarget),
                  },
                ),
                IconButton(
                  tooltip: l10n.transactionsFilterClearCategory,
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.setCategory(null),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _pickCategory(BuildContext context, TransactionType? type) =>
      AppBottomSheet.show<void>(
        context,
        title: context.l10n.transactionsFilterCategoryTitle,
        child: _CategoryFilterPicker(type: type),
      );
}

/// Active categories of [type] (both types when `null`); picking one sets the filter.
class _CategoryFilterPicker extends ConsumerWidget {
  const _CategoryFilterPicker({required this.type});

  final TransactionType? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final types = type == null ? CategoryType.values : [categoryTypeOf(type!)];
    final selectedId = ref.watch(transactionFilterControllerProvider).categoryId;
    final lists = [for (final t in types) ref.watch(categoriesProvider(t))];

    if (lists.any((list) => list.hasError)) {
      return ErrorView(
        message: errorMessageOf(lists.firstWhere((list) => list.hasError).error!, context),
        onRetry: () {
          for (final t in types) {
            ref.invalidate(categoriesProvider(t));
          }
        },
      );
    }
    if (lists.any((list) => !list.hasValue)) return const LoadingView();

    final categories = [for (final list in lists) ...list.requireValue];
    if (categories.isEmpty) return Text(l10n.categoriesEmptyTitle);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final category in categories)
          categoryChipOf(
            category,
            selected: category.id == selectedId,
            onTap: () {
              ref.read(transactionFilterControllerProvider.notifier).setCategory(category.id);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
