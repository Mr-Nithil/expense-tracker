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
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/providers/contribution_form_controller.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Add money to a goal: amount, date (today or earlier) and an optional note. Closes itself once
/// saved; errors show inside the sheet.
class ContributionFormSheet extends ConsumerStatefulWidget {
  const ContributionFormSheet({super.key, required this.goalId});

  final String goalId;

  static Future<void> show(BuildContext context, {required String goalId}) =>
      AppBottomSheet.show<void>(
        context,
        title: context.l10n.goalsAddMoney,
        child: ContributionFormSheet(goalId: goalId),
      );

  @override
  ConsumerState<ContributionFormSheet> createState() => _ContributionFormSheetState();
}

class _ContributionFormSheetState extends ConsumerState<ContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  Money? _amount;
  late DateTime _date;
  late DateTime _today;
  String? _dateError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _today = AppDateUtils.dateOnly(ref.read(clockProvider).now());
    _date = _today;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: GoalValidator.earliestDate,
      lastDate: GoalValidator.latestContributionDate(_today),
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
    setState(() => _dateError = _formError = null);
    final amount = _amount;
    if (!(_formKey.currentState?.validate() ?? false) || amount == null) return;

    ref
        .read(contributionFormControllerProvider.notifier)
        .add(goalId: widget.goalId, amount: amount, contributedOn: _date, note: _note.text);
  }

  void _showFailure(Object error) {
    final l10n = context.l10n;
    setState(() {
      switch (error) {
        case ValidationFailure(message: GoalValidator.dateOutOfRange):
          _dateError = l10n.errorGoalContributionDateOutOfRange;
        case ValidationFailure(message: GoalValidator.amountNotPositive):
          _formError = l10n.errorAmountInvalid;
        case ValidationFailure(message: GoalValidator.goalNotFound):
          _formError = l10n.errorGoalNotFound;
        default:
          _formError = errorMessageOf(error, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(contributionFormControllerProvider, (previous, next) {
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
    final isSaving = ref.watch(contributionFormControllerProvider).isLoading;
    final dateError = _dateError;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmountField(
            label: l10n.goalContributionAmountLabel,
            currencyCode: currencyCode,
            autofocus: true,
            enabled: !isSaving,
            onChanged: (value) => _amount = value,
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.goalContributionDateLabel),
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
            Text(
              dateError,
              style: context.text.bodySmall?.copyWith(color: context.colorScheme.error),
            ),
          ],
          const Gap(AppSpacing.md),
          AppTextField(
            label: l10n.goalContributionNoteLabel,
            controller: _note,
            maxLines: 2,
            enabled: !isSaving,
            inputFormatters: [LengthLimitingTextInputFormatter(GoalValidator.maxNoteLength)],
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
