import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_chip_of.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Chips of the active expense categories that can get a new budget (those in [excludedIds]
/// already have one this month).
class BudgetCategoryPicker extends ConsumerWidget {
  const BudgetCategoryPicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.excludedIds = const {},
    this.errorText,
    this.enabled = true,
  });

  final String? selectedId;
  final ValueChanged<String> onChanged;
  final Set<String> excludedIds;
  final String? errorText;
  final bool enabled;

  static const _type = CategoryType.expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (ref.watch(categoriesProvider(_type))) {
          AsyncData(:final value) => () {
            final available = [
              for (final category in value)
                if (!excludedIds.contains(category.id)) category,
            ];
            if (available.isEmpty) {
              return Text(
                l10n.budgetFormNoCategoriesLeft,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final category in available)
                  categoryChipOf(
                    category,
                    selected: category.id == selectedId,
                    onTap: enabled ? () => onChanged(category.id) : null,
                  ),
              ],
            );
          }(),
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
                onPressed: () => ref.invalidate(categoriesProvider(_type)),
              ),
            ],
          ),
          _ => const LoadingView(),
        },
        if (error != null) ...[
          const Gap(AppSpacing.xs),
          Text(error, style: context.text.bodySmall?.copyWith(color: context.colorScheme.error)),
        ],
      ],
    );
  }
}
