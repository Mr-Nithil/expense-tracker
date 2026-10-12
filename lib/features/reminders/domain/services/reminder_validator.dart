import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';

/// Reminder rules that need no database.
abstract final class ReminderValidator {
  /// Matches the `reminders.title` check constraint.
  static const maxTitleLength = 100;

  static const titleField = 'title';
  static const timeField = 'time';
  static const weekdaysField = 'weekdays';
  static const dayOfMonthField = 'dayOfMonth';

  /// `ValidationFailure.message` reasons, shared by the repository and the form.
  static const titleRequired = 'titleRequired';
  static const titleTooLong = 'titleTooLong';
  static const timeInvalid = 'timeInvalid';
  static const weekdaysRequired = 'weekdaysRequired';
  static const dayOfMonthInvalid = 'dayOfMonthInvalid';

  /// The first problem found, or `null` when valid.
  static ValidationFailure? validate({
    required String title,
    required ReminderTime time,
    required ReminderRepeat repeat,
    required Set<int> weekdays,
    required int? dayOfMonth,
  }) {
    final trimmed = normalizeTitle(title);
    if (trimmed.isEmpty) return const ValidationFailure(titleRequired, field: titleField);
    if (trimmed.length > maxTitleLength) {
      return const ValidationFailure(titleTooLong, field: titleField);
    }
    if (time.hour < 0 || time.hour > 23 || time.minute < 0 || time.minute > 59) {
      return const ValidationFailure(timeInvalid, field: timeField);
    }
    switch (repeat) {
      case ReminderRepeat.weekly:
        if (weekdays.isEmpty ||
            weekdays.any((day) => day < DateTime.monday || day > DateTime.sunday)) {
          return const ValidationFailure(weekdaysRequired, field: weekdaysField);
        }
      case ReminderRepeat.monthly:
        if (dayOfMonth == null || dayOfMonth < 1 || dayOfMonth > 31) {
          return const ValidationFailure(dayOfMonthInvalid, field: dayOfMonthField);
        }
      case ReminderRepeat.daily:
        break;
    }
    return null;
  }

  static String normalizeTitle(String title) => title.trim();

  /// Keeps only what [repeat] uses: weekdays for weekly, the day for monthly.
  static ({Set<int> weekdays, int? dayOfMonth}) normalize({
    required ReminderRepeat repeat,
    required Set<int> weekdays,
    required int? dayOfMonth,
  }) => (
    weekdays: repeat == ReminderRepeat.weekly ? weekdays : const <int>{},
    dayOfMonth: repeat == ReminderRepeat.monthly ? dayOfMonth : null,
  );
}
