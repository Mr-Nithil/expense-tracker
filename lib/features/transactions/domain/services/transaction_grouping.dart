import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:meta/meta.dart';

/// The transactions of one calendar day with their totals.
@immutable
class TransactionDay {
  const TransactionDay({
    required this.date,
    required this.transactions,
    required this.income,
    required this.expense,
  });

  /// Date-only.
  final DateTime date;
  final List<Transaction> transactions;
  final Money income;
  final Money expense;

  /// Income minus expense: the day's subtotal.
  Money get net => income - expense;
}

/// Splits [transactions] into days, keeping their order (so a newest-first list gives
/// newest-first days). Consecutive transactions of the same day form one group.
List<TransactionDay> groupTransactionsByDay(List<Transaction> transactions) {
  final days = <TransactionDay>[];
  var current = <Transaction>[];

  void close() {
    if (current.isEmpty) return;
    var income = Money.zero;
    var expense = Money.zero;
    for (final t in current) {
      switch (t.type) {
        case TransactionType.income:
          income += t.amount;
        case TransactionType.expense:
          expense += t.amount;
      }
    }
    days.add(
      TransactionDay(
        date: AppDateUtils.dateOnly(current.first.occurredOn),
        transactions: List.unmodifiable(current),
        income: income,
        expense: expense,
      ),
    );
    current = [];
  }

  for (final transaction in transactions) {
    if (current.isNotEmpty &&
        !AppDateUtils.isSameDay(current.first.occurredOn, transaction.occurredOn)) {
      close();
    }
    current.add(transaction);
  }
  close();
  return days;
}
