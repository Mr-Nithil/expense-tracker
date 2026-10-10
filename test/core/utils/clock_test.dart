import 'package:expense_tracker/core/utils/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixedClock returns its time and can advance', () {
    final clock = FixedClock(DateTime.utc(2026, 10, 3, 12));
    expect(clock.now(), DateTime.utc(2026, 10, 3, 12));
    clock.advance(const Duration(minutes: 5));
    expect(clock.now(), DateTime.utc(2026, 10, 3, 12, 5));
  });

  test('clockProvider defaults to the system clock and can be overridden', () {
    final defaultContainer = ProviderContainer();
    addTearDown(defaultContainer.dispose);
    expect(defaultContainer.read(clockProvider), isA<SystemClock>());

    final fixed = FixedClock(DateTime.utc(2026));
    final container = ProviderContainer(overrides: [clockProvider.overrideWithValue(fixed)]);
    addTearDown(container.dispose);
    expect(container.read(clockProvider).now(), DateTime.utc(2026));
  });
}
