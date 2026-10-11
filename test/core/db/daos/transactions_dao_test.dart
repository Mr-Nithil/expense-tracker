import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10, 12);
  final october = (from: DateTime(2026, 10), to: DateTime(2026, 11));

  late AppDatabase db;
  late String food;
  late String salary;

  Future<String> insertCategory(String name, String type, {String user = userId}) async {
    final id = IdGenerator.newId();
    await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        id: id,
        userId: user,
        createdAt: now,
        updatedAt: now,
        name: name,
        icon: 'food',
        color: 0,
        type: type,
      ),
    );
    return id;
  }

  setUp(() async {
    db = createTestDatabase();
    food = await insertCategory('Food', 'expense');
    salary = await insertCategory('Salary', 'income');
  });

  Future<String> insert({
    required DateTime on,
    String type = 'expense',
    String? categoryId,
    String user = userId,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) async {
    final id = IdGenerator.newId();
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        id: id,
        userId: user,
        createdAt: createdAt ?? now,
        updatedAt: now,
        type: type,
        amountMinor: 100,
        categoryId: categoryId ?? (type == 'expense' ? food : salary),
        occurredOn: on,
        deletedAt: Value(deletedAt),
      ),
    );
    return id;
  }

  Future<List<String>> ids({String? type, String? categoryId}) async =>
      (await db.transactionsDao
              .watchFiltered(
                userId,
                from: october.from,
                to: october.to,
                type: type,
                categoryId: categoryId,
              )
              .first)
          .map((t) => t.id)
          .toList();

  test('includes the first day of the month and excludes the next month', () async {
    final first = await insert(on: DateTime(2026, 10));
    final last = await insert(on: DateTime(2026, 10, 31));
    await insert(on: DateTime(2026, 11));
    await insert(on: DateTime(2026, 9, 30));

    expect(await ids(), unorderedEquals([first, last]));
  });

  test('orders by date, then by entry time, newest first', () async {
    final early = await insert(on: DateTime(2026, 10, 3));
    final lateFirst = await insert(on: DateTime(2026, 10, 9), createdAt: now);
    final lateSecond = await insert(
      on: DateTime(2026, 10, 9),
      createdAt: now.add(const Duration(minutes: 5)),
    );

    expect(await ids(), [lateSecond, lateFirst, early]);
  });

  test('filters by type and category', () async {
    final expense = await insert(on: DateTime(2026, 10, 5));
    final income = await insert(on: DateTime(2026, 10, 5), type: 'income');

    expect(await ids(type: 'expense'), [expense]);
    expect(await ids(type: 'income'), [income]);
    expect(await ids(categoryId: salary), [income]);
  });

  test('deleted and other users’ transactions are not listed', () async {
    await insert(on: DateTime(2026, 10, 5), deletedAt: now);
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    expect(await ids(), isEmpty);
  });

  test('getById includes deleted rows but not other users’', () async {
    final deleted = await insert(on: DateTime(2026, 10, 5), deletedAt: now);
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    final theirs = await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    expect(await db.transactionsDao.getById(userId, deleted), isNotNull);
    expect(await db.transactionsDao.getById(userId, theirs), isNull);
  });

  test('updateTransaction only touches the user’s own row', () async {
    final otherCategory = await insertCategory('Theirs', 'expense', user: 'u2');
    final theirs = await insert(on: DateTime(2026, 10, 5), user: 'u2', categoryId: otherCategory);

    final changed = await db.transactionsDao.updateTransaction(
      userId,
      theirs,
      const TransactionsCompanion(amountMinor: Value(1)),
    );

    expect(changed, 0);
  });
}
