import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_impl.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_sync_trigger.dart';
import '../../../helpers/test_database.dart';

void main() {
  const userId = 'user-1';
  final created = DateTime.utc(2026, 10, 11, 9);
  final later = DateTime.utc(2026, 10, 12, 18);
  final october = DateTime(2026, 10);

  late AppDatabase db;
  late FixedClock clock;
  late Session session;
  late BudgetRepositoryImpl repository;
  late FakeSyncTrigger trigger;
  late String food;

  Future<String> category(String name, String type, {bool archived = false}) async {
    final id = IdGenerator.newId();
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: id,
        userId: userId,
        createdAt: created,
        updatedAt: created,
        name: name,
        icon: 'food',
        color: 0,
        type: type,
        deletedAt: Value(archived ? created : null),
      ),
    );
    return id;
  }

  BudgetRepositoryImpl repositoryFor(AppDatabase database, Session session) => BudgetRepositoryImpl(
    dao: database.budgetsDao,
    categoriesDao: database.categoriesDao,
    clock: clock,
    session: session,
    syncTrigger: trigger,
  );

  setUp(() async {
    db = createTestDatabase();
    clock = FixedClock(created);
    trigger = FakeSyncTrigger();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: userId));
    repository = repositoryFor(db, session);
    food = await category('Food', 'expense');
  });

  Future<BudgetRow> rowOf(String id) async => (await db.budgetsDao.getById(userId, id))!;

  group('set', () {
    test('creates the overall budget with the deterministic id, pending sync', () async {
      final result = await repository.set(month: DateTime(2026, 10, 20), limit: const Money(50000));

      final budget = result.valueOrNull!;
      expect(budget.id, BudgetValidator.idFor(userId: userId, month: october));
      expect(budget.isOverall, isTrue);
      expect(budget.month, october);
      expect(budget.limit, const Money(50000));
      expect(budget.createdAt, created);
      final row = await rowOf(budget.id);
      expect(row.syncStatus, SyncStatus.pending);
      expect(trigger.requests, 1);
    });

    test('creates a category budget', () async {
      final budget = (await repository.set(
        month: october,
        categoryId: food,
        limit: const Money(1000),
      )).valueOrNull!;

      expect(budget.categoryId, food);
      expect(budget.id, BudgetValidator.idFor(userId: userId, month: october, categoryId: food));
    });

    test('setting the same key again updates the one row', () async {
      final first = (await repository.set(month: october, limit: const Money(100))).valueOrNull!;
      await db.budgetsDao.updateBudget(
        userId,
        first.id,
        const BudgetsCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock = FixedClock(later);
      repository = repositoryFor(db, session);

      final second = (await repository.set(
        month: DateTime(2026, 10, 31),
        limit: const Money(200),
      )).valueOrNull!;

      expect(second.id, first.id);
      expect(second.limit, const Money(200));
      expect(second.createdAt, created);
      expect(second.updatedAt, later);
      expect((await rowOf(first.id)).syncStatus, SyncStatus.pending);
      expect(await repository.watchMonth(october).first, [second]);
    });

    test('setting a deleted budget again restores it', () async {
      final first = (await repository.set(month: october, limit: const Money(100))).valueOrNull!;
      await repository.delete(first.id);

      final restored = await repository.set(month: october, limit: const Money(300));

      expect(restored.valueOrNull?.id, first.id);
      expect((await rowOf(first.id)).deletedAt, isNull);
      expect((await repository.watchMonth(october).first).single.limit, const Money(300));
    });

    test('two devices setting the same budget offline produce the same id', () async {
      final otherDb = createTestDatabase();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final otherSession = container.read(sessionProvider.notifier)
        ..set(const SessionUser(userId: userId));

      final here = await repository.set(month: october, limit: const Money(100));
      final there = await repositoryFor(otherDb, otherSession).set(
        month: DateTime(2026, 10, 3),
        limit: const Money(200),
      );

      expect(here.valueOrNull!.id, there.valueOrNull!.id);
    });

    test('rejects an invalid limit or month before touching the DB', () async {
      expect(
        (await repository.set(month: october, limit: Money.zero)).failureOrNull,
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          BudgetValidator.limitNotPositive,
        ),
      );
      expect(
        (await repository.set(month: DateTime(2028), limit: const Money(1))).failureOrNull,
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          BudgetValidator.monthOutOfRange,
        ),
      );
      expect(trigger.requests, 0);
    });

    group('category', () {
      Future<String?> reasonFor(String categoryId) async =>
          ((await repository.set(
                    month: october,
                    categoryId: categoryId,
                    limit: const Money(1),
                  )).failureOrNull
                  as ValidationFailure?)
              ?.message;

      test('must exist', () async {
        expect(await reasonFor('missing'), BudgetValidator.categoryNotFound);
      });

      test('must be an expense category', () async {
        expect(
          await reasonFor(await category('Salary', 'income')),
          BudgetValidator.categoryNotExpense,
        );
      });

      test('must not be archived for a new budget', () async {
        expect(
          await reasonFor(await category('Old', 'expense', archived: true)),
          BudgetValidator.categoryArchived,
        );
      });

      test('an existing budget can still be changed after its category was archived', () async {
        await repository.set(month: october, categoryId: food, limit: const Money(1));
        await db.categoriesDao.updateCategory(
          userId,
          food,
          CategoriesCompanion(deletedAt: Value(created)),
        );

        expect(await reasonFor(food), isNull);
      });

      test('a deleted budget is not revived for an archived category', () async {
        final budget = (await repository.set(
          month: october,
          categoryId: food,
          limit: const Money(1),
        )).valueOrNull!;
        await repository.delete(budget.id);
        await db.categoriesDao.updateCategory(
          userId,
          food,
          CategoriesCompanion(deletedAt: Value(created)),
        );

        expect(await reasonFor(food), BudgetValidator.categoryArchived);
      });
    });

    test('fails without a session', () async {
      session.set(null);

      final result = await repository.set(month: october, limit: const Money(1));

      expect(result.failureOrNull, isA<AuthFailure>());
    });
  });

  group('watchMonth', () {
    test('lists the month\'s budgets, overall first', () async {
      await repository.set(month: october, categoryId: food, limit: const Money(1));
      await repository.set(month: october, limit: const Money(2));
      await repository.set(month: DateTime(2026, 11), limit: const Money(3));

      final budgets = await repository.watchMonth(DateTime(2026, 10, 15)).first;

      expect(budgets.map((b) => b.categoryId), [null, food]);
    });

    test('is empty without a session', () async {
      await repository.set(month: october, limit: const Money(2));
      session.set(null);

      expect(await repository.watchMonth(october).first, isEmpty);
    });
  });

  group('watchMonthProgress', () {
    test('pairs each budget with what was spent', () async {
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: IdGenerator.newId(),
          userId: userId,
          createdAt: created,
          updatedAt: created,
          type: 'expense',
          amountMinor: 8000,
          categoryId: food,
          occurredOn: DateTime(2026, 10, 5),
        ),
      );
      await repository.set(month: october, limit: const Money(10000));
      await repository.set(month: october, categoryId: food, limit: const Money(5000));

      final progress = await repository.watchMonthProgress(october).first;

      expect(progress.map((p) => (p.budget.categoryId, p.spent, p.percentUsed)), [
        (null, const Money(8000), 80),
        (food, const Money(8000), 160),
      ]);
      expect(progress.last.remaining, const Money(-3000));
    });

    test('is empty without a session', () async {
      await repository.set(month: october, limit: const Money(2));
      session.set(null);

      expect(await repository.watchMonthProgress(october).first, isEmpty);
    });
  });

  group('copyMonth', () {
    final september = DateTime(2026, 9);

    Future<Map<String?, int>> limitsOf(DateTime month) async => {
      for (final budget in await repository.watchMonth(month).first)
        budget.categoryId: budget.limit.minor,
    };

    test('copies every budget with its limit and the target month\'s ids, pending sync', () async {
      await repository.set(month: september, limit: const Money(50000));
      await repository.set(month: september, categoryId: food, limit: const Money(20000));
      final requestsBefore = trigger.requests;

      final result = await repository.copyMonth(from: september, to: DateTime(2026, 10, 15));

      expect(result.valueOrNull, 2);
      expect(await limitsOf(october), {null: 50000, food: 20000});
      final overall = await rowOf(BudgetValidator.idFor(userId: userId, month: october));
      expect(overall.month, october);
      expect(overall.syncStatus, SyncStatus.pending);
      expect(await limitsOf(september), {null: 50000, food: 20000});
      expect(trigger.requests, requestsBefore + 1);
    });

    test('keeps budgets the target month already has', () async {
      await repository.set(month: september, limit: const Money(50000));
      await repository.set(month: september, categoryId: food, limit: const Money(20000));
      await repository.set(month: october, limit: const Money(70000));

      final result = await repository.copyMonth(from: september, to: october);

      expect(result.valueOrNull, 1);
      expect(await limitsOf(october), {null: 70000, food: 20000});
    });

    test('restores a deleted budget instead of adding a second row', () async {
      await repository.set(month: september, limit: const Money(50000));
      final deleted = (await repository.set(month: october, limit: const Money(1))).valueOrNull!;
      await repository.delete(deleted.id);

      expect((await repository.copyMonth(from: september, to: october)).valueOrNull, 1);

      final row = await rowOf(deleted.id);
      expect(row.deletedAt, isNull);
      expect(row.limitMinor, 50000);
    });

    test('skips categories that were archived since', () async {
      await repository.set(month: september, categoryId: food, limit: const Money(20000));
      await db.categoriesDao.updateCategory(
        userId,
        food,
        CategoriesCompanion(deletedAt: Value(created)),
      );

      expect((await repository.copyMonth(from: september, to: october)).valueOrNull, 0);
      expect(await limitsOf(october), isEmpty);
    });

    test('nothing to copy is 0 and requests no sync', () async {
      final result = await repository.copyMonth(from: september, to: october);

      expect(result.valueOrNull, 0);
      expect(trigger.requests, 0);
    });

    test('rejects a target month out of range, and fails without a session', () async {
      final outOfRange = await repository.copyMonth(from: october, to: DateTime(2030));
      expect(
        (outOfRange.failureOrNull! as ValidationFailure).message,
        BudgetValidator.monthOutOfRange,
      );

      session.set(null);
      expect(
        (await repository.copyMonth(from: september, to: october)).failureOrNull,
        isA<AuthFailure>(),
      );
    });
  });

  group('delete', () {
    test('soft deletes, pending sync', () async {
      final budget = (await repository.set(month: october, limit: const Money(1))).valueOrNull!;
      await db.budgetsDao.updateBudget(
        userId,
        budget.id,
        const BudgetsCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock = FixedClock(later);
      repository = repositoryFor(db, session);

      expect(await repository.delete(budget.id), Result.ok);

      final row = await rowOf(budget.id);
      expect(row.deletedAt, later);
      expect(row.updatedAt, later);
      expect(row.syncStatus, SyncStatus.pending);
      expect(await repository.watchMonth(october).first, isEmpty);
      expect(trigger.requests, 2);
    });

    test('deleting twice is a no-op', () async {
      final budget = (await repository.set(month: october, limit: const Money(1))).valueOrNull!;
      await repository.delete(budget.id);

      expect(await repository.delete(budget.id), Result.ok);
      expect(trigger.requests, 2);
    });

    test('an unknown id is NotFound', () async {
      expect((await repository.delete('missing')).failureOrNull, isA<NotFoundFailure>());
    });

    test('fails without a session', () async {
      session.set(null);
      expect((await repository.delete('x')).failureOrNull, isA<AuthFailure>());
    });
  });

  test('a database error becomes a StorageFailure instead of throwing', () async {
    final budget = (await repository.set(month: october, limit: const Money(1))).valueOrNull!;
    await db.customStatement('DROP TABLE budgets');

    expect(
      (await repository.set(month: october, limit: const Money(2))).failureOrNull,
      isA<StorageFailure>(),
    );
    expect(
      (await repository.copyMonth(from: DateTime(2026, 9), to: october)).failureOrNull,
      isA<StorageFailure>(),
    );
    expect((await repository.delete(budget.id)).failureOrNull, isA<StorageFailure>());
  });
}
