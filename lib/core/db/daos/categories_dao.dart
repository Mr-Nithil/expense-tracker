import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/categories.dart';
import 'package:expense_tracker/core/db/tables/transactions.dart';

part 'categories_dao.g.dart';

/// Category queries. Every query is scoped to [userId]; rules live in the repository.
@DriftAccessor(tables: [Categories, Transactions])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.attachedDatabase);

  /// Active (not archived) categories, optionally of one [type], in display order.
  Stream<List<CategoryRow>> watchActive(String userId, {String? type}) {
    final query = select(categories)
      ..where((t) {
        var condition = t.userId.equals(userId) & t.deletedAt.isNull();
        if (type != null) condition &= t.type.equals(type);
        return condition;
      })
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]);
    return query.watch();
  }

  SimpleSelectStatement<$CategoriesTable, CategoryRow> _byId(String userId, String id) =>
      select(categories)..where((t) => t.userId.equals(userId) & t.id.equals(id));

  /// Includes archived categories, so transactions can still show theirs.
  Stream<CategoryRow?> watchById(String userId, String id) => _byId(userId, id).watchSingleOrNull();

  /// Includes archived categories.
  Future<CategoryRow?> getById(String userId, String id) => _byId(userId, id).getSingleOrNull();

  Future<void> insertCategory(CategoriesCompanion row) => into(categories).insert(row);

  /// Returns the number of updated rows (0 when the category doesn't exist for [userId]).
  Future<int> updateCategory(String userId, String id, CategoriesCompanion changes) =>
      (update(categories)..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(changes);

  /// Highest `sort_order` among active categories of [type], or `null` when there are none.
  Future<int?> maxSortOrder(String userId, String type) {
    final max = categories.sortOrder.max();
    final query = selectOnly(categories)
      ..addColumns([max])
      ..where(
        categories.userId.equals(userId) &
            categories.type.equals(type) &
            categories.deletedAt.isNull(),
      );
    return query.map((row) => row.read(max)).getSingle();
  }

  /// Whether an active category of [type] already uses [name] (case-insensitive).
  Future<bool> activeNameExists(
    String userId,
    String type,
    String name, {
    String? excludeId,
  }) async {
    final query = select(categories)
      ..where((t) {
        var condition =
            t.userId.equals(userId) &
            t.type.equals(type) &
            t.deletedAt.isNull() &
            t.name.lower().equals(name.toLowerCase());
        if (excludeId != null) condition &= t.id.equals(excludeId).not();
        return condition;
      })
      ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  /// Number of non-deleted transactions that use [categoryId].
  Future<int> countActiveTransactions(String userId, String categoryId) {
    final count = transactions.id.count();
    final query = selectOnly(transactions)
      ..addColumns([count])
      ..where(
        transactions.userId.equals(userId) &
            transactions.categoryId.equals(categoryId) &
            transactions.deletedAt.isNull(),
      );
    return query.map((row) => row.read(count)!).getSingle();
  }
}
