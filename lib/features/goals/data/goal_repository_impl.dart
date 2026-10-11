import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/goals_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/mappers.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';

/// [GoalRepository] backed by the local `goals` and `goal_contributions` tables.
class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl({
    required this.dao,
    required this.clock,
    required this.session,
    required this.syncTrigger,
  });

  final GoalsDao dao;
  final Clock clock;
  final Session session;
  final SyncTrigger syncTrigger;

  static const _noSession = AuthFailure('goals: no session');
  static const _goalNotFound = NotFoundFailure('goal');
  static const _contributionNotFound = NotFoundFailure('goal contribution');

  GoalProgress _progress(({GoalRow goal, int savedMinor}) row) =>
      GoalProgress(goal: row.goal.toEntity(), saved: Money(row.savedMinor));

  @override
  Stream<List<GoalProgress>> watchAll() {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao.watchAllWithSaved(userId).map((rows) => [for (final row in rows) _progress(row)]);
  }

  @override
  Stream<GoalProgress?> watchById(String id) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(null);
    return dao.watchByIdWithSaved(userId, id).map((row) => row == null ? null : _progress(row));
  }

  @override
  Future<Result<Goal>> create(GoalDraft draft) async {
    final invalid = _validateGoal(draft.name, draft.target, draft.deadlineOn);
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('create', () async {
      final id = IdGenerator.newId();
      final now = clock.now().toUtc();
      await dao.insertGoal(
        GoalsCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          name: GoalValidator.normalizeName(draft.name),
          targetMinor: draft.target.minor,
          deadlineOn: Value(_dateOnly(draft.deadlineOn)),
          icon: draft.icon,
          color: draft.color,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<Goal>> update(Goal goal) async {
    final invalid = _validateGoal(goal.name, goal.target, goal.deadlineOn);
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('update', () async {
      final existing = await dao.getById(userId, goal.id);
      if (existing == null || existing.deletedAt != null) {
        return const Result.failure(_goalNotFound);
      }
      await dao.updateGoal(
        userId,
        goal.id,
        GoalsCompanion(
          name: Value(GoalValidator.normalizeName(goal.name)),
          targetMinor: Value(goal.target.minor),
          deadlineOn: Value(_dateOnly(goal.deadlineOn)),
          icon: Value(goal.icon),
          color: Value(goal.color),
          updatedAt: Value(clock.now().toUtc()),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, goal.id))!.toEntity());
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('delete', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null) return const Result.failure(_goalNotFound);
      if (existing.deletedAt != null) return Result.ok;

      final now = clock.now().toUtc();
      await dao.softDeleteContributionsOfGoal(userId, id, now);
      await dao.updateGoal(
        userId,
        id,
        GoalsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  @override
  Stream<List<GoalContribution>> watchContributions(String goalId) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao
        .watchContributions(userId, goalId)
        .map((rows) => [for (final row in rows) row.toEntity()]);
  }

  @override
  Future<Result<GoalContribution>> addContribution(ContributionDraft draft) async {
    final invalid = GoalValidator.validateContribution(
      amount: draft.amount,
      contributedOn: draft.contributedOn,
      note: draft.note,
      today: clock.now(),
    );
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('addContribution', () async {
      final goal = await dao.getById(userId, draft.goalId);
      if (goal == null || goal.deletedAt != null) {
        return const Result.failure(
          ValidationFailure(GoalValidator.goalNotFound, field: GoalValidator.goalField),
        );
      }

      final id = IdGenerator.newId();
      final now = clock.now().toUtc();
      await dao.insertContribution(
        GoalContributionsCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          goalId: draft.goalId,
          amountMinor: draft.amount.minor,
          contributedOn: AppDateUtils.dateOnly(draft.contributedOn),
          note: Value(GoalValidator.normalizeNote(draft.note)),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getContributionById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<void>> deleteContribution(String id) => _setContributionDeleted(id, deleted: true);

  @override
  Future<Result<void>> restoreContribution(String id) =>
      _setContributionDeleted(id, deleted: false);

  Future<Result<void>> _setContributionDeleted(String id, {required bool deleted}) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard(deleted ? 'deleteContribution' : 'restoreContribution', () async {
      final existing = await dao.getContributionById(userId, id);
      if (existing == null) return const Result.failure(_contributionNotFound);
      if ((existing.deletedAt != null) == deleted) return Result.ok;
      if (!deleted) {
        final goal = await dao.getById(userId, existing.goalId);
        if (goal == null || goal.deletedAt != null) {
          return const Result.failure(
            ValidationFailure(GoalValidator.goalNotFound, field: GoalValidator.goalField),
          );
        }
      }

      final now = clock.now().toUtc();
      await dao.updateContribution(
        userId,
        id,
        GoalContributionsCompanion(
          deletedAt: Value(deleted ? now : null),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  ValidationFailure? _validateGoal(String name, Money target, DateTime? deadlineOn) =>
      GoalValidator.validateGoal(
        name: name,
        target: target,
        deadlineOn: deadlineOn,
        today: clock.now(),
      );

  static DateTime? _dateOnly(DateTime? date) => date == null ? null : AppDateUtils.dateOnly(date);

  /// Runs [body] in one DB transaction and turns any exception into a `StorageFailure`.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await dao.transaction(body);
    } catch (error, stackTrace) {
      AppLogger.error('goal $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('goal $operation: $error'));
    }
  }
}
