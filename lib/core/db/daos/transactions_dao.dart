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
