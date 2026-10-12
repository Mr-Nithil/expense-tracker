import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_notification_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sunday, October 11 2026, 18:00.
  final now = DateTime(2026, 10, 11, 18);

  Reminder reminder({
    String id = 'r1',
    int hour = 20,
    int minute = 0,
    ReminderRepeat repeat = ReminderRepeat.daily,
    Set<int> weekdays = const {},
    int? dayOfMonth,
    bool enabled = true,
  }) => Reminder(
    id: id,
    title: 'Log expenses',
    time: ReminderTime(hour: hour, minute: minute),
    repeat: repeat,
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
    enabled: enabled,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  List<PlannedNotification> plan(List<Reminder> reminders, [DateTime? at]) =>
      ReminderNotificationPlan.of(reminders, at ?? now);

  group('daily', () {
    test('later today when the time has not passed', () {
      final planned = plan([reminder()]).single;

      expect(planned.at, DateTime(2026, 10, 11, 20));
      expect(planned.repeat, PlannedRepeat.daily);
      expect(planned.title, 'Log expenses');
    });

    test('tomorrow when the time has passed (or is exactly now)', () {
      expect(plan([reminder(hour: 9)]).single.at, DateTime(2026, 10, 12, 9));
      expect(plan([reminder(hour: 18)]).single.at, DateTime(2026, 10, 12, 18));
    });
  });

  group('weekly', () {
    test('one repeating notification per day, at each day\'s next date', () {
      final planned = plan([
        reminder(
          repeat: ReminderRepeat.weekly,
          weekdays: {DateTime.sunday, DateTime.monday, DateTime.friday},
        ),
      ]);

      expect(planned.map((p) => p.at), [
        DateTime(2026, 10, 12, 20), // Monday
        DateTime(2026, 10, 16, 20), // Friday
        DateTime(2026, 10, 11, 20), // Sunday, later today
      ]);
      expect(planned.every((p) => p.repeat == PlannedRepeat.weekly), isTrue);
      expect(planned.map((p) => p.id).toSet(), hasLength(3));
    });

    test('today\'s weekday after its time moves to next week', () {
      final planned = plan([
        reminder(repeat: ReminderRepeat.weekly, weekdays: {DateTime.sunday}, hour: 8),
      ]).single;

      expect(planned.at, DateTime(2026, 10, 18, 8));
    });
  });

  group('monthly', () {
    test('days 1–28 repeat on that day: this month if still ahead, else next', () {
      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 15)]).single.at,
        DateTime(2026, 10, 15, 20),
      );
      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 1)]).single.at,
        DateTime(2026, 11, 1, 20),
      );
      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 28)]).single.repeat,
        PlannedRepeat.monthly,
      );
    });

    test('the 31st: the next three dates once each, using the last day of short months', () {
      final planned = plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 31)]);

      expect(planned.map((p) => p.at), [
        DateTime(2026, 10, 31, 20),
        DateTime(2026, 11, 30, 20),
        DateTime(2026, 12, 31, 20),
      ]);
      expect(planned.every((p) => p.repeat == PlannedRepeat.none), isTrue);
    });

    test('the 30th across February uses the 28th (29th in a leap year)', () {
      final from = DateTime(2027, 1, 31, 23);
      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 30)], from).map((p) => p.at),
        [DateTime(2027, 2, 28, 20), DateTime(2027, 3, 30, 20), DateTime(2027, 4, 30, 20)],
      );
      final leap = DateTime(2028, 1, 31, 23);
      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 30)], leap).first.at,
        DateTime(2028, 2, 29, 20),
      );
    });

    test('a passed date this month is skipped', () {
      final lateOnThe31st = DateTime(2026, 10, 31, 21);

      expect(
        plan([reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 31)], lateOnThe31st).first.at,
        DateTime(2026, 11, 30, 20),
      );
    });
  });

  test('switched-off reminders are not planned', () {
    expect(plan([reminder(enabled: false)]), isEmpty);
  });

  test('every planned notification is after now', () {
    final planned = plan([
      reminder(id: 'a', hour: 0, minute: 0),
      reminder(id: 'b', repeat: ReminderRepeat.weekly, weekdays: {1, 2, 3, 4, 5, 6, 7}),
      reminder(id: 'c', repeat: ReminderRepeat.monthly, dayOfMonth: 29),
    ]);

    expect(planned.every((p) => p.at.isAfter(now)), isTrue);
  });

  group('ids', () {
    test('are stable, distinct per slot and inside the reminder range', () {
      final id0 = ReminderNotificationIds.of('3f2c0d8e-0000-4000-8000-000000000001', 0);
      final id6 = ReminderNotificationIds.of('3f2c0d8e-0000-4000-8000-000000000001', 6);

      expect(ReminderNotificationIds.of('3f2c0d8e-0000-4000-8000-000000000001', 0), id0);
      expect(id6 - id0, 6);
      expect(ReminderNotificationIds.isReminderId(id0), isTrue);
      expect(ReminderNotificationIds.isReminderId(id6), isTrue);
      expect(id6, lessThan(1 << 31));
    });

    test('ids outside the range are not reminders', () {
      expect(ReminderNotificationIds.isReminderId(0), isFalse);
      expect(ReminderNotificationIds.isReminderId(ReminderNotificationIds.base - 1), isFalse);
      expect(ReminderNotificationIds.isReminderId(1 << 30), isFalse);
    });

    test('the hash does not depend on Dart\'s String.hashCode (known value)', () {
      // FNV-1a("a") = 0xe40c292c; bucket = 0xe40c292c % 2^20 = 0x0c292c.
      expect(
        ReminderNotificationIds.of('a', 0),
        ReminderNotificationIds.base + 0x0c292c * ReminderNotificationIds.slotsPerReminder,
      );
    });
  });
}
