import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/transactions.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';

part 'transactions_dao.g.dart';

/// Transaction queries. Every query is scoped to [userId]; rules live in the repository.
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  /// Non-deleted transactions with `occurred_on` in `[from, to)` (date-only), optionally of one
  /// [type] and/or [categoryId]. Newest first: by date, then by when they were entered.
  Stream<List<TransactionRow>> watchFiltered(
    String userId, {
    required DateTime from,
    required DateTime to,
    String? type,
    String? categoryId,
  }) {
    // `occurred_on` is `yyyy-MM-dd` text, which compares like the dates it holds.
    final start = AppDateUtils.toIsoDate(from);
    final end = AppDateUtils.toIsoDate(to);
    final query = select(transactions)
      ..where((t) {
        var condition =
            t.userId.equals(userId) &
            t.deletedAt.isNull() &
            t.occurredOn.isBiggerOrEqualValue(start) &
            t.occurredOn.isSmallerThanValue(end);
        if (type != null) condition &= t.type.equals(type);
        if (categoryId != null) condition &= t.categoryId.equals(categoryId);
        return condition;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.occurredOn),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.watch();
  }

  /// Sums of the non-deleted income and expenses with `occurred_on` in the month containing
  /// [month]; 0 when there are none. Re-emitted when transactions change.
  Stream<({int incomeMinor, int expenseMinor})> watchMonthTotals(String userId, DateTime month) {
    final amount = transactions.amountMinor;
    final income = coalesce([
      amount.sum(filter: transactions.type.equals('income')),
      const Constant(0),
    ]);
    final expense = coalesce([
      amount.sum(filter: transactions.type.equals('expense')),
      const Constant(0),
    ]);
    final query = selectOnly(transactions)
      ..addColumns([income, expense])
      ..where(_liveInMonth(userId, month));
    return query.watchSingle().map(
      (row) => (incomeMinor: row.read(income)!, expenseMinor: row.read(expense)!),
    );
  }

  /// Non-deleted expenses of the month containing [month], summed per category: largest first
  /// (ties by category id, so the order is stable). Re-emitted when transactions change.
  Stream<List<({String categoryId, int spentMinor})>> watchMonthSpendingByCategory(
    String userId,
    DateTime month,
  ) {
    final spent = transactions.amountMinor.sum();
    final query = selectOnly(transactions)
      ..addColumns([transactions.categoryId, spent])
      ..where(_liveInMonth(userId, month) & transactions.type.equals('expense'))
      ..groupBy([transactions.categoryId])
      ..orderBy([
        OrderingTerm.desc(spent),
        OrderingTerm.asc(transactions.categoryId),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (categoryId: row.read(transactions.categoryId)!, spentMinor: row.read(spent)!),
      ],
    );
  }

  /// Non-deleted income and expense per day of the month containing [month], oldest day first.
  /// Only days with transactions are listed. Re-emitted when transactions change.
  Stream<List<({DateTime day, int incomeMinor, int expenseMinor})>> watchMonthDailyTotals(
    String userId,
    DateTime month,
  ) {
    final amount = transactions.amountMinor;
    final income = coalesce([
      amount.sum(filter: transactions.type.equals('income')),
      const Constant(0),
    ]);
    final expense = coalesce([
      amount.sum(filter: transactions.type.equals('expense')),
      const Constant(0),
    ]);
    final query = selectOnly(transactions)
      ..addColumns([transactions.occurredOn, income, expense])
      ..where(_liveInMonth(userId, month))
      ..groupBy([transactions.occurredOn])
      ..orderBy([OrderingTerm.asc(transactions.occurredOn)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          (
            day: row.readWithConverter<DateTime, String>(transactions.occurredOn)!,
            incomeMinor: row.read(income)!,
            expenseMinor: row.read(expense)!,
          ),
      ],
    );
  }

  /// The user's non-deleted transactions with `occurred_on` in the month containing [month].
  Expression<bool> _liveInMonth(String userId, DateTime month) {
    final startDate = AppDateUtils.monthStart(month);
    // `occurred_on` is `yyyy-MM-dd` text, which compares like the dates it holds.
    final start = AppDateUtils.toIsoDate(startDate);
    final end = AppDateUtils.toIsoDate(AppDateUtils.nextMonthStart(startDate));
    return transactions.userId.equals(userId) &
        transactions.deletedAt.isNull() &
        transactions.occurredOn.isBiggerOrEqualValue(start) &
        transactions.occurredOn.isSmallerThanValue(end);
  }

  SimpleSelectStatement<$TransactionsTable, TransactionRow> _byId(String userId, String id) =>
      select(transactions)..where((t) => t.userId.equals(userId) & t.id.equals(id));

  /// Includes soft-deleted rows (for restore / undo).
  Stream<TransactionRow?> watchById(String userId, String id) =>
      _byId(userId, id).watchSingleOrNull();

  /// Includes soft-deleted rows (for restore / undo).
  Future<TransactionRow?> getById(String userId, String id) => _byId(userId, id).getSingleOrNull();

  Future<void> insertTransaction(TransactionsCompanion row) => into(transactions).insert(row);

  /// Returns the number of updated rows (0 when it doesn't exist for [userId]).
  Future<int> updateTransaction(String userId, String id, TransactionsCompanion changes) => (update(
    transactions,
  )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(changes);
}
