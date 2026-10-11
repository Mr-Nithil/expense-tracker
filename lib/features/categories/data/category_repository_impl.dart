import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/categories_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/features/categories/data/mappers.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/category_validator.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';

/// [CategoryRepository] backed by the local `categories` table.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({required this.dao, required this.clock, required this.session});

  final CategoriesDao dao;
  final Clock clock;
  final Session session;

  static const _duplicateName = ValidationFailure(
    CategoryValidator.duplicateName,
    field: CategoryValidator.nameField,
  );
  static const _noSession = AuthFailure('categories: no session');

  @override
  Stream<List<Category>> watchAll({CategoryType? type}) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao
        .watchActive(userId, type: type?.dbValue)
        .map((rows) => [for (final row in rows) row.toEntity()]);
  }

  @override
  Stream<Category?> watchById(String id) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(null);
    return dao.watchById(userId, id).map((row) => row?.toEntity());
  }

  @override
  Future<Result<Category>> create(CategoryDraft draft) async {
    final invalid = CategoryValidator.validate(
      name: draft.name,
      icon: draft.icon,
      color: draft.color,
    );
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('create', () async {
      final name = draft.name.trim();
      final type = draft.type.dbValue;
      if (await dao.activeNameExists(userId, type, name)) {
        return const Result.failure(_duplicateName);
      }

      final id = IdGenerator.newId();
      final now = clock.now().toUtc();
      final lastOrder = await dao.maxSortOrder(userId, type);
      await dao.insertCategory(
        CategoriesCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          name: name,
          icon: draft.icon,
          color: draft.color,
          type: type,
          sortOrder: Value((lastOrder ?? -1) + 1),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      // TODO(M3.6): syncTrigger.requestSync().
      return Result.success((await dao.getById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<Category>> update(Category category) async {
    final invalid = CategoryValidator.validate(
      name: category.name,
      icon: category.icon,
      color: category.color,
    );
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('update', () async {
      final existing = await dao.getById(userId, category.id);
      if (existing == null || existing.deletedAt != null) {
        return const Result.failure(NotFoundFailure('category'));
      }

      final name = category.name.trim();
      final type = category.type.dbValue;
      if (await dao.activeNameExists(userId, type, name, excludeId: category.id)) {
        return const Result.failure(_duplicateName);
      }
      // Transactions must keep a category of their own type (M2.8).
      if (type != existing.type && await dao.countActiveTransactions(userId, category.id) > 0) {
        return const Result.failure(
          ValidationFailure(
            CategoryValidator.typeLockedByTransactions,
            field: CategoryValidator.typeField,
          ),
        );
      }

      await dao.updateCategory(
        userId,
        category.id,
        CategoriesCompanion(
          name: Value(name),
          icon: Value(category.icon),
          color: Value(category.color),
          type: Value(type),
          updatedAt: Value(clock.now().toUtc()),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      // TODO(M3.6): syncTrigger.requestSync().
      return Result.success((await dao.getById(userId, category.id))!.toEntity());
    });
  }

  @override
  Future<Result<void>> archive(String id) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('archive', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null) return const Result.failure(NotFoundFailure('category'));
      if (existing.deletedAt != null) return Result.ok;

      final now = clock.now().toUtc();
      await dao.updateCategory(
        userId,
        id,
        CategoriesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      // TODO(M3.6): syncTrigger.requestSync().
      return Result.ok;
    });
  }

  @override
  Future<Result<int>> seedDefaults(List<DefaultCategorySeed> seeds) async {
    for (final seed in seeds) {
      final invalid = CategoryValidator.validate(
        name: seed.name,
        icon: seed.spec.icon,
        color: seed.spec.color,
      );
      if (invalid != null) return Result.failure(invalid);
    }
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('seedDefaults', () async {
      final at = DefaultCategories.seedTimestamp;
      final positionByType = <String, int>{};
      var inserted = 0;

      for (final seed in seeds) {
        final type = seed.spec.type.dbValue;
        final name = seed.name.trim();
        final position = positionByType.update(type, (p) => p + 1, ifAbsent: () => 0);
        final id = DefaultCategories.idFor(userId, seed.spec.key);

        if (await dao.getById(userId, id) != null) continue;
        if (await dao.activeNameExists(userId, type, name)) continue;

        await dao.insertCategory(
          CategoriesCompanion.insert(
            id: id,
            userId: userId,
            createdAt: at,
            updatedAt: at,
            name: name,
            icon: seed.spec.icon,
            color: seed.spec.color,
            type: type,
            isDefault: const Value(true),
            sortOrder: Value(position),
            syncStatus: const Value(SyncStatus.pending),
          ),
        );
        inserted++;
      }
      // TODO(M3.6): syncTrigger.requestSync().
      return Result.success(inserted);
    });
  }

  /// Runs [body] in one DB transaction and turns any exception into a `StorageFailure`.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await dao.transaction(body);
    } catch (error, stackTrace) {
      AppLogger.error('category $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('category $operation: $error'));
    }
  }
}
