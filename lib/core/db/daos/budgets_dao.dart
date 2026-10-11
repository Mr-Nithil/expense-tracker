import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/budgets.dart';
import 'package:expense_tracker/core/db/tables/transactions.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';

part 'budgets_dao.g.dart';

/// Budget queries. Every query is scoped to [userId]; rules live in the repository.
@DriftAccessor(tables: [Budgets, Transactions])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.attachedDatabase);

  /// Non-deleted budgets of the month containing [month]: the overall budget first, then
  /// per-category budgets in creation order.
  Stream<List<BudgetRow>> watchMonth(String userId, DateTime month) =>
      _monthQuery(userId, month).watch();

  /// [watchMonth], read once.
  Future<List<BudgetRow>> getMonth(String userId, DateTime month) =>
      _monthQuery(userId, month).get();

  SimpleSelectStatement<$BudgetsTable, BudgetRow> _monthQuery(String userId, DateTime month) =>
      select(budgets)
        ..where(
          (b) =>
              b.userId.equals(userId) &
              b.deletedAt.isNull() &
              b.month.equalsValue(AppDateUtils.monthStart(month)),
        )
        ..orderBy([
          (b) => OrderingTerm(expression: b.categoryId.isNull(), mode: OrderingMode.desc),
          (b) => OrderingTerm.asc(b.createdAt),
        ]);

  /// Like [watchMonth], with each budget's spending in that month: the overall budget counts
  /// every non-deleted expense, a category budget only its category's. Computed in SQL, and
  /// re-emitted when budgets or transactions change.
  Stream<List<({BudgetRow budget, int spentMinor})>> watchMonthWithSpent(
    String userId,
    DateTime month,
  ) {
    final start = AppDateUtils.monthStart(month);
    // `occurred_on` is `yyyy-MM-dd` text, which compares like the dates it holds.
    final from = AppDateUtils.toIsoDate(start);
    final to = AppDateUtils.toIsoDate(AppDateUtils.nextMonthStart(start));
    final spentQuery = selectOnly(transactions)
      ..addColumns([transactions.amountMinor.sum()])
      ..where(
        transactions.userId.equalsExp(budgets.userId) &
            transactions.deletedAt.isNull() &
            transactions.type.equals('expense') &
            transactions.occurredOn.isBiggerOrEqualValue(from) &
            transactions.occurredOn.isSmallerThanValue(to) &
            (budgets.categoryId.isNull() | transactions.categoryId.equalsExp(budgets.categoryId)),
      );
    final spent = coalesce([subqueryExpression<int>(spentQuery), const Constant(0)]);
    final query = select(budgets).addColumns([spent])
      ..where(
        budgets.userId.equals(userId) &
            budgets.deletedAt.isNull() &
            budgets.month.equalsValue(start),
      )
      ..orderBy([
        OrderingTerm(expression: budgets.categoryId.isNull(), mode: OrderingMode.desc),
        OrderingTerm.asc(budgets.createdAt),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows) (budget: row.readTable(budgets), spentMinor: row.read(spent)!),
      ],
    );
  }

  /// Includes soft-deleted rows (a deleted budget is revived when its key is set again).
  Future<BudgetRow?> getById(String userId, String id) =>
      (select(budgets)..where((b) => b.userId.equals(userId) & b.id.equals(id))).getSingleOrNull();

  Future<void> insertBudget(BudgetsCompanion row) => into(budgets).insert(row);

  /// Returns the number of updated rows (0 when it doesn't exist for [userId]).
  Future<int> updateBudget(String userId, String id, BudgetsCompanion changes) =>
      (update(budgets)..where((b) => b.userId.equals(userId) & b.id.equals(id))).write(changes);
}
