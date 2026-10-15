import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/sync/row_resealer.dart';
import 'package:expense_tracker/core/sync/sync_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1, 8);
  late AppDatabase db;
  late RowResealer resealer;

  setUp(() {
    db = createTestDatabase();
    resealer = RowResealer(db: db, tables: syncableTables(db));
  });

  Future<void> category(String id, String user, SyncStatus status) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          userId: user,
          name: id,
          icon: 'food',
          color: 0,
          type: 'expense',
          createdAt: at,
          updatedAt: at,
          syncStatus: Value(status),
        ),
      );

  Future<CategoryRow> read(String id) =>
      (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();

  test('marks the user\'s synced rows pending, keeping updated_at; once', () async {
    await category('a', 'u1', SyncStatus.synced);
    await category('b', 'u1', SyncStatus.pending);
    await category('c', 'u2', SyncStatus.synced);

    expect(await resealer.ensureSealed('u1'), 1);

    expect((await read('a')).syncStatus, SyncStatus.pending);
    expect((await read('a')).updatedAt, at);
    expect((await read('c')).syncStatus, SyncStatus.synced, reason: 'another user');

    await db.customStatement('UPDATE categories SET sync_status = ${SyncStatus.synced.index}');
    expect(await resealer.ensureSealed('u1'), 0, reason: 'already done for u1');
    expect((await read('a')).syncStatus, SyncStatus.synced);
  });

  test('tables without private columns are left alone', () async {
    await db.profilesDao.insertProfile(
      ProfilesCompanion.insert(
        id: 'u1',
        userId: 'u1',
        createdAt: at,
        updatedAt: at,
        syncStatus: const Value(SyncStatus.synced),
      ),
    );

    await resealer.ensureSealed('u1');

    expect((await db.profilesDao.getProfile('u1'))?.syncStatus, SyncStatus.synced);
  });

  test('another user on this phone runs it again', () async {
    await resealer.ensureSealed('u1');
    await category('d', 'u2', SyncStatus.synced);

    expect(await resealer.ensureSealed('u2'), 1);
  });
}
