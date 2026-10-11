import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/categories_dao.dart';
import 'package:expense_tracker/core/db/daos/transactions_dao.dart';
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
import 'package:expense_tracker/features/transactions/data/mappers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/category_spending.dart';
import 'package:expense_tracker/features/transactions/domain/entities/day_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';

/// [TransactionRepository] backed by the local `transactions` table.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required this.dao,
    required this.categoriesDao,
    required this.clock,
    required this.session,
    required this.syncTrigger,
  });

  final TransactionsDao dao;
  final CategoriesDao categoriesDao;
  final Clock clock;
  final Session session;
  final SyncTrigger syncTrigger;

  static const _noSession = AuthFailure('transactions: no session');
  static const _notFound = NotFoundFailure('transaction');

  @override
  Stream<List<Transaction>> watch(TransactionFilter filter) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    final range = filter.range;
    return dao
        .watchFiltered(
          userId,
          from: range.start,
          to: range.end,
          type: filter.type?.dbValue,
          categoryId: filter.categoryId,
        )
        .map((rows) => [for (final row in rows) row.toEntity()]);
  }

  @override
  Stream<List<CategorySpending>> watchMonthSpendingByCategory(DateTime month) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao
        .watchMonthSpendingByCategory(userId, month)
        .map(
          (rows) => [
            for (final row in rows)
              CategorySpending(categoryId: row.categoryId, amount: Money(row.spentMinor)),
          ],
        );
  }

  @override
  Stream<List<DayTotals>> watchMonthDailyTotals(DateTime month) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao
        .watchMonthDailyTotals(userId, month)
        .map(
          (rows) => [
            for (final row in rows)
              DayTotals(
                date: row.day,
                income: Money(row.incomeMinor),
                expense: Money(row.expenseMinor),
              ),
          ],
        );
  }

  @override
  Stream<MonthTotals> watchMonthTotals(DateTime month) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(MonthTotals.zero);
    return dao
        .watchMonthTotals(userId, month)
        .map(
          (totals) => MonthTotals(
            income: Money(totals.incomeMinor),
            expense: Money(totals.expenseMinor),
          ),
        );
  }

  @override
  Stream<Transaction?> watchById(String id) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(null);
    return dao.watchById(userId, id).map((row) => row?.toEntity());
  }

  @override
  Future<Result<Transaction>> getById(String id) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);
    return _guard('getById', () async {
      final row = await dao.getById(userId, id);
      if (row == null || row.deletedAt != null) return const Result.failure(_notFound);
      return Result.success(row.toEntity());
    });
  }

  @override
  Future<Result<Transaction>> create(TransactionDraft draft) async {
    final invalid = _validate(draft.amount.minor, draft.occurredOn, draft.note);
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('create', () async {
      final categoryProblem = await _checkCategory(userId, draft.categoryId, draft.type);
      if (categoryProblem != null) return Result.failure(categoryProblem);

      final id = IdGenerator.newId();
      final now = clock.now().toUtc();
      await dao.insertTransaction(
        TransactionsCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          type: draft.type.dbValue,
          amountMinor: draft.amount.minor,
          categoryId: draft.categoryId,
          occurredOn: AppDateUtils.dateOnly(draft.occurredOn),
          note: Value(TransactionValidator.normalizeNote(draft.note)),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) async {
    final invalid = _validate(transaction.amount.minor, transaction.occurredOn, transaction.note);
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('update', () async {
      final existing = await dao.getById(userId, transaction.id);
      if (existing == null || existing.deletedAt != null) return const Result.failure(_notFound);

      final categoryProblem = await _checkCategory(
        userId,
        transaction.categoryId,
        transaction.type,
        // A transaction keeps its category even after that category was archived (M2.5).
        currentCategoryId: existing.categoryId,
      );
      if (categoryProblem != null) return Result.failure(categoryProblem);

      await dao.updateTransaction(
        userId,
        transaction.id,
        TransactionsCompanion(
          type: Value(transaction.type.dbValue),
          amountMinor: Value(transaction.amount.minor),
          categoryId: Value(transaction.categoryId),
          occurredOn: Value(AppDateUtils.dateOnly(transaction.occurredOn)),
          note: Value(TransactionValidator.normalizeNote(transaction.note)),
          updatedAt: Value(clock.now().toUtc()),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, transaction.id))!.toEntity());
    });
  }

  @override
  Future<Result<void>> delete(String id) => _setDeleted(id, deleted: true);

  @override
  Future<Result<void>> restore(String id) => _setDeleted(id, deleted: false);

  Future<Result<void>> _setDeleted(String id, {required bool deleted}) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard(deleted ? 'delete' : 'restore', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null) return const Result.failure(_notFound);
      if ((existing.deletedAt != null) == deleted) return Result.ok;

      final now = clock.now().toUtc();
      await dao.updateTransaction(
        userId,
        id,
        TransactionsCompanion(
          deletedAt: Value(deleted ? now : null),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  ValidationFailure? _validate(int amountMinor, DateTime occurredOn, String? note) =>
      TransactionValidator.validate(
        amount: Money(amountMinor),
        occurredOn: occurredOn,
        note: note,
        today: clock.now(),
      );

  /// The category must exist, match [type], and not be archived unless it is already the
  /// transaction's category ([currentCategoryId]).
  Future<ValidationFailure?> _checkCategory(
    String userId,
    String categoryId,
    TransactionType type, {
    String? currentCategoryId,
  }) async {
    const field = TransactionValidator.categoryField;
    final category = await categoriesDao.getById(userId, categoryId);
    if (category == null) {
      return const ValidationFailure(TransactionValidator.categoryNotFound, field: field);
    }
    if (category.deletedAt != null && categoryId != currentCategoryId) {
      return const ValidationFailure(TransactionValidator.categoryArchived, field: field);
    }
    if (category.type != type.dbValue) {
      return const ValidationFailure(TransactionValidator.categoryTypeMismatch, field: field);
    }
    return null;
  }

  /// Runs [body] in one DB transaction and turns any exception into a `StorageFailure`.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await dao.transaction(body);
    } catch (error, stackTrace) {
      AppLogger.error('transaction $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('transaction $operation: $error'));
    }
  }
}
