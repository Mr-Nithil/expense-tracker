import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/services/spending_levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const max = Money(10000);
  int level(int spent) => SpendingLevels.of(Money(spent), max);

  test('no spending is level 0', () {
    expect(level(0), 0);
    expect(SpendingLevels.of(Money.zero, Money.zero), 0);
  });

  test('any spending is at least level 1', () {
    expect(level(1), 1);
    expect(level(2500), 1);
  });

  test('quarters of the biggest day, rounded up', () {
    expect(level(2501), 2);
    expect(level(5000), 2);
    expect(level(5001), 3);
    expect(level(7500), 3);
    expect(level(7501), 4);
  });

  test('the biggest day is the top level', () {
    expect(level(10000), SpendingLevels.count);
  });

  test('never above the top level', () {
    expect(level(25000), SpendingLevels.count);
  });

  test('large amounts stay exact', () {
    const big = Money(900000000000000);
    expect(SpendingLevels.of(const Money(225000000000000), big), 1);
    expect(SpendingLevels.of(const Money(225000000000001), big), 2);
  });
}
