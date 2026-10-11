import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_details.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// One category budget in a list: the category (archived ones included) and its progress.
class BudgetProgressTile extends ConsumerWidget {
  const BudgetProgressTile({
    super.key,
    required this.progress,
    required this.currencyCode,
    this.onTap,
  });

  /// A category budget (`budget.categoryId` is set).
  final BudgetProgress progress;
  final String currencyCode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final category = ref.watch(categoryByIdProvider(progress.budget.categoryId!));
    final name = switch (category) {
      AsyncData(value: final c?) => c.isArchived ? l10n.categoryChipArchived(c.name) : c.name,
      AsyncData() => l10n.categoryUnknown,
      // Still loading: no flash of "Unknown category".
      _ => '',
    };
    final found = category.value;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(name, style: context.text.titleSmall),
                  const Gap(AppSpacing.xs),
                  BudgetProgressDetails(
                    progress: progress,
                    currencyCode: currencyCode,
                    label: name,
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
