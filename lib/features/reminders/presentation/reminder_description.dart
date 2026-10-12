import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reminder schedules as text: "Every day at 8:30 PM", "Mon, Thu at 8:30 PM",
/// "Monthly on day 31 at 9:00 AM". Times follow the device's 24-hour setting.
abstract final class ReminderDescription {
  static String of(BuildContext context, Reminder reminder) {
    final l10n = context.l10n;
    final time = timeText(context, reminder.time);
    return switch (reminder.repeat) {
      ReminderRepeat.daily => l10n.reminderEveryDay(time),
      ReminderRepeat.weekly => l10n.reminderWeekly(
        weekdaysInLocaleOrder(
              context,
            )
            .where(reminder.weekdays.contains)
            .map((day) => weekdayName(context, day))
            .join(l10n.commonListSeparator),
        time,
      ),
      ReminderRepeat.monthly => l10n.reminderMonthly(reminder.dayOfMonth ?? 1, time),
    };
  }

  static String timeText(BuildContext context, ReminderTime time) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: time.hour, minute: time.minute),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  /// `DateTime.monday` (1) … `DateTime.sunday` (7), starting on the locale's first weekday.
  static List<int> weekdaysInLocaleOrder(BuildContext context) {
    // MaterialLocalizations counts from Sunday (0); DateTime weekdays from Monday (1).
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    return [for (var i = 0; i < 7; i++) (first + i + 6) % 7 + 1];
  }

  /// Short weekday name for the locale, e.g. "Mon".
  static String weekdayName(BuildContext context, int weekday) =>
      // 2024-01-01 was a Monday.
      DateFormat.E(context.localeTag).format(DateTime(2024, 1, weekday));
}
