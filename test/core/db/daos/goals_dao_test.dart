import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10, 12);

  late AppDatabase db;

  setUp(() => db = createTestDatabase());

  Future<String> goal({
    String user = userId,
    DateTime? createdAt,
    bool deleted = false,
    String name = 'Laptop',
  }) async {
    final id = IdGenerator.newId();
    await db.goalsDao.insertGoal(
      GoalsCompanion.insert(
        id: id,
        userId: user,
        createdAt: createdAt ?? now,
        updatedAt: now,
        name: name,
        targetMinor: 100000,
        icon: 'savings',
        color: 0,
        deletedAt: Value(deleted ? now : null),
      ),
    );
    return id;
  }

  Future<String> contribute(
    String goalId,
    int amount, {
    String user = userId,
    DateTime? on,
    DateTime? createdAt,
    bool deleted = false,
  }) async {
    final id = IdGenerator.newId();
    await db.goalsDao.insertContribution(
      GoalContributionsCompanion.insert(
        id: id,
        userId: user,
        createdAt: createdAt ?? now,
        updatedAt: now,
        goalId: goalId,
        amountMinor: amount,
        contributedOn: on ?? DateTime(2026, 10, 1),
        deletedAt: Value(deleted ? now : null),
      ),
    );
    return id;
  }

  group('watchAllWithSaved', () {
    test('lists live goals oldest first, each with its own saved sum', () async {
      final bike = await goal(name: 'Bike', createdAt: now.add(const Duration(days: 1)));
      final laptop = await goal();
      await contribute(laptop, 2000);
      await contribute(laptop, 500);
      await contribute(bike, 700);

      final rows = await db.goalsDao.watchAllWithSaved(userId).first;

      expect(rows.map((r) => (r.goal.id, r.savedMinor)), [(laptop, 2500), (bike, 700)]);
    });

    test('ignores deleted goals and contributions, and other users', () async {
      final laptop = await goal();
      await goal(deleted: true);
      await goal(user: 'u2');
      await contribute(laptop, 1000);
      await contribute(laptop, 99, deleted: true);

      final rows = await db.goalsDao.watchAllWithSaved(userId).first;

      expect(rows.single.savedMinor, 1000);
    });

    test('a goal without contributions has saved 0', () async {
      await goal();

      expect((await db.goalsDao.watchAllWithSaved(userId).first).single.savedMinor, 0);
    });

    test('emits again when a contribution is added', () async {
      final laptop = await goal();
      final saved = db.goalsDao.watchAllWithSaved(userId).map((rows) => rows.single.savedMinor);

      final expectation = expectLater(saved, emitsInOrder([0, 400]));
      await pumpEventQueue();
      await contribute(laptop, 400);
      await expectation;
    });
  });

  test('watchByIdWithSaved returns one live goal, or null', () async {
    final laptop = await goal();
    final gone = await goal(deleted: true);
    await contribute(laptop, 300);

    expect((await db.goalsDao.watchByIdWithSaved(userId, laptop).first)?.savedMinor, 300);
    expect(await db.goalsDao.watchByIdWithSaved(userId, gone).first, isNull);
    expect(await db.goalsDao.watchByIdWithSaved('u2', laptop).first, isNull);
  });

  test('getById includes deleted rows and is scoped to the user', () async {
    final gone = await goal(deleted: true);

    expect((await db.goalsDao.getById(userId, gone))?.deletedAt, isNotNull);
    expect(await db.goalsDao.getById('u2', gone), isNull);
  });

  test('watchContributions lists live ones newest first', () async {
    final laptop = await goal();
    final older = await contribute(laptop, 1, on: DateTime(2026, 9, 1));
    final sameDayEarly = await contribute(laptop, 2, on: DateTime(2026, 10, 1));
    final sameDayLate = await contribute(
      laptop,
      3,
      on: DateTime(2026, 10, 1),
      createdAt: now.add(const Duration(hours: 1)),
    );
    await contribute(laptop, 4, deleted: true);

    final rows = await db.goalsDao.watchContributions(userId, laptop).first;

    expect(rows.map((r) => r.id), [sameDayLate, sameDayEarly, older]);
  });

  test('softDeleteContributionsOfGoal deletes only that goal\'s live ones, pending sync', () async {
    final laptop = await goal();
    final bike = await goal(name: 'Bike');
    final a = await contribute(laptop, 1);
    final b = await contribute(laptop, 2);
    final other = await contribute(bike, 3);
    final later = now.add(const Duration(days: 2));

    expect(await db.goalsDao.softDeleteContributionsOfGoal(userId, laptop, later), 2);

    for (final id in [a, b]) {
      final row = (await db.goalsDao.getContributionById(userId, id))!;
      expect(row.deletedAt, later);
      expect(row.updatedAt, later);
      expect(row.syncStatus, SyncStatus.pending);
    }
    expect((await db.goalsDao.getContributionById(userId, other))!.deletedAt, isNull);
  });

  test('updates only touch the user\'s own rows', () async {
    final laptop = await goal();
    final c = await contribute(laptop, 1);

    expect(
      await db.goalsDao.updateGoal('u2', laptop, const GoalsCompanion(name: Value('x'))),
      0,
    );
    expect(
      await db.goalsDao.updateContribution(
        'u2',
        c,
        const GoalContributionsCompanion(amountMinor: Value(5)),
      ),
      0,
    );
    expect(
      await db.goalsDao.updateGoal(userId, laptop, const GoalsCompanion(name: Value('Mac'))),
      1,
    );
    expect((await db.goalsDao.getById(userId, laptop))!.name, 'Mac');
  });
}
