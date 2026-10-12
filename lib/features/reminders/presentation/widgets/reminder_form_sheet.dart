import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_form_controller.dart';
import 'package:expense_tracker/features/reminders/presentation/reminder_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Add or edit a reminder: title, time and repeat (daily, weekly on chosen days, or monthly on a
/// day). When editing it can also delete the reminder. Pops `true` once saved, `false` once
/// deleted, so the caller can ask for notification permission.
class ReminderFormSheet extends ConsumerStatefulWidget {
  const ReminderFormSheet({super.key, this.reminder});

  /// The reminder to edit, or `null` to add one.
  final Reminder? reminder;

  /// Time of a new reminder.
  static const defaultTime = ReminderTime(hour: 20, minute: 0);

  static Future<bool?> show(BuildContext context, {Reminder? reminder}) =>
      AppBottomSheet.show<bool>(
        context,
        title: reminder == null
            ? context.l10n.reminderFormNewTitle
            : context.l10n.reminderFormEditTitle,
        child: ReminderFormSheet(reminder: reminder),
      );

  @override
  ConsumerState<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends ConsumerState<ReminderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.reminder?.title);
  late ReminderTime _time = widget.reminder?.time ?? ReminderFormSheet.defaultTime;
  late ReminderRepeat _repeat = widget.reminder?.repeat ?? ReminderRepeat.daily;
  late Set<int> _weekdays;
  late int _dayOfMonth;
  bool _deleting = false;
  String? _titleError;
  String? _daysError;
  String? _dayError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final today = ref.read(clockProvider).now();
    final existing = widget.reminder;
    _weekdays = existing != null && existing.weekdays.isNotEmpty
        ? {...existing.weekdays}
        : {today.weekday};
    _dayOfMonth = existing?.dayOfMonth ?? today.day;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _clearErrors() => _titleError = _daysError = _dayError = _formError = null;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (picked != null && mounted) {
      setState(() => _time = ReminderTime(hour: picked.hour, minute: picked.minute));
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(_clearErrors);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _deleting = false;
    ref
        .read(reminderFormControllerProvider.notifier)
        .save(
          existing: widget.reminder,
          title: _title.text,
          time: _time,
          repeat: _repeat,
          weekdays: _weekdays,
          dayOfMonth: _dayOfMonth,
        );
  }

  Future<void> _delete(Reminder reminder) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.reminderDeleteConfirmTitle(reminder.title),
      message: l10n.reminderDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(_clearErrors);
    _deleting = true;
    await ref.read(reminderFormControllerProvider.notifier).delete(reminder.id);
  }

  void _showFailure(Object error) {
    final l10n = context.l10n;
    setState(() {
      switch (error) {
        case ValidationFailure(message: ReminderValidator.titleRequired):
          _titleError = ValidationError.required.toL10n(context);
        case ValidationFailure(message: ReminderValidator.weekdaysRequired):
          _daysError = l10n.errorReminderWeekdaysRequired;
        case ValidationFailure(message: ReminderValidator.dayOfMonthInvalid):
          _dayError = l10n.errorReminderDayOfMonthRequired;
        default:
          _formError = errorMessageOf(error, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(reminderFormControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(:final error):
          _showFailure(error);
        case AsyncData() when previous?.isLoading ?? false:
          Navigator.of(context).pop(!_deleting);
        default:
          break;
      }
    });
    final isSaving = ref.watch(reminderFormControllerProvider).isLoading;
    final editing = widget.reminder;
    final errorStyle = context.text.bodySmall?.copyWith(color: context.colorScheme.error);
    final daysError = _daysError;
    final dayError = _dayError;
    final formError = _formError;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.reminderFormTitleLabel,
            hint: l10n.reminderFormTitleHint,
            controller: _title,
            errorText: _titleError,
            enabled: !isSaving,
            textInputAction: TextInputAction.done,
            inputFormatters: [LengthLimitingTextInputFormatter(ReminderValidator.maxTitleLength)],
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
            validator: (value) => Validators.required(value)?.toL10n(context),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.reminderFormTimeLabel),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton.secondary(
              label: ReminderDescription.timeText(context, _time),
              icon: Icons.schedule,
              onPressed: isSaving ? null : _pickTime,
            ),
          ),
          const Gap(AppSpacing.md),
          SectionHeader(title: l10n.reminderFormRepeatLabel),
          SegmentedButton<ReminderRepeat>(
            segments: [
              ButtonSegment(value: ReminderRepeat.daily, label: Text(l10n.reminderRepeatDaily)),
              ButtonSegment(value: ReminderRepeat.weekly, label: Text(l10n.reminderRepeatWeekly)),
              ButtonSegment(
                value: ReminderRepeat.monthly,
                label: Text(l10n.reminderRepeatMonthly),
              ),
            ],
            selected: {_repeat},
            onSelectionChanged: isSaving
                ? null
                : (selection) => setState(() {
                    _repeat = selection.first;
                    _daysError = _dayError = null;
                  }),
          ),
          if (_repeat == ReminderRepeat.weekly) ...[
            const Gap(AppSpacing.md),
            SectionHeader(title: l10n.reminderFormDaysLabel),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final day in ReminderDescription.weekdaysInLocaleOrder(context))
                  FilterChip(
                    label: Text(ReminderDescription.weekdayName(context, day)),
                    selected: _weekdays.contains(day),
                    onSelected: isSaving
                        ? null
                        : (on) => setState(() {
                            on ? _weekdays.add(day) : _weekdays.remove(day);
                            _daysError = null;
                          }),
                  ),
              ],
            ),
            if (daysError != null) ...[
              const Gap(AppSpacing.xs),
              Text(daysError, style: errorStyle),
            ],
          ],
          if (_repeat == ReminderRepeat.monthly) ...[
            const Gap(AppSpacing.md),
            DropdownButtonFormField<int>(
              initialValue: _dayOfMonth,
              decoration: InputDecoration(
                labelText: l10n.reminderFormDayOfMonthLabel,
                helperText: l10n.reminderFormDayOfMonthHint,
                errorText: dayError,
              ),
              items: [
                for (var day = 1; day <= 31; day++)
                  DropdownMenuItem(value: day, child: Text(day.toString())),
              ],
              onChanged: isSaving
                  ? null
                  : (day) => setState(() {
                      if (day != null) _dayOfMonth = day;
                      _dayError = null;
                    }),
            ),
          ],
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
              label: l10n.reminderFormDelete,
              icon: Icons.delete_outline,
              onPressed: isSaving ? null : () => _delete(editing),
              isExpanded: true,
            ),
          ],
        ],
      ),
    );
  }
}
