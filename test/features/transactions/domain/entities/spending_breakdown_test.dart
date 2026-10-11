import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/category_spending.dart';
import 'package:expense_tracker/features/transactions/domain/entities/spending_breakdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CategorySpending spent(String id, int minor) =>
      CategorySpending(categoryId: id, amount: Money(minor));

  test('keeps every category, in order, with its share', () {
    final breakdown = SpendingBreakdown.of([
      spent('food', 4200),
      spent('rent', 3000),
      spent('bus', 2800),
    ]);

    expect(breakdown.total, const Money(10000));
    expect(breakdown.shares.map((s) => s.categoryId), ['food', 'rent', 'bus']);
    expect(breakdown.shares.map((s) => s.percent), [42, 30, 28]);
    expect(breakdown.shares.first.fraction, 0.42);
    expect(breakdown.shares.any((s) => s.isOther), isFalse);
  });

  test('six categories still fit without "Other"', () {
    final breakdown = SpendingBreakdown.of([for (var i = 6; i > 0; i--) spent('c$i', i * 100)]);

    expect(breakdown.shares, hasLength(6));
    expect(breakdown.shares.any((s) => s.isOther), isFalse);
  });

  test('more than six: the top five, then "Other" with the rest', () {
    final breakdown = SpendingBreakdown.of([
      spent('a', 5000),
      spent('b', 2000),
      spent('c', 1000),
      spent('d', 800),
      spent('e', 600),
      spent('f', 400),
      spent('g', 200),
    ]);

    expect(breakdown.shares, hasLength(6));
    expect(breakdown.shares.take(5).map((s) => s.categoryId), ['a', 'b', 'c', 'd', 'e']);
    final other = breakdown.shares.last;
    expect(other.isOther, isTrue);
    expect(other.amount, const Money(600));
    expect(other.percent, 6);
    expect(other.foldedCategories, 2);
    expect(breakdown.shares.first.foldedCategories, 0);
    expect(breakdown.total, const Money(10000));
  });

  test('percents round half up', () {
    final breakdown = SpendingBreakdown.of([spent('a', 2), spent('b', 1)]);
    // 66.67% and 33.33%.
    expect(breakdown.shares.map((s) => s.percent), [67, 33]);

    final halves = SpendingBreakdown.of([spent('a', 1), spent('b', 199)]);
    // 0.5% rounds up to 1.
    expect(halves.shares.last.percent, 100);
    expect(halves.shares.first.percent, 1);
  });

  test('a tiny share can be 0%', () {
    final breakdown = SpendingBreakdown.of([spent('a', 100000), spent('b', 1)]);
    expect(breakdown.shares.last.percent, 0);
    expect(breakdown.shares.last.fraction, greaterThan(0));
  });

  test('no spending is empty', () {
    expect(SpendingBreakdown.of(const []).isEmpty, isTrue);
    expect(SpendingBreakdown.of(const []), SpendingBreakdown.empty);
  });

  test('large amounts stay exact', () {
    final breakdown = SpendingBreakdown.of([
      spent('a', 720000000000000),
      spent('b', 180000000000000),
    ]);
    expect(breakdown.shares.map((s) => s.percent), [80, 20]);
  });
}
