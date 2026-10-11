import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/features/categories/data/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/category_validator.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'user-1';
  final created = DateTime.utc(2026, 10, 1, 9);
  final later = DateTime.utc(2026, 10, 10, 18);

  late AppDatabase db;
  late FixedClock clock;
  late Session session;
  late CategoryRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    clock = FixedClock(created);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: userId));
    repository = CategoryRepositoryImpl(dao: db.categoriesDao, clock: clock, session: session);
  });

  CategoryDraft draft({
    String name = 'Food',
    CategoryType type = CategoryType.expense,
    String icon = 'food',
    int color = 0xFF4CAF50,
  }) => CategoryDraft(name: name, icon: icon, color: color, type: type);

  Future<Category> create({String name = 'Food', CategoryType type = CategoryType.expense}) async =>
      (await repository.create(draft(name: name, type: type))).valueOrNull!;

  Future<CategoryRow> row(String id) async => (await db.categoriesDao.getById(userId, id))!;

  String? reasonOf<T>(Result<T> result) => result.failureOrNull?.message;

  group('create', () {
    test('stores a trimmed, pending category owned by the user', () async {
      final result = await repository.create(draft(name: '  Food  '));

      final category = result.valueOrNull!;
      expect(category.name, 'Food');
      expect(category.isDefault, isFalse);
      expect(category.isArchived, isFalse);
      expect(category.createdAt, created);
      expect(category.updatedAt, created);

      final stored = await row(category.id);
      expect(stored.userId, userId);
      expect(stored.syncStatus, SyncStatus.pending);
      expect(stored.type, 'expense');
    });

    test('appends to the end of its type', () async {
      final food = await create();
      final transport = await create(name: 'Transport');
      final salary = await create(name: 'Salary', type: CategoryType.income);

      expect(food.sortOrder, 0);
      expect(transport.sortOrder, 1);
      expect(salary.sortOrder, 0);
    });

    test('rejects invalid input without writing', () async {
      final result = await repository.create(draft(name: ' '));

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await repository.watchAll().first, isEmpty);
    });

    test('rejects a duplicate active name of the same type, ignoring case', () async {
      await create();

      expect(reasonOf(await repository.create(draft(name: 'FOOD'))), 'duplicateName');
      expect(
        (await repository.create(draft(name: 'Food', type: CategoryType.income))).isSuccess,
        isTrue,
      );
    });

    test('an archived name can be used again', () async {
      final old = await create();
      await repository.archive(old.id);

      expect((await repository.create(draft())).isSuccess, isTrue);
    });

    test('fails with AuthFailure without a session', () async {
      session.set(null);
      expect((await repository.create(draft())).failureOrNull, isA<AuthFailure>());
    });
  });

  group('watch', () {
    test('watchAll lists active categories in order, optionally by type', () async {
      await create(name: 'Food');
      await create(name: 'Bills');
      await create(name: 'Salary', type: CategoryType.income);
      final gone = await create(name: 'Gone');
      await repository.archive(gone.id);

      final expense = await repository.watchAll(type: CategoryType.expense).first;
      final all = await repository.watchAll().first;

      expect(expense.map((c) => c.name), ['Food', 'Bills']);
      expect(all, hasLength(3));
    });

    test('watchById includes archived categories', () async {
      final food = await create();
      await repository.archive(food.id);

      final watched = await repository.watchById(food.id).first;

      expect(watched?.isArchived, isTrue);
    });

    test('emits nothing for a signed-out user', () async {
      await create();
      session.set(null);

      expect(await repository.watchAll().first, isEmpty);
      expect(await repository.watchById('any').first, isNull);
    });
  });

  group('update', () {
    test('saves the editable fields, keeps createdAt, and marks it pending', () async {
      final food = await create();
      await db.categoriesDao.updateCategory(
        userId,
        food.id,
        const CategoriesCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock.current = later;

      final result = await repository.update(
        food.copyWith(name: ' Groceries ', icon: 'cart', color: 0xFF2196F3),
      );

      final updated = result.valueOrNull!;
      expect(updated.name, 'Groceries');
      expect(updated.icon, 'cart');
      expect(updated.color, 0xFF2196F3);
      expect(updated.createdAt, created);
      expect(updated.updatedAt, later);
      expect((await row(food.id)).syncStatus, SyncStatus.pending);
    });

    test('rejects invalid values and leaves the stored row unchanged', () async {
      final food = await create();

      expect(
        reasonOf(await repository.update(food.copyWith(name: '  '))),
        CategoryValidator.nameRequired,
      );
      expect(
        reasonOf(await repository.update(food.copyWith(icon: ''))),
        CategoryValidator.iconRequired,
      );
      expect(
        reasonOf(await repository.update(food.copyWith(color: -1))),
        CategoryValidator.invalidColor,
      );
      final stored = await row(food.id);
      expect(stored.name, 'Food');
      expect(stored.icon, 'food');
    });

    test('a missing or archived category is not found', () async {
      final food = await create();
      await repository.archive(food.id);

      expect((await repository.update(food)).failureOrNull, isA<NotFoundFailure>());
      expect(
        (await repository.update(food.copyWith(id: IdGenerator.newId()))).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });

    test('rejects another category’s name but allows changing its own case', () async {
      final food = await create();
      await create(name: 'Bills');

      expect(reasonOf(await repository.update(food.copyWith(name: 'bills'))), 'duplicateName');
      expect((await repository.update(food.copyWith(name: 'FOOD'))).isSuccess, isTrue);
    });

    test('the type is locked while transactions use the category', () async {
      final food = await create();
      final unused = await create(name: 'Gift');
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: IdGenerator.newId(),
              userId: userId,
              createdAt: created,
              updatedAt: created,
              type: 'expense',
              amountMinor: 1200,
              categoryId: food.id,
              occurredOn: DateTime(2026, 10, 3),
            ),
          );

      final locked = await repository.update(food.copyWith(type: CategoryType.income));
      final free = await repository.update(unused.copyWith(type: CategoryType.income));

      expect(reasonOf(locked), 'typeLockedByTransactions');
      expect(free.valueOrNull?.type, CategoryType.income);
    });
  });

  group('archive', () {
    test('soft-deletes and marks pending', () async {
      final food = await create();
      clock.current = later;

      final result = await repository.archive(food.id);

      expect(result.isSuccess, isTrue);
      final stored = await row(food.id);
      expect(stored.deletedAt, later);
      expect(stored.updatedAt, later);
      expect(stored.syncStatus, SyncStatus.pending);
      expect(await repository.watchAll().first, isEmpty);
    });

    test('is idempotent and keeps the first archive time', () async {
      final food = await create();
      await repository.archive(food.id);
      clock.current = later;

      expect((await repository.archive(food.id)).isSuccess, isTrue);
      expect((await row(food.id)).deletedAt, created);
    });

    test('a missing category is not found', () async {
      expect((await repository.archive('missing')).failureOrNull, isA<NotFoundFailure>());
    });
  });

  test('a database error becomes a StorageFailure', () async {
    await db.customStatement('DROP TABLE transactions');
    await db.customStatement('DROP TABLE categories');

    expect((await repository.create(draft())).failureOrNull, isA<StorageFailure>());
  });

  group('seedDefaults', () {
    final seeds = [
      for (final spec in DefaultCategories.all)
        DefaultCategorySeed(spec: spec, name: 'Name ${spec.key}'),
    ];
    String idOf(String key) => DefaultCategories.idFor(userId, key);

    test('inserts every default with deterministic ids and the seed timestamp', () async {
      final result = await repository.seedDefaults(seeds);

      expect(result.valueOrNull, DefaultCategories.all.length);
      final food = await row(idOf('food'));
      expect(food.name, 'Name food');
      expect(food.icon, 'food');
      expect(food.isDefault, isTrue);
      expect(food.createdAt, DefaultCategories.seedTimestamp);
      expect(food.updatedAt, DefaultCategories.seedTimestamp);
      expect(food.syncStatus, SyncStatus.pending);
      expect(food.userId, userId);
    });

    test('orders defaults within their type', () async {
      await repository.seedDefaults(seeds);

      final expense = await repository.watchAll(type: CategoryType.expense).first;
      final income = await repository.watchAll(type: CategoryType.income).first;

      expect(expense.first.name, 'Name food');
      expect(expense.last.name, 'Name other');
      expect(income.first.name, 'Name salary');
      expect(income.map((c) => c.sortOrder), [0, 1, 2, 3, 4]);
    });

    test('is idempotent', () async {
      await repository.seedDefaults(seeds);

      final again = await repository.seedDefaults(seeds);

      expect(again.valueOrNull, 0);
      expect(await repository.watchAll().first, hasLength(DefaultCategories.all.length));
    });

    test('never revives an archived default or undoes an edit', () async {
      await repository.seedDefaults(seeds);
      await repository.archive(idOf('education'));
      final food = (await repository.watchById(idOf('food')).first)!;
      await repository.update(food.copyWith(name: 'Groceries'));

      await repository.seedDefaults(seeds);

      expect((await row(idOf('education'))).deletedAt, isNotNull);
      expect((await row(idOf('food'))).name, 'Groceries');
    });

    test('skips a default whose name an active category already uses', () async {
      await create(name: 'name FOOD');

      final result = await repository.seedDefaults(seeds);

      expect(result.valueOrNull, DefaultCategories.all.length - 1);
      expect(await db.categoriesDao.getById(userId, idOf('food')), isNull);
    });

    test('fails with AuthFailure without a session', () async {
      session.set(null);
      expect((await repository.seedDefaults(seeds)).failureOrNull, isA<AuthFailure>());
    });

    test('an invalid seed fails the whole batch without inserting anything', () async {
      final result = await repository.seedDefaults([
        ...seeds,
        DefaultCategorySeed(spec: DefaultCategories.all.first, name: ' '),
      ]);

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await repository.watchAll().first, isEmpty);
    });
  });
}
