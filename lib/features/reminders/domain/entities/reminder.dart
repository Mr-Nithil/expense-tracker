import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';

/// How often a reminder repeats. Stored as `daily` / `weekly` / `monthly`.
enum ReminderRepeat { daily, weekly, monthly }

/// A local wall-clock time of day (no date, no time zone).
@freezed
abstract class ReminderTime with _$ReminderTime {
  const factory ReminderTime({required int hour, required int minute}) = _ReminderTime;

  const ReminderTime._();

  /// `HH:mm`, as stored (sorts like the time it holds).
  String toHhMm() => '${_two(hour)}:${_two(minute)}';

  /// Reads `HH:mm`; `null` when it isn't a valid time.
  static ReminderTime? parse(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ReminderTime(hour: hour, minute: minute);
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

/// A reminder the user set: a notification at [time], repeating [repeat].
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String title,
    required ReminderTime time,
    required ReminderRepeat repeat,

    /// For [ReminderRepeat.weekly]: `DateTime.monday` (1) … `DateTime.sunday` (7). Empty otherwise.
    @Default(<int>{}) Set<int> weekdays,

    /// For [ReminderRepeat.monthly]: 1–31 (short months use their last day). Null otherwise.
    int? dayOfMonth,
    required bool enabled,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reminder;
}

/// What the user enters to create a reminder (the repository adds id and timestamps).
@freezed
abstract class ReminderDraft with _$ReminderDraft {
  const factory ReminderDraft({
    required String title,
    required ReminderTime time,
    required ReminderRepeat repeat,
    @Default(<int>{}) Set<int> weekdays,
    int? dayOfMonth,
    @Default(true) bool enabled,
  }) = _ReminderDraft;
}
