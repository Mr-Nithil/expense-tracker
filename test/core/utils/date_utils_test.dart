import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('date-only helpers', () {
    test('dateOnly strips the time', () {
      expect(AppDateUtils.dateOnly(DateTime(2026, 10, 3, 23, 59, 59)), DateTime(2026, 10, 3));
    });

    test('monthStart and nextMonthStart', () {
      expect(AppDateUtils.monthStart(DateTime(2026, 10, 17, 8)), DateTime(2026, 10));
      expect(AppDateUtils.nextMonthStart(DateTime(2026, 12, 31)), DateTime(2027));
    });

    test('monthRange is half-open', () {
      final range = AppDateUtils.monthRange(DateTime(2026, 2, 14));
      expect(range, DateRange(DateTime(2026, 2), DateTime(2026, 3)));
      expect(range.contains(DateTime(2026, 2)), isTrue);
      expect(range.contains(DateTime(2026, 2, 28, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 3)), isFalse);
      expect(range.contains(DateTime(2026, 1, 31)), isFalse);
    });

    test('daysInMonth handles leap years', () {
      expect(AppDateUtils.daysInMonth(DateTime(2024, 2)), 29);
      expect(AppDateUtils.daysInMonth(DateTime(2026, 2)), 28);
      expect(AppDateUtils.daysInMonth(DateTime(2026, 12)), 31);
    });

    test('addMonths clamps the day', () {
      expect(AppDateUtils.addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
      expect(AppDateUtils.addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
      expect(AppDateUtils.addMonths(DateTime(2026, 3, 15), -3), DateTime(2025, 12, 15));
      expect(AppDateUtils.addMonths(DateTime(2026, 11, 30), 14), DateTime(2028, 1, 30));
    });

    test('isSameDay and isSameMonth', () {
      expect(AppDateUtils.isSameDay(DateTime(2026, 10, 3, 1), DateTime(2026, 10, 3, 22)), isTrue);
      expect(AppDateUtils.isSameDay(DateTime(2026, 10, 3), DateTime(2026, 10, 4)), isFalse);
      expect(AppDateUtils.isSameMonth(DateTime(2026, 10, 1), DateTime(2026, 10, 31)), isTrue);
      expect(AppDateUtils.isSameMonth(DateTime(2026, 10), DateTime(2025, 10)), isFalse);
    });
  });

  group('ISO dates', () {
    test('toIsoDate pads fields', () {
      expect(AppDateUtils.toIsoDate(DateTime(2026, 1, 5, 13)), '2026-01-05');
    });

    test('parseIsoDate round-trips', () {
      final date = DateTime(2026, 10, 3);
      expect(AppDateUtils.parseIsoDate(AppDateUtils.toIsoDate(date)), date);
    });

    test('parseIsoDate rejects malformed and impossible dates', () {
      for (final input in ['2026-1-05', '2026-02-30', '2026-13-01', '03/10/2026', '']) {
        expect(() => AppDateUtils.parseIsoDate(input), throwsFormatException, reason: input);
      }
    });
  });

  group('formatting (en_US)', () {
    final date = DateTime(2026, 10, 3, 14, 5);

    test('formats dates, months and times', () {
      expect(AppDateUtils.formatShortDate(date, 'en_US'), 'Oct 3, 2026');
      expect(AppDateUtils.formatWeekdayDate(date, 'en_US'), 'Sat, Oct 3');
      expect(AppDateUtils.formatLongDate(date, 'en_US'), 'Saturday, October 3, 2026');
      expect(AppDateUtils.formatMonthYear(date, 'en_US'), 'October 2026');
      expect(AppDateUtils.formatTime(date, 'en_US'), matches(RegExp(r'^2:05\sPM$')));
    });
  });
}
