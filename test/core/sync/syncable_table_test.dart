import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:expense_tracker/core/sync/syncable_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  const user = 'user-1';
  final created = DateTime.utc(2026, 10, 1, 9, 30, 15, 123);
  final updated = DateTime.utc(2026, 10, 11, 18, 5, 1, 456);

  late AppDatabase db;

  /// One fully populated row per synced table, with every optional column set.
  Future<void> seedEveryTable() async {
    Value<DateTime?> deleted() => Value(updated);
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: user,
            userId: user,
            createdAt: created,
            updatedAt: updated,
            displayName: const Value('Nithil'),
            currencyCode: const Value('LKR'),
            locale: const Value('en_LK'),
            themeMode: const Value('dark'),
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            name: 'Food',
            icon: 'food',
            color: 0xFFEF6C00,
            type: 'expense',
            isDefault: const Value(true),
            sortOrder: const Value(3),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            deletedAt: deleted(),
            type: 'expense',
            amountMinor: 123456,
            categoryId: 'cat',
            occurredOn: DateTime(2026, 10, 11),
            note: const Value('Team lunch'),
          ),
        );
    await db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            id: 'budget',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            month: DateTime(2026, 10),
            categoryId: const Value('cat'),
            limitMinor: 5000000,
          ),
        );
    await db
        .into(db.goals)
        .insert(
          GoalsCompanion.insert(
            id: 'goal',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            name: 'Laptop',
            targetMinor: 30000000,
            deadlineOn: Value(DateTime(2027, 3, 31)),
            icon: 'laptop',
            color: 0xFF1E88E5,
          ),
        );
    await db
        .into(db.goalContributions)
        .insert(
          GoalContributionsCompanion.insert(
            id: 'contribution',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            goalId: 'goal',
            amountMinor: 250000,
            contributedOn: DateTime(2026, 10, 5),
            note: const Value('Bonus'),
          ),
        );
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: 'reminder',
            userId: user,
            createdAt: created,
            updatedAt: updated,
            title: 'Log expenses',
            timeOfDay: '21:30',
            repeatRule: 'weekly',
            weekdays: const Value(0x15),
            enabled: const Value(false),
          ),
        );
  }

  Future<DataClass> onlyRow(SyncableTable table) async =>
      (await db.select(table.table).get()).single;

  /// What PostgREST would send back: `+00:00` offsets, JSON booleans, the server timestamp and
  /// possibly a column this app version doesn't know.
  Map<String, Object?> asServerJson(Map<String, Object?> pushed) => {
    for (final MapEntry(:key, :value) in pushed.entries)
      key: value is String && value.endsWith('Z')
          ? '${value.substring(0, value.length - 1)}+00:00'
          : value,
    SyncableTable.serverUpdatedAtColumn: '2026-10-11T18:05:02.789123+00:00',
    'column_from_a_newer_version': 42,
  };

  setUp(() async {
    db = createTestDatabase();
    await seedEveryTable();
  });

  test('toRemote sends every column except sync_status and server_updated_at', () async {
    for (final table in syncableTables(db)) {
      final json = table.toRemote(await onlyRow(table));
      final expected = {
        for (final column in table.table.$columns) column.name,
      }..removeAll([SyncableTable.syncStatusColumn, SyncableTable.serverUpdatedAtColumn]);

      expect(json.keys.toSet(), expected, reason: table.name);
    }
  });

  test('toRemote encodes timestamps as UTC ISO, dates as yyyy-MM-dd and money as int', () async {
    final transactions = syncableTables(db).firstWhere((t) => t.name == 'transactions');
    final json = transactions.toRemote(await onlyRow(transactions));

    expect(json['created_at'], '2026-10-01T09:30:15.123Z');
    expect(json['deleted_at'], '2026-10-11T18:05:01.456Z');
    expect(json['occurred_on'], '2026-10-11');
    expect(json['amount_minor'], 123456);
    expect(json['note'], 'Team lunch');
  });

  test('every table round-trips through server JSON and comes back synced', () async {
    for (final table in syncableTables(db)) {
      final original = await onlyRow(table);
      final pushed = table.toRemote(original);

      final fromServer = await table.fromRemote(asServerJson(pushed));

      expect(table.toRemote(fromServer), pushed, reason: table.name);
      final columns = (fromServer as Insertable).toColumns(false);
      expect(
        (columns[SyncableTable.syncStatusColumn]! as Variable).value,
        SyncStatus.synced.index,
        reason: table.name,
      );
      expect(
        (columns[SyncableTable.serverUpdatedAtColumn]! as Variable).value,
        DateTime.utc(2026, 10, 11, 18, 5, 2, 789, 123),
        reason: table.name,
      );
    }
  });

  test('a row from the server can be stored and read back', () async {
    final categories = syncableTables(db).firstWhere((t) => t.name == 'categories');
    final json = asServerJson(categories.toRemote(await onlyRow(categories)))
      ..['id'] = 'cat-2'
      ..['is_default'] = false;

    await db
        .into(db.categories)
        .insert(
          await categories.fromRemote(json) as CategoryRow,
          mode: InsertMode.insertOrReplace,
        );

    final stored = await db.categoriesDao.getById(user, 'cat-2');
    expect(stored?.isDefault, isFalse);
    expect(stored?.syncStatus, SyncStatus.synced);
    expect(stored?.updatedAt, updated);
  });

  test('null optional columns stay null', () async {
    final goals = syncableTables(db).firstWhere((t) => t.name == 'goals');
    final json = asServerJson(goals.toRemote(await onlyRow(goals)))
      ..['deadline_on'] = null
      ..['deleted_at'] = null;

    final row = await goals.fromRemote(json) as GoalRow;

    expect(row.deadlineOn, isNull);
    expect(row.deletedAt, isNull);
  });

  group('pendingRows and markSynced', () {
    late SyncableTable transactions;

    setUp(() => transactions = syncableTables(db).firstWhere((t) => t.name == 'transactions'));

    Future<void> addTransaction(
      String id, {
      String userId = user,
      SyncStatus status = SyncStatus.pending,
      DateTime? deletedAt,
    }) async {
      if (userId != user) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'cat-$userId',
                userId: userId,
                createdAt: created,
                updatedAt: updated,
                name: 'Food',
                icon: 'food',
                color: 0,
                type: 'expense',
              ),
            );
      }
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              userId: userId,
              createdAt: created,
              updatedAt: updated,
              deletedAt: Value(deletedAt),
              syncStatus: Value(status),
              type: 'expense',
              amountMinor: 100,
              categoryId: userId == user ? 'cat' : 'cat-$userId',
              occurredOn: DateTime(2026, 10, 11),
            ),
          );
    }

    Future<List<String>> pendingIds() async => [
      for (final row in await transactions.pendingRows(user)) (row as TransactionRow).id,
    ];

    test('are the user’s pending rows, soft-deleted ones included', () async {
      await addTransaction('synced', status: SyncStatus.synced);
      await addTransaction('deleted', deletedAt: updated);
      await addTransaction('theirs', userId: 'user-2');

      expect(await pendingIds(), unorderedEquals(['tx', 'deleted']));
    });

    test('markSynced marks the pushed rows', () async {
      final rows = await transactions.pendingRows(user);

      expect(await transactions.markSynced(rows), 1);
      expect(await pendingIds(), isEmpty);
    });

    test('a row edited during the push stays pending', () async {
      final rows = await transactions.pendingRows(user);
      await db.transactionsDao.updateTransaction(
        user,
        'tx',
        TransactionsCompanion(updatedAt: Value(updated.add(const Duration(seconds: 1)))),
      );

      expect(await transactions.markSynced(rows), 0);
      expect(await pendingIds(), ['tx']);
    });

    test('works for every registered table', () async {
      for (final table in syncableTables(db)) {
        final rows = await table.pendingRows(user);
        expect(rows, hasLength(1), reason: table.name);
        expect(await table.markSynced(rows), 1, reason: table.name);
        expect(await table.pendingRows(user), isEmpty, reason: table.name);
      }
    });
  });

  group('merge', () {
    late SyncableTable categories;
    final remoteTime = DateTime.utc(2026, 10, 12, 10);

    setUp(() => categories = syncableTables(db).firstWhere((t) => t.name == 'categories'));

    /// The seeded category as the server would send it, with changes.
    Future<DataClass> remote({
      String id = 'cat',
      String name = 'Groceries',
      DateTime? updatedAt,
      String userId = user,
    }) async {
      final json = asServerJson(categories.toRemote(await onlyRow(categories)))
        ..['id'] = id
        ..['name'] = name
        ..['user_id'] = userId
        ..['updated_at'] = (updatedAt ?? remoteTime).toIso8601String();
      return categories.fromRemote(json);
    }

    Future<void> setLocal({required SyncStatus status, required DateTime updatedAt}) =>
        db.categoriesDao.updateCategory(
          user,
          'cat',
          CategoriesCompanion(syncStatus: Value(status), updatedAt: Value(updatedAt)),
        );

    Future<CategoryRow> local() async => (await db.categoriesDao.getById(user, 'cat'))!;

    test('inserts a row this device doesn’t have', () async {
      final outcome = await categories.merge(await remote(id: 'new'), userId: user);

      expect(outcome, MergeOutcome.inserted);
      expect((await db.categoriesDao.getById(user, 'new'))?.syncStatus, SyncStatus.synced);
    });

    test('overwrites a synced local copy', () async {
      await setLocal(status: SyncStatus.synced, updatedAt: updated);

      expect(await categories.merge(await remote(), userId: user), MergeOutcome.updated);
      expect((await local()).name, 'Groceries');
      expect((await local()).syncStatus, SyncStatus.synced);
    });

    test('keeps a newer pending local copy (last-write-wins)', () async {
      await setLocal(
        status: SyncStatus.pending,
        updatedAt: remoteTime.add(const Duration(minutes: 1)),
      );

      expect(await categories.merge(await remote(), userId: user), MergeOutcome.keptLocal);
      expect((await local()).name, 'Food');
      expect((await local()).syncStatus, SyncStatus.pending);
    });

    test('an older pending local copy loses to the server', () async {
      await setLocal(
        status: SyncStatus.pending,
        updatedAt: remoteTime.subtract(const Duration(minutes: 1)),
      );

      expect(await categories.merge(await remote(), userId: user), MergeOutcome.updated);
      expect((await local()).name, 'Groceries');
      expect((await local()).syncStatus, SyncStatus.synced);
    });

    test('an equal timestamp is our own push coming back: take it, mark synced', () async {
      await setLocal(status: SyncStatus.pending, updatedAt: remoteTime);

      expect(await categories.merge(await remote(), userId: user), MergeOutcome.updated);
      expect((await local()).syncStatus, SyncStatus.synced);
    });

    test('another user’s row is skipped', () async {
      final outcome = await categories.merge(
        await remote(id: 'theirs', userId: 'user-2'),
        userId: user,
      );

      expect(outcome, MergeOutcome.skipped);
      expect(await db.categoriesDao.getById('user-2', 'theirs'), isNull);
    });

    test('values cleared on the server are cleared locally (nulls are applied)', () async {
      final transactions = syncableTables(db).firstWhere((t) => t.name == 'transactions');
      // The seeded transaction is deleted and has a note; the server version undoes both.
      final json = asServerJson(transactions.toRemote(await onlyRow(transactions)))
        ..['note'] = null
        ..['deleted_at'] = null
        ..['updated_at'] = remoteTime.toIso8601String();

      final outcome = await transactions.merge(await transactions.fromRemote(json), userId: user);

      expect(outcome, MergeOutcome.updated);
      final row = (await db.transactionsDao.getById(user, 'tx'))!;
      expect(row.note, isNull);
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, SyncStatus.synced);
    });

    test('overwriting a parent keeps its children (updates in place)', () async {
      // The seeded transaction and budget reference this category.
      await setLocal(status: SyncStatus.synced, updatedAt: updated);

      await categories.merge(await remote(), userId: user);

      expect(await db.transactionsDao.getById(user, 'tx'), isNotNull);
      expect((await local()).name, 'Groceries');
    });
  });
}
