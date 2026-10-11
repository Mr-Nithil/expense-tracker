import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DayTotals day(int income, int expense) =>
      DayTotals(date: DateTime(2026, 10, 5), income: Money(income), expense: Money(expense));

  test('net is income minus expenses', () {
    expect(day(10000, 400).net, const Money(9600));
  });

  test('net is negative on a spending day', () {
    expect(day(0, 1250).net, const Money(-1250));
  });

  test('net is zero when they cancel out', () {
    expect(day(500, 500).net, Money.zero);
  });
}
