import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/loading_view.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_chip_of.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/category_type_of.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Category chips for a transaction of [type]. The selected category stays visible even if it was
/// archived (a transaction keeps its category, M2.5).
class TransactionCategoryPicker extends ConsumerWidget {
  const TransactionCategoryPicker({
    super.key,
    required this.type,
    required this.selectedId,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final TransactionType type;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(categoriesProvider(categoryTypeOf(type)));
    final selectedId = this.selectedId;
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (active) {
          AsyncData(:final value) => () {
            final isSelectedActive = value.any((c) => c.id == selectedId);
            // An archived (or not yet synced) current category isn't in the active list.
            final extra = selectedId == null || isSelectedActive
                ? null
                : ref.watch(categoryByIdProvider(selectedId));
            // Only once loaded, so "Unknown category" never flashes.
            final selectedExtra = extra != null && extra.hasValue ? extra : null;
            if (value.isEmpty && extra == null) {
              return Text(
                l10n.transactionFormNoCategories,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (selectedExtra != null)
                  categoryChipOf(selectedExtra.value, selected: true, onTap: null),
                for (final category in value)
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
                onPressed: () => ref.invalidate(categoriesProvider(categoryTypeOf(type))),
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
