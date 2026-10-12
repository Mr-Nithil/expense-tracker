import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/stable_hash.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_notification_plan.freezed.dart';

/// How a planned notification repeats (the scheduler maps it to the notification service).
enum PlannedRepeat { none, daily, weekly, monthly }

/// One notification to schedule for a reminder.
@freezed
abstract class PlannedNotification with _$PlannedNotification {
  const factory PlannedNotification({
    required int id,
    required String reminderId,
    required String title,

    /// First time it shows (local wall-clock time), always after "now".
    required DateTime at,
    required PlannedRepeat repeat,
  }) = _PlannedNotification;
}

/// Notification ids for reminders: stable across app runs (FNV-1a of the reminder id, not
/// `String.hashCode`) and inside their own range, so other notifications (budget alerts) never
/// collide with them.
abstract final class ReminderNotificationIds {
  /// Up to 7 weekdays, or 3 upcoming monthly dates.
  static const slotsPerReminder = 8;
  static const _buckets = 1 << 20;
  static const base = 1 << 24;
  static const _end = base + _buckets * slotsPerReminder;

  static int of(String reminderId, int slot) =>
      base + (StableHash.fnv1a(reminderId) % _buckets) * slotsPerReminder + slot;

  static bool isReminderId(int id) => id >= base && id < _end;
}

/// Which notifications the enabled reminders need from [now] on.
///
/// Daily, weekly (one per weekday) and monthly on days 1–28 repeat by themselves. Days 29–31
/// don't exist every month, so those get their next [monthlyLookahead] dates as one-offs (on the
/// month's last day when it is shorter), refreshed whenever the plan is applied again.
abstract final class ReminderNotificationPlan {
  /// One-off dates planned ahead for monthly reminders on days 29–31. Keeps the total under iOS's
  /// limit of 64 pending notifications.
  static const monthlyLookahead = 3;

  /// Last day that every month has.
  static const _safeMonthDay = 28;

  static List<PlannedNotification> of(List<Reminder> reminders, DateTime now) => [
    for (final reminder in reminders)
      if (reminder.enabled) ..._forReminder(reminder, now),
  ];

  static List<PlannedNotification> _forReminder(Reminder reminder, DateTime now) {
    PlannedNotification planned(int slot, DateTime at, PlannedRepeat repeat) => PlannedNotification(
      id: ReminderNotificationIds.of(reminder.id, slot),
      reminderId: reminder.id,
      title: reminder.title,
      at: at,
      repeat: repeat,
    );
    final time = reminder.time;
    final today = AppDateUtils.dateOnly(now);
    DateTime atTime(DateTime day) => DateTime(day.year, day.month, day.day, time.hour, time.minute);

    switch (reminder.repeat) {
      case ReminderRepeat.daily:
        final todayAt = atTime(today);
        return [
          planned(
            0,
            todayAt.isAfter(now) ? todayAt : atTime(today.add(const Duration(days: 1))),
            PlannedRepeat.daily,
          ),
        ];
      case ReminderRepeat.weekly:
        final days = reminder.weekdays.toList()..sort();
        return [
          for (final weekday in days)
            planned(
              weekday - DateTime.monday,
              _nextWeekday(today, weekday, atTime, now),
              PlannedRepeat.weekly,
            ),
        ];
      case ReminderRepeat.monthly:
        final day = reminder.dayOfMonth ?? 1;
        if (day <= _safeMonthDay) {
          final thisMonth = atTime(DateTime(today.year, today.month, day));
          return [
            planned(
              0,
              thisMonth.isAfter(now)
                  ? thisMonth
                  : atTime(DateTime(today.year, today.month + 1, day)),
              PlannedRepeat.monthly,
            ),
          ];
        }
        final dates = <DateTime>[];
        for (var month = 0; dates.length < monthlyLookahead; month++) {
          final first = DateTime(today.year, today.month + month);
          final clamped = day.clamp(1, AppDateUtils.daysInMonth(first));
          final at = atTime(DateTime(first.year, first.month, clamped));
          if (at.isAfter(now)) dates.add(at);
        }
        return [for (final (slot, at) in dates.indexed) planned(slot, at, PlannedRepeat.none)];
    }
  }

  static DateTime _nextWeekday(
    DateTime today,
    int weekday,
    DateTime Function(DateTime) atTime,
    DateTime now,
  ) {
    for (var offset = 0; offset <= 7; offset++) {
      final day = DateTime(today.year, today.month, today.day + offset);
      if (day.weekday == weekday && atTime(day).isAfter(now)) return atTime(day);
    }
    throw StateError('unreachable: a weekday comes within 8 days');
  }
}
