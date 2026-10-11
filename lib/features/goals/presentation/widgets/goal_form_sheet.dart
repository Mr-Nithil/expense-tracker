import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/amount_field.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_color_picker.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_icon_picker.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goal_form_controller.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Create or edit a savings goal: name, target, optional deadline, icon and color. Closes itself
/// once saved.
///
/// Errors show inside the sheet, next to the field they concern (a snackbar would sit behind it).
class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({super.key, this.goal});

  /// The goal to edit, or `null` to add one.
  final Goal? goal;

  /// Icon of a new goal.
  static const defaultIcon = 'savings';

  static Future<void> show(BuildContext context, {Goal? goal}) => AppBottomSheet.show<void>(
    context,
    title: goal == null ? context.l10n.goalFormNewTitle : context.l10n.goalFormEditTitle,
    child: GoalFormSheet(goal: goal),
  );

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.goal?.name);
  late Money? _target = widget.goal?.target;
  late DateTime? _deadline = widget.goal?.deadlineOn;
  late String _icon = widget.goal?.icon ?? GoalFormSheet.defaultIcon;
  late int _color = widget.goal?.color ?? CategoryPalette.colors.first;
  late DateTime _today;
  String? _nameError;
  String? _deadlineError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _today = AppDateUtils.dateOnly(ref.read(clockProvider).now());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _clearErrors() => _nameError = _deadlineError = _formError = null;

  Future<void> _pickDeadline() async {
    final existing = widget.goal?.deadlineOn;
    // Today onwards; an edited goal whose deadline already passed may keep it.
    final first = existing != null && existing.isBefore(_today) ? existing : _today;
    final last = GoalValidator.latestDeadline(_today);
    final current = _deadline ?? _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(first) ? first : (current.isAfter(last) ? last : current),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && mounted) {
      setState(() {
        _deadline = picked;
        _deadlineError = null;
      });
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(_clearErrors);
    final target = _target;
    if (!(_formKey.currentState?.validate() ?? false) || target == null) return;

    ref
        .read(goalFormControllerProvider.notifier)
        .save(
          existing: widget.goal,
          name: _name.text,
          target: target,
          deadlineOn: _deadline,
          icon: _icon,
          color: _color,
        );
  }

  void _showFailure(Object error) {
    final l10n = context.l10n;
    setState(() {
      switch (error) {
        case ValidationFailure(message: GoalValidator.nameRequired):
          _nameError = ValidationError.required.toL10n(context);
        case ValidationFailure(message: GoalValidator.deadlineOutOfRange):
          _deadlineError = l10n.errorGoalDeadlineOutOfRange(GoalValidator.maxDeadlineYearsAhead);
        case ValidationFailure(message: GoalValidator.targetNotPositive):
          _formError = l10n.errorAmountInvalid;
        default:
          _formError = errorMessageOf(error, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(goalFormControllerProvider, (previous, next) {
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
    final isSaving = ref.watch(goalFormControllerProvider).isLoading;
    final errorStyle = context.text.bodySmall?.copyWith(color: context.colorScheme.error);
    final deadline = _deadline;
    final deadlineError = _deadlineError;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CategoryIcon(iconKey: _icon, color: _color),
              const Gap(AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: l10n.goalFormNameLabel,
                  controller: _name,
                  errorText: _nameError,
                  enabled: !isSaving,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(GoalValidator.maxNameLength)],
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  validator: (value) => Validators.required(value)?.toL10n(context),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          AmountField(
            label: l10n.goalFormTargetLabel,
            currencyCode: currencyCode,
            initialValue: widget.goal?.target,
            enabled: !isSaving,
            onChanged: (value) => _target = value,
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.goalFormDeadlineLabel),
          Row(
            children: [
              Flexible(
                child: AppButton.secondary(
                  label: deadline == null ? l10n.goalFormNoDeadline : context.formatDate(deadline),
                  icon: Icons.event_outlined,
                  onPressed: isSaving ? null : _pickDeadline,
                ),
              ),
              if (deadline != null)
                IconButton(
                  tooltip: l10n.goalFormClearDeadline,
                  icon: const Icon(Icons.close),
                  onPressed: isSaving
                      ? null
                      : () => setState(() {
                          _deadline = null;
                          _deadlineError = null;
                        }),
                ),
            ],
          ),
          if (deadlineError != null) ...[
            const Gap(AppSpacing.xs),
            Text(deadlineError, style: errorStyle),
          ],
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.goalFormIconLabel),
          CategoryIconPicker(
            selected: _icon,
            color: _color,
            onChanged: isSaving ? null : (icon) => setState(() => _icon = icon),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.goalFormColorLabel),
          CategoryColorPicker(
            selected: _color,
            onChanged: isSaving ? null : (color) => setState(() => _color = color),
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
