import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_field.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_form_controller.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_category_picker.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_chip_of.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Add a budget to a month (the overall one while it has none, or a category without one), or
/// edit a budget's limit and remove it. Closes itself once saved or removed.
///
/// Errors show inside the sheet (a snackbar would sit behind it).
class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({
    super.key,
    required this.month,
    this.budget,
    this.overview = const BudgetOverview(),
  });

  final DateTime month;

  /// The budget to edit, or `null` to add one.
  final Budget? budget;

  /// The month's budgets when adding, so taken targets aren't offered again.
  final BudgetOverview overview;

  static Future<void> showAdd(
    BuildContext context, {
    required DateTime month,
    required BudgetOverview overview,
  }) => AppBottomSheet.show<void>(
    context,
    title: context.l10n.budgetFormNewTitle,
    child: BudgetFormSheet(month: month, overview: overview),
  );

  static Future<void> showEdit(BuildContext context, Budget budget) => AppBottomSheet.show<void>(
    context,
    title: context.l10n.budgetFormEditTitle,
    child: BudgetFormSheet(month: budget.month, budget: budget),
  );

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late bool _isOverall = widget.budget?.isOverall ?? widget.overview.overall == null;
  late String? _categoryId = widget.budget?.categoryId;
  late Money? _limit = widget.budget?.limit;
  String? _categoryError;
  String? _formError;

  void _clearErrors() => _categoryError = _formError = null;

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(_clearErrors);
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final categoryId = _isOverall ? null : _categoryId;
    if (!_isOverall && categoryId == null) {
      setState(() => _categoryError = context.l10n.errorBudgetCategoryRequired);
    }
    final limit = _limit;
    if (!fieldsValid || limit == null || (!_isOverall && categoryId == null)) return;

    ref
        .read(budgetFormControllerProvider.notifier)
        .save(month: widget.month, categoryId: categoryId, limit: limit);
  }

  Future<void> _remove(Budget budget) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.budgetRemoveConfirmTitle,
      message: l10n.budgetRemoveConfirmMessage,
      confirmLabel: l10n.budgetFormRemove,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(_clearErrors);
    await ref.read(budgetFormControllerProvider.notifier).remove(budget.id);
  }

  void _showFailure(Object error) {
    final l10n = context.l10n;
    setState(() {
      // When editing there is no picker to show a category problem next to.
      void category(String message) =>
          widget.budget == null ? _categoryError = message : _formError = message;
      switch (error) {
        case ValidationFailure(message: BudgetValidator.categoryNotFound):
          category(l10n.errorBudgetCategoryRequired);
        case ValidationFailure(message: BudgetValidator.categoryArchived):
          category(l10n.errorBudgetCategoryArchived);
        case ValidationFailure(message: BudgetValidator.categoryNotExpense):
          category(l10n.errorBudgetCategoryNotExpense);
        case ValidationFailure(message: BudgetValidator.limitNotPositive):
          _formError = l10n.errorAmountInvalid;
        case ValidationFailure(message: BudgetValidator.monthOutOfRange):
          _formError = l10n.errorBudgetMonthOutOfRange(BudgetValidator.maxMonthsAhead);
        default:
          _formError = errorMessageOf(error, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(budgetFormControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(:final error):
          _showFailure(error);
        case AsyncData() when previous?.isLoading ?? false:
          Navigator.of(context).pop();
        default:
          break;
      }
    });

    return AsyncValueView(
      value: ref.watch(currencyCodeProvider),
      // The currency comes from the profile; reload that.
      onRetry: () => ref.invalidate(profileProvider),
      data: _buildForm,
    );
  }

  Widget _buildForm(String currencyCode) {
    final l10n = context.l10n;
    final isSaving = ref.watch(budgetFormControllerProvider).isLoading;
    final muted = context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant);
    final editing = widget.budget;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppDateUtils.formatMonthYear(widget.month, context.localeTag), style: muted),
          const Gap(AppSpacing.md),
          if (editing == null && widget.overview.overall == null) ...[
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.budgetFormOverall)),
                ButtonSegment(value: false, label: Text(l10n.budgetFormCategory)),
              ],
              selected: {_isOverall},
              onSelectionChanged: isSaving
                  ? null
                  : (selection) => setState(() {
                      _isOverall = selection.first;
                      _categoryError = null;
                    }),
            ),
            const Gap(AppSpacing.md),
          ],
          if (_isOverall) ...[
            if (editing != null) ...[
              Text(l10n.budgetOverallTitle, style: context.text.titleMedium),
              const Gap(AppSpacing.xs),
            ],
            Text(l10n.budgetFormOverallHint, style: muted),
          ] else if (editing?.categoryId case final categoryId?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _CategoryOf(categoryId: categoryId),
            )
          else
            BudgetCategoryPicker(
              selectedId: _categoryId,
              excludedIds: {
                for (final progress in widget.overview.categories) ?progress.budget.categoryId,
              },
              enabled: !isSaving,
              errorText: _categoryError,
              onChanged: (id) => setState(() {
                _categoryId = id;
                _categoryError = null;
              }),
            ),
          const Gap(AppSpacing.md),
          AmountField(
            label: l10n.budgetFormLimitLabel,
            currencyCode: currencyCode,
            initialValue: editing?.limit,
            autofocus: editing != null,
            enabled: !isSaving,
            onChanged: (value) => _limit = value,
          ),
          const Gap(AppSpacing.lg),
          if (formError != null) ...[
            Text(
              formError,
              style: context.text.bodyMedium?.copyWith(color: context.colorScheme.error),
            ),
            const Gap(AppSpacing.sm),
          ],
          AppButton.primary(
            label: l10n.commonSave,
            onPressed: _submit,
            isLoading: isSaving,
            isExpanded: true,
          ),
          if (editing != null) ...[
            const Gap(AppSpacing.sm),
            AppButton.text(
              label: l10n.budgetFormRemove,
              icon: Icons.delete_outline,
              onPressed: isSaving ? null : () => _remove(editing),
              isExpanded: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// The edited budget's category as a chip; nothing until it has loaded (no "unknown" flash).
class _CategoryOf extends ConsumerWidget {
  const _CategoryOf({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(categoryId));
    if (!category.hasValue) return const SizedBox.shrink();
    return categoryChipOf(category.value, selected: true);
  }
}
