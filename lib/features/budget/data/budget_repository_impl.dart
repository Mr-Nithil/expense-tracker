import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/budgets_dao.dart';
import 'package:expense_tracker/core/db/daos/categories_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/mappers.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';

/// [BudgetRepository] backed by the local `budgets` table.
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required this.dao,
    required this.categoriesDao,
    required this.clock,
    required this.session,
    required this.syncTrigger,
  });

  final BudgetsDao dao;
  final CategoriesDao categoriesDao;
  final Clock clock;
  final Session session;
  final SyncTrigger syncTrigger;

  static const _noSession = AuthFailure('budgets: no session');
  static const _notFound = NotFoundFailure('budget');

  /// `categories.type` of categories that can have a budget.
  static const _expenseType = 'expense';

  @override
  Stream<List<Budget>> watchMonth(DateTime month) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao.watchMonth(userId, month).map((rows) => [for (final row in rows) row.toEntity()]);
  }

  @override
  Stream<List<BudgetProgress>> watchMonthProgress(DateTime month) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao
        .watchMonthWithSpent(userId, month)
        .map(
          (rows) => [
            for (final row in rows)
              BudgetProgress(budget: row.budget.toEntity(), spent: Money(row.spentMinor)),
          ],
        );
  }

  @override
  Future<Result<Budget>> set({
    required DateTime month,
    String? categoryId,
    required Money limit,
  }) async {
    final invalid = BudgetValidator.validate(limit: limit, month: month, today: clock.now());
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    final id = BudgetValidator.idFor(userId: userId, month: month, categoryId: categoryId);
    return _guard('set', () async {
      final existing = await dao.getById(userId, id);
      if (categoryId != null) {
        final categoryProblem = await _checkCategory(
          userId,
          categoryId,
          // A live budget keeps its category even after that category was archived.
          isExistingBudget: existing != null && existing.deletedAt == null,
        );
        if (categoryProblem != null) return Result.failure(categoryProblem);
      }

      await _write(userId, id, existing, month: month, categoryId: categoryId, limit: limit);
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<int>> copyMonth({required DateTime from, required DateTime to}) async {
    final invalid = BudgetValidator.validateMonth(to, today: clock.now());
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('copyMonth', () async {
      // Keys (category id, null = overall) that already have a live budget in [to].
      final taken = {for (final row in await dao.getMonth(userId, to)) row.categoryId};
      var copied = 0;
      for (final source in await dao.getMonth(userId, from)) {
        final categoryId = source.categoryId;
        if (taken.contains(categoryId)) continue;
        if (categoryId != null &&
            await _checkCategory(userId, categoryId, isExistingBudget: false) != null) {
          continue;
        }
        final id = BudgetValidator.idFor(userId: userId, month: to, categoryId: categoryId);
        await _write(
          userId,
          id,
          await dao.getById(userId, id),
          month: to,
          categoryId: categoryId,
          limit: Money(source.limitMinor),
        );
        copied++;
      }
      if (copied > 0) syncTrigger.requestSync();
      return Result.success(copied);
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('delete', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null) return const Result.failure(_notFound);
      if (existing.deletedAt != null) return Result.ok;

      final now = clock.now().toUtc();
      await dao.updateBudget(
        userId,
        id,
        BudgetsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  /// Inserts the budget [id], or updates [existing] (restoring it if it was deleted).
  Future<void> _write(
    String userId,
    String id,
    BudgetRow? existing, {
    required DateTime month,
    required String? categoryId,
    required Money limit,
  }) async {
    final now = clock.now().toUtc();
    if (existing == null) {
      await dao.insertBudget(
        BudgetsCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          month: AppDateUtils.monthStart(month),
          categoryId: Value(categoryId),
          limitMinor: limit.minor,
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    } else {
      await dao.updateBudget(
        userId,
        id,
        BudgetsCompanion(
          limitMinor: Value(limit.minor),
          deletedAt: const Value(null),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
    }
  }

  /// The category must exist, be an expense category, and not be archived unless the budget
  /// already exists ([isExistingBudget]).
  Future<ValidationFailure?> _checkCategory(
    String userId,
    String categoryId, {
    required bool isExistingBudget,
  }) async {
    const field = BudgetValidator.categoryField;
    final category = await categoriesDao.getById(userId, categoryId);
    if (category == null) {
      return const ValidationFailure(BudgetValidator.categoryNotFound, field: field);
    }
    if (category.deletedAt != null && !isExistingBudget) {
      return const ValidationFailure(BudgetValidator.categoryArchived, field: field);
    }
    if (category.type != _expenseType) {
      return const ValidationFailure(BudgetValidator.categoryNotExpense, field: field);
    }
    return null;
  }

  /// Runs [body] in one DB transaction and turns any exception into a `StorageFailure`.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await dao.transaction(body);
    } catch (error, stackTrace) {
      AppLogger.error('budget $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('budget $operation: $error'));
    }
  }
}
