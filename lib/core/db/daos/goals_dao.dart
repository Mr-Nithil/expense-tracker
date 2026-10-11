import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/goal_contributions.dart';
import 'package:expense_tracker/core/db/tables/goals.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';

part 'goals_dao.g.dart';

/// Goal and contribution queries. Every query is scoped to [userId]; rules live in the repository.
@DriftAccessor(tables: [Goals, GoalContributions])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.attachedDatabase);

  /// Non-deleted goals, oldest first, each with the sum of its non-deleted contributions.
  /// Computed in SQL and re-emitted when goals or contributions change.
  Stream<List<({GoalRow goal, int savedMinor})>> watchAllWithSaved(String userId) =>
      _withSaved(userId).watch().map(_read);

  /// One non-deleted goal with its saved sum, or `null`.
  Stream<({GoalRow goal, int savedMinor})?> watchByIdWithSaved(String userId, String id) {
    final query = _withSaved(userId)..where(goals.id.equals(id));
    return query.watch().map((rows) => _read(rows).firstOrNull);
  }

  /// The saved sum is a correlated sub-query, so each goal gets its own total.
  late final _saved = coalesce([
    subqueryExpression<int>(
      selectOnly(goalContributions)
        ..addColumns([goalContributions.amountMinor.sum()])
        ..where(
          goalContributions.goalId.equalsExp(goals.id) &
              goalContributions.userId.equalsExp(goals.userId) &
              goalContributions.deletedAt.isNull(),
        ),
    ),
    const Constant(0),
  ]);

  JoinedSelectStatement<HasResultSet, dynamic> _withSaved(String userId) =>
      select(goals).addColumns([_saved])
        ..where(goals.userId.equals(userId) & goals.deletedAt.isNull())
        ..orderBy([OrderingTerm.asc(goals.createdAt), OrderingTerm.asc(goals.id)]);

  List<({GoalRow goal, int savedMinor})> _read(List<TypedResult> rows) => [
    for (final row in rows) (goal: row.readTable(goals), savedMinor: row.read(_saved)!),
  ];

  /// Includes soft-deleted rows.
  Future<GoalRow?> getById(String userId, String id) =>
      (select(goals)..where((g) => g.userId.equals(userId) & g.id.equals(id))).getSingleOrNull();

  Future<void> insertGoal(GoalsCompanion row) => into(goals).insert(row);

  /// Returns the number of updated rows (0 when it doesn't exist for [userId]).
  Future<int> updateGoal(String userId, String id, GoalsCompanion changes) =>
      (update(goals)..where((g) => g.userId.equals(userId) & g.id.equals(id))).write(changes);

  /// Non-deleted contributions of [goalId], newest first: by date, then by when they were entered.
  Stream<List<GoalContributionRow>> watchContributions(String userId, String goalId) =>
      (select(goalContributions)
            ..where(
              (c) => c.userId.equals(userId) & c.goalId.equals(goalId) & c.deletedAt.isNull(),
            )
            ..orderBy([
              (c) => OrderingTerm.desc(c.contributedOn),
              (c) => OrderingTerm.desc(c.createdAt),
            ]))
          .watch();

  /// Includes soft-deleted rows.
  Future<GoalContributionRow?> getContributionById(String userId, String id) => (select(
    goalContributions,
  )..where((c) => c.userId.equals(userId) & c.id.equals(id))).getSingleOrNull();

  Future<void> insertContribution(GoalContributionsCompanion row) =>
      into(goalContributions).insert(row);

  /// Returns the number of updated rows (0 when it doesn't exist for [userId]).
  Future<int> updateContribution(String userId, String id, GoalContributionsCompanion changes) =>
      (update(
        goalContributions,
      )..where((c) => c.userId.equals(userId) & c.id.equals(id))).write(changes);

  /// Soft-deletes every live contribution of [goalId] at [at], pending sync. Returns how many.
  Future<int> softDeleteContributionsOfGoal(String userId, String goalId, DateTime at) =>
      (update(goalContributions)..where(
            (c) => c.userId.equals(userId) & c.goalId.equals(goalId) & c.deletedAt.isNull(),
          ))
          .write(
            GoalContributionsCompanion(
              deletedAt: Value(at),
              updatedAt: Value(at),
              syncStatus: const Value(SyncStatus.pending),
            ),
          );
}
