import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  final now = DateTime(2026, 10, 11, 15, 45);

  late ProviderContainer container;

  setUp(() {
    container = createTestContainer(overrides: [clockProvider.overrideWithValue(FixedClock(now))]);
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
  });

  DashboardMonthController controller() =>
      container.read(dashboardMonthControllerProvider.notifier);
  DateTime month() => container.read(dashboardMonthControllerProvider);

  test('starts at the first day of the current month', () {
    expect(month(), DateTime(2026, 10));
  });

  test('steps months across a year boundary', () {
    controller().setMonth(DateTime(2026, 1, 20));
    controller().previousMonth();
    expect(month(), DateTime(2025, 12));
    controller()
      ..nextMonth()
      ..nextMonth();
    expect(month(), DateTime(2026, 2));
  });

  test('clamps to the months that can hold transactions', () {
    final bounds = DashboardMonthController.monthBounds(now);

    controller().setMonth(DateTime(1999, 5));
    expect(month(), bounds.first);

    controller().setMonth(DateTime(2030));
    expect(month(), bounds.last);
  });

  test('resets for a new user', () {
    container.listen(dashboardMonthControllerProvider, (_, _) {});
    controller().previousMonth();

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));

    expect(month(), DateTime(2026, 10));
  });
}
