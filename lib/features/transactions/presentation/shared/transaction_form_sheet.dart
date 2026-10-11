import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_field.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_form_controller.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Add or edit a transaction: type, amount, category, date and note. Closes itself once saved.
///
/// Errors show inside the sheet, next to the field they concern (a snackbar would sit behind it).
class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({super.key, this.transaction, this.initialDate});

  /// The transaction to edit, or `null` to add one.
  final Transaction? transaction;

  /// Starting date of a new transaction (e.g. the calendar's selected day); today when `null`.
  /// Ignored when editing.
  final DateTime? initialDate;

  static Future<void> show(
    BuildContext context, {
    Transaction? transaction,
    DateTime? initialDate,
  }) => AppBottomSheet.show<void>(
    context,
    title: transaction == null
        ? context.l10n.transactionFormNewTitle
        : context.l10n.transactionFormEditTitle,
    child: TransactionFormSheet(transaction: transaction, initialDate: initialDate),
  );

  @override
  ConsumerState<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _note = TextEditingController(text: widget.transaction?.note);
  late TransactionType _type = widget.transaction?.type ?? TransactionType.expense;
  late Money? _amount = widget.transaction?.amount;
  late String? _categoryId = widget.transaction?.categoryId;
  late DateTime _date;
  late DateTime _today;
  String? _categoryError;
  String? _dateError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _today = AppDateUtils.dateOnly(ref.read(clockProvider).now());
    final initialDate = widget.initialDate;
    _date =
        widget.transaction?.occurredOn ??
        (initialDate == null ? _today : AppDateUtils.dateOnly(initialDate));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _clearErrors() => _categoryError = _dateError = _formError = null;

  Future<void> _pickDate() async {
    final first = TransactionValidator.earliestDate;
    final last = TransactionValidator.latestDate(_today);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(first) ? first : (_date.isAfter(last) ? last : _date),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        _dateError = null;
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;
    setState(_clearErrors);
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    if (_categoryId == null) setState(() => _categoryError = l10n.errorTransactionCategoryRequired);
    final amount = _amount;
    final categoryId = _categoryId;
    if (!fieldsValid || amount == null || categoryId == null) return;

    ref
        .read(transactionFormControllerProvider.notifier)
        .save(
          existing: widget.transaction,
          type: _type,
          amount: amount,
          categoryId: categoryId,
          occurredOn: _date,
          note: _note.text,
        );
  }

  void _showFailure(Object error) {
    final l10n = context.l10n;
    setState(() {
      switch (error) {
        case ValidationFailure(message: TransactionValidator.categoryNotFound):
          _categoryError = l10n.errorTransactionCategoryRequired;
        case ValidationFailure(message: TransactionValidator.categoryArchived):
          _categoryError = l10n.errorTransactionCategoryArchived;
        case ValidationFailure(message: TransactionValidator.categoryTypeMismatch):
          _categoryError = l10n.errorTransactionCategoryMismatch;
        case ValidationFailure(message: TransactionValidator.dateOutOfRange):
          _dateError = l10n.errorTransactionDateOutOfRange;
        case ValidationFailure(message: TransactionValidator.amountNotPositive):
          _formError = l10n.errorAmountInvalid;
        default:
          _formError = errorMessageOf(error, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(transactionFormControllerProvider, (previous, next) {
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
    final isSaving = ref.watch(transactionFormControllerProvider).isLoading;
    final errorStyle = context.text.bodySmall?.copyWith(color: context.colorScheme.error);
    final dateError = _dateError;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(value: TransactionType.expense, label: Text(l10n.commonExpense)),
              ButtonSegment(value: TransactionType.income, label: Text(l10n.commonIncome)),
            ],
            selected: {_type},
            onSelectionChanged: isSaving
                ? null
                : (selection) => setState(() {
                    _type = selection.first;
                    // The chosen category belongs to the other type.
                    _categoryId = null;
                    _categoryError = null;
                  }),
          ),
          const Gap(AppSpacing.md),
          AmountField(
            label: l10n.transactionFormAmountLabel,
            currencyCode: currencyCode,
            initialValue: widget.transaction?.amount,
            autofocus: widget.transaction == null,
            enabled: !isSaving,
            onChanged: (value) => _amount = value,
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.transactionFormCategoryLabel),
          TransactionCategoryPicker(
            type: _type,
            selectedId: _categoryId,
            enabled: !isSaving,
            errorText: _categoryError,
            onChanged: (id) => setState(() {
              _categoryId = id;
              _categoryError = null;
            }),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.transactionFormDateLabel),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton.secondary(
              label: context.formatDate(_date),
              icon: Icons.calendar_today_outlined,
              onPressed: isSaving ? null : _pickDate,
            ),
          ),
          if (dateError != null) ...[
            const Gap(AppSpacing.xs),
            Text(dateError, style: errorStyle),
          ],
          const Gap(AppSpacing.md),
          AppTextField(
            label: l10n.transactionFormNoteLabel,
            controller: _note,
            maxLines: 3,
            enabled: !isSaving,
            inputFormatters: [LengthLimitingTextInputFormatter(TransactionValidator.maxNoteLength)],
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
        ],
      ),
    );
  }
}
