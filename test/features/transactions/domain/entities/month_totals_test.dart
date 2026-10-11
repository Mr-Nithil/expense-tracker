import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('balance is income minus expenses', () {
    const totals = MonthTotals(income: Money(500000), expense: Money(120050));
    expect(totals.balance, const Money(379950));
  });

  test('balance is negative when more was spent than earned', () {
    const totals = MonthTotals(income: Money(1000), expense: Money(2500));
    expect(totals.balance, const Money(-1500));
  });

  test('zero has nothing', () {
    expect(MonthTotals.zero.income, Money.zero);
    expect(MonthTotals.zero.expense, Money.zero);
    expect(MonthTotals.zero.balance, Money.zero);
  });
}
