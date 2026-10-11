import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  final now = DateTime(2026, 10, 11, 15, 45);
  final october = TransactionFilter(month: DateTime(2026, 10));

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = createTestDatabase();
    container = createTestContainer(
      db: db,
      overrides: [clockProvider.overrideWithValue(FixedClock(now))],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: 'food',
        userId: 'u1',
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        name: 'Food',
        icon: 'food',
        color: 0,
        type: 'expense',
        sortOrder: const Value(0),
      ),
    );
  });

  Future<void> add(int day, int amount) async {
    final result = await container
        .read(transactionRepositoryProvider)
        .create(
          TransactionDraft(
            type: TransactionType.expense,
            amount: Money(amount),
            categoryId: 'food',
            occurredOn: DateTime(2026, 10, day),
          ),
        );
    expect(result.isSuccess, isTrue);
  }

  group('TransactionFilterController', () {
    TransactionFilterController controller() =>
        container.read(transactionFilterControllerProvider.notifier);
    TransactionFilter filter() => container.read(transactionFilterControllerProvider);

    test('starts at the first day of the current month, unfiltered', () {
      expect(filter(), TransactionFilter(month: DateTime(2026, 10)));
      expect(filter().isNarrowed, isFalse);
    });

    test('steps months across a year boundary', () {
      controller().setMonth(DateTime(2026, 1, 20));
      controller().previousMonth();
      expect(filter().month, DateTime(2025, 12));
      controller()
        ..nextMonth()
        ..nextMonth();
      expect(filter().month, DateTime(2026, 2));
    });

    test('clamps to the months that can hold transactions', () {
      controller().setMonth(DateTime(1999, 5));
      expect(filter().month, DateTime(2000));
      controller().previousMonth();
      expect(filter().month, DateTime(2000));

      controller().setMonth(DateTime(2030));
      expect(filter().month, DateTime(2027, 10));
    });

    test('changing the type drops the category, the same type keeps it', () {
      controller()
        ..setType(TransactionType.expense)
        ..setCategory('food')
        ..setType(TransactionType.expense);
      expect(filter().categoryId, 'food');

      controller().setType(TransactionType.income);
      expect(filter().categoryId, isNull);
      expect(filter().type, TransactionType.income);
    });

    test('clearing keeps the month', () {
      controller()
        ..previousMonth()
        ..setType(TransactionType.income)
        ..clearFilters();
      expect(filter(), TransactionFilter(month: DateTime(2026, 9)));
    });

    test('resets for a new user', () {
      container.listen(transactionFilterControllerProvider, (_, _) {});
      controller()
        ..previousMonth()
        ..setType(TransactionType.income);

      container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));

      expect(filter(), TransactionFilter(month: DateTime(2026, 10)));
    });
  });

  test('lists the month and groups it into newest-first days', () async {
    container.listen(transactionDaysProvider(october), (_, _) {});
    await add(3, 100);
    await add(9, 200);
    await add(9, 300);
    await pumpEventQueue();

    final days = container.read(transactionDaysProvider(october)).requireValue;
    expect(days.map((d) => d.date), [DateTime(2026, 10, 9), DateTime(2026, 10, 3)]);
    expect(days.first.expense, const Money(500));
  });

  test('re-subscribes for a different user', () async {
    container.listen(transactionsProvider(october), (_, _) {});
    await add(3, 100);
    await pumpEventQueue();
    expect(await container.read(transactionsProvider(october).future), hasLength(1));

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));
    await pumpEventQueue();

    expect(await container.read(transactionsProvider(october).future), isEmpty);
  });

  test('transactionById follows updates and reports deletion', () async {
    final repository = container.read(transactionRepositoryProvider);
    final created = (await repository.create(
      TransactionDraft(
        type: TransactionType.expense,
        amount: const Money(100),
        categoryId: 'food',
        occurredOn: DateTime(2026, 10, 3),
      ),
    )).valueOrNull!;
    container
      ..listen(transactionByIdProvider(created.id), (_, _) {})
      ..listen(transactionByIdProvider('missing'), (_, _) {});
    await pumpEventQueue();

    await repository.update(created.copyWith(amount: const Money(250)));
    await pumpEventQueue();
    expect(
      (await container.read(transactionByIdProvider(created.id).future))?.amount,
      const Money(250),
    );

    await repository.delete(created.id);
    await pumpEventQueue();
    expect((await container.read(transactionByIdProvider(created.id).future))?.isDeleted, isTrue);
    expect(await container.read(transactionByIdProvider('missing').future), isNull);
  });
}
