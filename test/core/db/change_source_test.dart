import 'package:drift/drift.dart' show Value, Variable;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

/// M10.14: who made each row and change. Local edits reset an agent-marked row to the user;
/// sync merges and re-sealing keep the marks (trigger in `change_source.drift`).
void main() {
  final created = DateTime.utc(2026, 10, 1, 8);
  final later = DateTime.utc(2026, 10, 2, 8);
  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<CategoryRow> read() =>
      (db.select(db.categories)..where((c) => c.id.equals('c1'))).getSingle();

  /// A category as it arrives from the server after the agent changed it (synced).
  Future<void> agentRow() => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: 'c1',
          userId: 'u1',
          name: 'Coffee',
          icon: 'coffee',
          color: 0,
          type: 'expense',
          createdAt: created,
          updatedAt: created,
          syncStatus: const Value(SyncStatus.synced),
          createdBy: const Value(ChangeSource.agent),
          updatedBy: const Value(ChangeSource.agent),
          agentProposalId: const Value('p1'),
        ),
      );

  test('a new local row is the user\'s', () async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'c1',
            userId: 'u1',
            name: 'Food',
            icon: 'food',
            color: 0,
            type: 'expense',
            createdAt: created,
            updatedAt: created,
          ),
        );

    final row = await read();
    expect((row.createdBy, row.updatedBy, row.agentProposalId), ('user', 'user', null));
  });

  test(
    'a local edit of an agent row marks the change as the user\'s, keeping created_by',
    () async {
      await agentRow();

      await db.categoriesDao.updateCategory(
        'u1',
        'c1',
        CategoriesCompanion(
          name: const Value('Coffee & tea'),
          updatedAt: Value(later),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );

      final row = await read();
      expect(row.name, 'Coffee & tea');
      expect((row.createdBy, row.updatedBy, row.agentProposalId), ('agent', 'user', null));
    },
  );

  test('a sync merge (synced) keeps the agent marks', () async {
    await agentRow();

    await db.customUpdate(
      "UPDATE categories SET name = 'Cafe', updated_at = ?, sync_status = ? WHERE id = 'c1'",
      variables: [Variable<DateTime>(later), Variable<int>(SyncStatus.synced.index)],
    );

    final row = await read();
    expect((row.updatedBy, row.agentProposalId), ('agent', 'p1'));
  });

  test('re-sealing (pending, same updated_at) keeps the agent marks', () async {
    await agentRow();

    await db.customUpdate(
      "UPDATE categories SET sync_status = ? WHERE id = 'c1'",
      variables: [Variable<int>(SyncStatus.pending.index)],
    );

    final row = await read();
    expect((row.updatedBy, row.agentProposalId), ('agent', 'p1'));
  });

  test('every synced table has the trigger', () async {
    final triggers = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'trigger'")
        .map((row) => row.read<String>('name'))
        .get();

    expect(
      triggers.toSet(),
      containsAll([
        for (final table in [
          'profiles',
          'categories',
          'transactions',
          'budgets',
          'goals',
          'goal_contributions',
          'reminders',
        ])
          '${table}_local_change_source',
      ]),
    );
  });
}
