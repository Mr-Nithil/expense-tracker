import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/weekday_mask.dart';

extension ReminderRowMapper on ReminderRow {
  Reminder toEntity() => Reminder(
    id: id,
    title: title,
    // The DB and the server check the shape; midnight only guards against a corrupt row.
    time: ReminderTime.parse(timeOfDay) ?? const ReminderTime(hour: 0, minute: 0),
    repeat: ReminderRepeat.values.byName(repeatRule),
    weekdays: WeekdayMask.decode(weekdays),
    dayOfMonth: dayOfMonth,
    enabled: enabled,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
