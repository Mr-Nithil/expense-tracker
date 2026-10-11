import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/entities/category_spending.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_sync_trigger.dart';
import '../../../helpers/test_database.dart';

void main() {
  const userId = 'user-1';
  final created = DateTime.utc(2026, 10, 11, 9);
  final later = DateTime.utc(2026, 10, 12, 18);
  final october = TransactionFilter(month: DateTime(2026, 10));

  late AppDatabase db;
  late FixedClock clock;
  late Session session;
  late TransactionRepositoryImpl repository;
  late FakeSyncTrigger trigger;
  late String food;
  late String salary;

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

  setUp(() async {
    db = createTestDatabase();
    clock = FixedClock(created);
    trigger = FakeSyncTrigger();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: userId));
    repository = TransactionRepositoryImpl(
      dao: db.transactionsDao,
      categoriesDao: db.categoriesDao,
      clock: clock,
      session: session,
      syncTrigger: trigger,
    );
    food = await category('Food', 'expense');
    salary = await category('Salary', 'income');
  });

  TransactionDraft draft({
    TransactionType type = TransactionType.expense,
    int amount = 1200,
    String? categoryId,
    DateTime? on,
    String? note,
  }) => TransactionDraft(
    type: type,
    amount: Money(amount),
    categoryId: categoryId ?? (type == TransactionType.expense ? food : salary),
    occurredOn: on ?? DateTime(2026, 10, 11),
    note: note,
  );

  Future<Transaction> create([TransactionDraft? d]) async =>
      (await repository.create(d ?? draft())).valueOrNull!;

  Future<TransactionRow> row(String id) async => (await db.transactionsDao.getById(userId, id))!;

  String? reasonOf<T>(Result<T> result) => result.failureOrNull?.message;

  group('create', () {
    test('stores a pending transaction with a date-only day and trimmed note', () async {
      final result = await repository.create(
        draft(on: DateTime(2026, 10, 11, 21, 45), note: '  lunch  '),
      );

      final tx = result.valueOrNull!;
      expect(tx.amount, const Money(1200));
      expect(tx.occurredOn, DateTime(2026, 10, 11));
      expect(tx.note, 'lunch');
      expect(tx.isDeleted, isFalse);
      expect(tx.createdAt, created);
      final stored = await row(tx.id);
      expect(stored.userId, userId);
      expect(stored.syncStatus, SyncStatus.pending);
      expect(stored.type, 'expense');
    });

    test('an empty note is stored as null', () async {
      expect((await create(draft(note: '   '))).note, isNull);
    });

    test('rejects invalid amount, date and note without writing', () async {
      expect(
        reasonOf(await repository.create(draft(amount: 0))),
        TransactionValidator.amountNotPositive,
      );
      expect(
        reasonOf(await repository.create(draft(on: DateTime(2027, 10, 12)))),
        TransactionValidator.dateOutOfRange,
      );
      expect(
        reasonOf(await repository.create(draft(note: 'x' * 501))),
        TransactionValidator.noteTooLong,
      );
      expect(await repository.watch(october).first, isEmpty);
    });

    test('the category must exist, match the type and be active', () async {
      final archived = await category('Old', 'expense', archived: true);

      expect(
        reasonOf(await repository.create(draft(categoryId: 'missing'))),
        TransactionValidator.categoryNotFound,
      );
      expect(
        reasonOf(await repository.create(draft(categoryId: salary))),
        TransactionValidator.categoryTypeMismatch,
      );
      expect(
        reasonOf(await repository.create(draft(categoryId: archived))),
        TransactionValidator.categoryArchived,
      );
    });

    test('fails with AuthFailure without a session', () async {
      session.set(null);
      expect((await repository.create(draft())).failureOrNull, isA<AuthFailure>());
    });
  });

  group('watch', () {
    test('lists one month, newest first, narrowed by type and category', () async {
      final older = await create(draft(on: DateTime(2026, 10, 2)));
      final newer = await create(draft(on: DateTime(2026, 10, 9)));
      final income = await create(draft(type: TransactionType.income, on: DateTime(2026, 10, 5)));
      await create(draft(on: DateTime(2026, 11)));
      await create(draft(on: DateTime(2026, 9, 30)));

      List<String> ids(List<Transaction> list) => [for (final t in list) t.id];

      expect(ids(await repository.watch(october).first), [newer.id, income.id, older.id]);
      expect(
        ids(await repository.watch(october.copyWith(type: TransactionType.income)).first),
        [income.id],
      );
      expect(
        ids(await repository.watch(october.copyWith(categoryId: food)).first),
        [newer.id, older.id],
      );
    });

    test('is empty for a signed-out user', () async {
      await create();
      session.set(null);
      expect(await repository.watch(october).first, isEmpty);
      expect(await repository.watchById('any').first, isNull);
    });
  });

  group('watchMonthTotals', () {
    test('sums the month\'s income and expenses', () async {
      await create(draft(type: TransactionType.income, amount: 500000));
      await create(draft(amount: 1250));
      await create(draft(amount: 750, on: DateTime(2026, 10, 31)));
      await create(draft(amount: 999, on: DateTime(2026, 11)));

      final totals = await repository.watchMonthTotals(DateTime(2026, 10, 20)).first;

      expect(totals, const MonthTotals(income: Money(500000), expense: Money(2000)));
      expect(totals.balance, const Money(498000));
    });

    test('is zero for a signed-out user', () async {
      await create();
      session.set(null);
      expect(await repository.watchMonthTotals(DateTime(2026, 10)).first, MonthTotals.zero);
    });
  });

  group('watchMonthSpendingByCategory', () {
    test('lists the month\'s expenses per category, largest first', () async {
      final rent = await category('Rent', 'expense');
      await create(draft(amount: 500));
      await create(draft(amount: 2000, categoryId: rent));
      await create(draft(type: TransactionType.income, amount: 900000));

      expect(await repository.watchMonthSpendingByCategory(DateTime(2026, 10)).first, [
        CategorySpending(categoryId: rent, amount: const Money(2000)),
        CategorySpending(categoryId: food, amount: const Money(500)),
      ]);
    });

    test('is empty for a signed-out user', () async {
      await create();
      session.set(null);
      expect(await repository.watchMonthSpendingByCategory(DateTime(2026, 10)).first, isEmpty);
    });
  });

  group('getById', () {
    test('returns a transaction and hides deleted ones', () async {
      final tx = await create();
      expect((await repository.getById(tx.id)).valueOrNull?.id, tx.id);

      await repository.delete(tx.id);

      expect((await repository.getById(tx.id)).failureOrNull, isA<NotFoundFailure>());
      expect((await repository.watchById(tx.id).first)?.isDeleted, isTrue);
    });
  });

  group('update', () {
    test('saves the fields, keeps createdAt, and marks it pending', () async {
      final tx = await create();
      await db.transactionsDao.updateTransaction(
        userId,
        tx.id,
        const TransactionsCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock.current = later;

      final result = await repository.update(
        tx.copyWith(amount: const Money(4500), occurredOn: DateTime(2026, 10, 1), note: ' dinner '),
      );

      final updated = result.valueOrNull!;
      expect(updated.amount, const Money(4500));
      expect(updated.occurredOn, DateTime(2026, 10, 1));
      expect(updated.note, 'dinner');
      expect(updated.createdAt, created);
      expect(updated.updatedAt, later);
      expect((await row(tx.id)).syncStatus, SyncStatus.pending);
    });

    test('keeps a category that was archived after the transaction used it', () async {
      final tx = await create();
      await db.categoriesDao.updateCategory(
        userId,
        food,
        CategoriesCompanion(deletedAt: Value(created)),
      );

      final result = await repository.update(tx.copyWith(amount: const Money(999)));

      expect(result.valueOrNull?.categoryId, food);
    });

    test('cannot switch to an archived or mismatched category', () async {
      final tx = await create();
      final archived = await category('Old', 'expense', archived: true);

      expect(
        reasonOf(await repository.update(tx.copyWith(categoryId: archived))),
        TransactionValidator.categoryArchived,
      );
      expect(
        reasonOf(await repository.update(tx.copyWith(type: TransactionType.income))),
        TransactionValidator.categoryTypeMismatch,
      );
      expect(
        (await repository.update(
          tx.copyWith(type: TransactionType.income, categoryId: salary),
        )).valueOrNull?.type,
        TransactionType.income,
      );
    });

    test('rejects invalid values and leaves the stored row unchanged', () async {
      final tx = await create();

      expect(
        reasonOf(await repository.update(tx.copyWith(amount: Money.zero))),
        TransactionValidator.amountNotPositive,
      );
      expect(
        reasonOf(await repository.update(tx.copyWith(occurredOn: DateTime(1999, 12, 31)))),
        TransactionValidator.dateOutOfRange,
      );
      expect(
        reasonOf(await repository.update(tx.copyWith(note: 'x' * 501))),
        TransactionValidator.noteTooLong,
      );
      final stored = await row(tx.id);
      expect(stored.amountMinor, 1200);
      expect(stored.occurredOn, DateTime(2026, 10, 11));
    });

    test('a missing or deleted transaction is not found', () async {
      final tx = await create();
      await repository.delete(tx.id);

      expect((await repository.update(tx)).failureOrNull, isA<NotFoundFailure>());
      expect(
        (await repository.update(tx.copyWith(id: 'missing'))).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('delete and restore', () {
    test('delete soft-deletes and restore brings it back, both pending', () async {
      final tx = await create();
      clock.current = later;

      expect((await repository.delete(tx.id)).isSuccess, isTrue);
      final deleted = await row(tx.id);
      expect(deleted.deletedAt, later);
      expect(deleted.syncStatus, SyncStatus.pending);
      expect(await repository.watch(october).first, isEmpty);

      expect((await repository.restore(tx.id)).isSuccess, isTrue);
      final restored = await row(tx.id);
      expect(restored.deletedAt, isNull);
      expect(restored.updatedAt, later);
      expect((await repository.watch(october).first).single.id, tx.id);
    });

    test('both are idempotent', () async {
      final tx = await create();
      await repository.delete(tx.id);
      clock.current = later;

      expect((await repository.delete(tx.id)).isSuccess, isTrue);
      expect((await row(tx.id)).deletedAt, created);
      expect((await repository.restore(tx.id)).isSuccess, isTrue);
      expect((await repository.restore(tx.id)).isSuccess, isTrue);
    });

    test('a missing transaction is not found', () async {
      expect((await repository.delete('missing')).failureOrNull, isA<NotFoundFailure>());
      expect((await repository.restore('missing')).failureOrNull, isA<NotFoundFailure>());
    });
  });

  test('a database error becomes a StorageFailure', () async {
    await db.customStatement('DROP TABLE transactions');

    expect((await repository.create(draft())).failureOrNull, isA<StorageFailure>());
  });

  group('sync requests', () {
    test('create, update, delete and restore each ask for a sync', () async {
      final tx = await create();
      await repository.update(tx.copyWith(amount: const Money(999)));
      await repository.delete(tx.id);
      await repository.restore(tx.id);

      expect(trigger.requests, 4);
    });

    test('failures and no-op deletes or restores do not', () async {
      final tx = await create();
      trigger.requests = 0;

      await repository.create(draft(amount: 0));
      await repository.update(tx.copyWith(amount: Money.zero));
      await repository.restore(tx.id);
      await repository.delete('missing');

      expect(trigger.requests, 0);
    });
  });
}
