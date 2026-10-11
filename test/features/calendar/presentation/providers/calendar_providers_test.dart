import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  final now = DateTime(2026, 10, 11, 15, 45);
  final today = DateTime(2026, 10, 11);

  late ProviderContainer container;

  setUp(() {
    container = createTestContainer(overrides: [clockProvider.overrideWithValue(FixedClock(now))]);
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
  });

  CalendarController controller() => container.read(calendarControllerProvider.notifier);
  CalendarState state() => container.read(calendarControllerProvider);

  test('starts at the current month with today selected', () {
    expect(state(), (month: DateTime(2026, 10), selectedDay: today));
  });

  test('another month has nothing selected; back to this month selects today', () {
    controller().setMonth(DateTime(2026, 2, 20));
    expect(state(), (month: DateTime(2026, 2), selectedDay: null));

    controller().setMonth(DateTime(2026, 10, 3));
    expect(state(), (month: DateTime(2026, 10), selectedDay: today));
  });

  test('selecting a day shows its month', () {
    controller().selectDay(DateTime(2026, 9, 30, 14));
    expect(state(), (month: DateTime(2026, 9), selectedDay: DateTime(2026, 9, 30)));
  });

  test('clamps to the months that can hold transactions', () {
    final bounds = CalendarController.monthBounds(today);

    controller().setMonth(DateTime(1999, 5));
    expect(state().month, bounds.first);

    controller().setMonth(DateTime(2030));
    expect(state().month, bounds.last);
  });

  test('resets for a new user', () {
    container.listen(calendarControllerProvider, (_, _) {});
    controller().selectDay(DateTime(2026, 3, 4));

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));

    expect(state(), (month: DateTime(2026, 10), selectedDay: today));
  });
}
