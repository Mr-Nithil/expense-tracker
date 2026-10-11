import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1);
  var nextId = 0;

  Transaction tx(int day, int amount, {TransactionType type = TransactionType.expense}) =>
      Transaction(
        id: '${nextId++}',
        type: type,
        amount: Money(amount),
        categoryId: 'c',
        occurredOn: DateTime(2026, 10, day),
        isDeleted: false,
        createdAt: at,
        updatedAt: at,
      );

  test('no transactions means no days', () {
    expect(groupTransactionsByDay(const []), isEmpty);
  });

  test('groups newest-first transactions into newest-first days', () {
    final a = tx(9, 100);
    final b = tx(9, 200);
    final c = tx(3, 300);

    final days = groupTransactionsByDay([a, b, c]);

    expect(days.map((d) => d.date), [DateTime(2026, 10, 9), DateTime(2026, 10, 3)]);
    expect(days.first.transactions, [a, b]);
    expect(days.last.transactions, [c]);
  });

  test('sums income and expense per day and nets them', () {
    final days = groupTransactionsByDay([
      tx(9, 1250),
      tx(9, 85000, type: TransactionType.income),
      tx(9, 399),
      tx(8, 1000),
    ]);

    expect(days.first.expense, const Money(1649));
    expect(days.first.income, const Money(85000));
    expect(days.first.net, const Money(83351));
    expect(days.last.net, const Money(-1000));
  });

  test('sums exactly in minor units', () {
    // 0.10 + 0.20 would not be 0.30 with doubles.
    final days = groupTransactionsByDay([tx(5, 10), tx(5, 20)]);
    expect(days.single.expense, const Money(30));
  });
}
