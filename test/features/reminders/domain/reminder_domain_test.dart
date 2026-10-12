import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
import 'package:expense_tracker/features/reminders/domain/services/weekday_mask.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderTime', () {
    test('formats as HH:mm with leading zeros', () {
      expect(const ReminderTime(hour: 8, minute: 5).toHhMm(), '08:05');
      expect(const ReminderTime(hour: 23, minute: 59).toHhMm(), '23:59');
    });

    test('parses HH:mm and rejects anything else', () {
      expect(ReminderTime.parse('20:30'), const ReminderTime(hour: 20, minute: 30));
      expect(ReminderTime.parse('00:00'), const ReminderTime(hour: 0, minute: 0));
      for (final bad in ['24:00', '12:60', '8:30', '12-30', '']) {
        expect(ReminderTime.parse(bad), isNull, reason: bad);
      }
    });
  });

  group('WeekdayMask', () {
    test('Monday is bit 0 and Sunday bit 6', () {
      expect(WeekdayMask.encode({DateTime.monday}), 1);
      expect(WeekdayMask.encode({DateTime.sunday}), 64);
      expect(WeekdayMask.encode({DateTime.monday, DateTime.wednesday, DateTime.friday}), 21);
    });

    test('round-trips every set of days', () {
      for (var mask = 0; mask < 128; mask++) {
        expect(WeekdayMask.encode(WeekdayMask.decode(mask)), mask);
      }
      expect(WeekdayMask.decode(null), isEmpty);
    });
  });

  group('ReminderValidator', () {
    String? reason({
      String title = 'Log expenses',
      ReminderTime time = const ReminderTime(hour: 20, minute: 0),
      ReminderRepeat repeat = ReminderRepeat.daily,
      Set<int> weekdays = const {},
      int? dayOfMonth,
    }) => ReminderValidator.validate(
      title: title,
      time: time,
      repeat: repeat,
      weekdays: weekdays,
      dayOfMonth: dayOfMonth,
    )?.message;

    test('a titled daily reminder is valid', () {
      expect(reason(), isNull);
    });

    test('the title is required (after trimming) and limited to 100 characters', () {
      expect(reason(title: '  '), ReminderValidator.titleRequired);
      expect(reason(title: 'a' * 101), ReminderValidator.titleTooLong);
    });

    test('the time must exist', () {
      expect(
        reason(time: const ReminderTime(hour: 24, minute: 0)),
        ReminderValidator.timeInvalid,
      );
    });

    test('weekly needs at least one valid weekday', () {
      expect(reason(repeat: ReminderRepeat.weekly), ReminderValidator.weekdaysRequired);
      expect(
        reason(repeat: ReminderRepeat.weekly, weekdays: {8}),
        ReminderValidator.weekdaysRequired,
      );
      expect(reason(repeat: ReminderRepeat.weekly, weekdays: {DateTime.monday}), isNull);
    });

    test('monthly needs a day 1..31', () {
      expect(reason(repeat: ReminderRepeat.monthly), ReminderValidator.dayOfMonthInvalid);
      expect(
        reason(repeat: ReminderRepeat.monthly, dayOfMonth: 0),
        ReminderValidator.dayOfMonthInvalid,
      );
      expect(reason(repeat: ReminderRepeat.monthly, dayOfMonth: 31), isNull);
    });

    test('normalize keeps only what the repeat uses', () {
      expect(
        ReminderValidator.normalize(
          repeat: ReminderRepeat.daily,
          weekdays: {DateTime.monday},
          dayOfMonth: 5,
        ),
        (weekdays: const <int>{}, dayOfMonth: null),
      );
      expect(
        ReminderValidator.normalize(
          repeat: ReminderRepeat.monthly,
          weekdays: {DateTime.monday},
          dayOfMonth: 5,
        ).dayOfMonth,
        5,
      );
    });
  });
}
