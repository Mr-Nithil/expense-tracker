import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_impl.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_sync_trigger.dart';
import '../../../helpers/test_database.dart';

void main() {
  const userId = 'user-1';
  final created = DateTime.utc(2026, 10, 11, 9);
  final later = DateTime.utc(2026, 10, 12, 18);

  late AppDatabase db;
  late FixedClock clock;
  late Session session;
  late GoalRepositoryImpl repository;
  late FakeSyncTrigger trigger;

  GoalRepositoryImpl repositoryFor() => GoalRepositoryImpl(
    dao: db.goalsDao,
    clock: clock,
    session: session,
    syncTrigger: trigger,
  );

  setUp(() {
    db = createTestDatabase();
    clock = FixedClock(created);
    trigger = FakeSyncTrigger();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: userId));
    repository = repositoryFor();
  });

  GoalDraft draft({String name = 'Laptop', int target = 150000, DateTime? deadline}) => GoalDraft(
    name: name,
    target: Money(target),
    deadlineOn: deadline,
    icon: 'savings',
    color: 0xFF2E7D32,
  );

  Future<Goal> createGoal([GoalDraft? d]) async =>
      (await repository.create(d ?? draft())).valueOrNull!;

  ContributionDraft contribution(String goalId, {int amount = 5000, DateTime? on, String? note}) =>
      ContributionDraft(
        goalId: goalId,
        amount: Money(amount),
        contributedOn: on ?? DateTime(2026, 10, 5),
        note: note,
      );

  Future<GoalContribution> contribute(String goalId, {int amount = 5000, DateTime? on}) async =>
      (await repository.addContribution(contribution(goalId, amount: amount, on: on))).valueOrNull!;

  String? reasonOf<T>(Result<T> result) => result.failureOrNull?.message;

  group('create', () {
    test('stores a trimmed, pending goal with a date-only deadline', () async {
      final result = await repository.create(
        draft(name: '  New laptop ', deadline: DateTime(2027, 3, 1, 18, 30)),
      );

      final goal = result.valueOrNull!;
      expect(goal.name, 'New laptop');
      expect(goal.target, const Money(150000));
      expect(goal.deadlineOn, DateTime(2027, 3));
      expect(goal.createdAt, created);
      final row = (await db.goalsDao.getById(userId, goal.id))!;
      expect(row.syncStatus, SyncStatus.pending);
      expect(row.userId, userId);
      expect(trigger.requests, 1);
    });

    test('rejects invalid fields before touching the DB', () async {
      expect(reasonOf(await repository.create(draft(name: ' '))), GoalValidator.nameRequired);
      expect(reasonOf(await repository.create(draft(target: 0))), GoalValidator.targetNotPositive);
      expect(await repository.watchAll().first, isEmpty);
      expect(trigger.requests, 0);
    });

    test('fails without a session', () async {
      session.set(null);
      expect((await repository.create(draft())).failureOrNull, isA<AuthFailure>());
    });
  });

  group('update', () {
    test('changes the editable fields, pending sync', () async {
      final goal = await createGoal();
      await db.goalsDao.updateGoal(
        userId,
        goal.id,
        const GoalsCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock = FixedClock(later);
      repository = repositoryFor();

      final result = await repository.update(
        goal.copyWith(name: 'MacBook', target: const Money(200000), deadlineOn: null),
      );

      expect(result.valueOrNull?.name, 'MacBook');
      final row = (await db.goalsDao.getById(userId, goal.id))!;
      expect(row.targetMinor, 200000);
      expect(row.deadlineOn, isNull);
      expect(row.updatedAt, later);
      expect(row.syncStatus, SyncStatus.pending);
    });

    test('a missing or deleted goal is NotFound', () async {
      final goal = await createGoal();
      await repository.delete(goal.id);

      expect((await repository.update(goal)).failureOrNull, isA<NotFoundFailure>());
      expect(
        (await repository.update(goal.copyWith(id: 'missing'))).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });

    test('validates like create', () async {
      final goal = await createGoal();
      expect(
        reasonOf(await repository.update(goal.copyWith(name: ''))),
        GoalValidator.nameRequired,
      );
    });
  });

  group('watchAll / watchById', () {
    test('pairs each goal with its saved total and follows contributions', () async {
      final laptop = await createGoal();
      // Created a minute later: the list is oldest first (equal times would tie on random ids).
      clock = FixedClock(created.add(const Duration(minutes: 1)));
      repository = repositoryFor();
      final bike = await createGoal(draft(name: 'Bike'));
      await contribute(laptop.id, amount: 3000);
      await contribute(laptop.id, amount: 2000);

      final all = await repository.watchAll().first;
      expect(all.map((p) => (p.goal.name, p.saved)), [
        ('Laptop', const Money(5000)),
        ('Bike', Money.zero),
      ]);
      expect((await repository.watchById(bike.id).first)?.saved, Money.zero);
      expect(await repository.watchById('missing').first, isNull);
    });

    test('are empty for a signed-out user', () async {
      final goal = await createGoal();
      session.set(null);

      expect(await repository.watchAll().first, isEmpty);
      expect(await repository.watchById(goal.id).first, isNull);
      expect(await repository.watchContributions(goal.id).first, isEmpty);
    });
  });

  group('delete', () {
    test('soft-deletes the goal and its contributions, pending sync', () async {
      final goal = await createGoal();
      final c = await contribute(goal.id);
      clock = FixedClock(later);
      repository = repositoryFor();

      expect(await repository.delete(goal.id), Result.ok);

      final goalRow = (await db.goalsDao.getById(userId, goal.id))!;
      final contributionRow = (await db.goalsDao.getContributionById(userId, c.id))!;
      expect(goalRow.deletedAt, later);
      expect(goalRow.syncStatus, SyncStatus.pending);
      expect(contributionRow.deletedAt, later);
      expect(contributionRow.syncStatus, SyncStatus.pending);
      expect(await repository.watchAll().first, isEmpty);
    });

    test('deleting twice is a no-op; an unknown id is NotFound', () async {
      final goal = await createGoal();
      await repository.delete(goal.id);
      final requests = trigger.requests;

      expect(await repository.delete(goal.id), Result.ok);
      expect(trigger.requests, requests);
      expect((await repository.delete('missing')).failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('contributions', () {
    test('adds a pending, date-only contribution with a trimmed note', () async {
      final goal = await createGoal();

      final result = await repository.addContribution(
        contribution(goal.id, on: DateTime(2026, 10, 5, 22), note: '  bonus  '),
      );

      final c = result.valueOrNull!;
      expect(c.contributedOn, DateTime(2026, 10, 5));
      expect(c.note, 'bonus');
      final row = (await db.goalsDao.getContributionById(userId, c.id))!;
      expect(row.syncStatus, SyncStatus.pending);
    });

    test('lists a goal\'s contributions newest first', () async {
      final goal = await createGoal();
      final older = await contribute(goal.id, on: DateTime(2026, 9, 1));
      final newer = await contribute(goal.id, on: DateTime(2026, 10, 1));

      final list = await repository.watchContributions(goal.id).first;
      expect(list.map((c) => c.id), [newer.id, older.id]);
    });

    test('the goal must exist and not be deleted', () async {
      expect(
        reasonOf(await repository.addContribution(contribution('missing'))),
        GoalValidator.goalNotFound,
      );
      final goal = await createGoal();
      await repository.delete(goal.id);
      expect(
        reasonOf(await repository.addContribution(contribution(goal.id))),
        GoalValidator.goalNotFound,
      );
    });

    test('rejects invalid fields, including future dates', () async {
      final goal = await createGoal();
      expect(
        reasonOf(await repository.addContribution(contribution(goal.id, amount: 0))),
        GoalValidator.amountNotPositive,
      );
      expect(
        reasonOf(
          await repository.addContribution(contribution(goal.id, on: DateTime(2026, 10, 12))),
        ),
        GoalValidator.dateOutOfRange,
      );
    });

    test('deleting a contribution lowers the saved total; twice is a no-op', () async {
      final goal = await createGoal();
      final c = await contribute(goal.id, amount: 3000);
      await contribute(goal.id, amount: 1000);

      expect(await repository.deleteContribution(c.id), Result.ok);
      expect((await repository.watchById(goal.id).first)?.saved, const Money(1000));
      expect(await repository.deleteContribution(c.id), Result.ok);
      expect(
        (await repository.deleteContribution('missing')).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('restoreContribution', () {
    test('brings a deleted contribution back, pending sync', () async {
      final goal = await createGoal();
      final c = await contribute(goal.id, amount: 3000);
      await repository.deleteContribution(c.id);
      await db.goalsDao.updateContribution(
        userId,
        c.id,
        const GoalContributionsCompanion(syncStatus: Value(SyncStatus.synced)),
      );

      expect(await repository.restoreContribution(c.id), Result.ok);

      final row = (await db.goalsDao.getContributionById(userId, c.id))!;
      expect(row.deletedAt, isNull);
      expect(row.syncStatus, SyncStatus.pending);
      expect((await repository.watchById(goal.id).first)?.saved, const Money(3000));
    });

    test('restoring a live contribution is a no-op; unknown is NotFound', () async {
      final goal = await createGoal();
      final c = await contribute(goal.id);
      final requests = trigger.requests;

      expect(await repository.restoreContribution(c.id), Result.ok);
      expect(trigger.requests, requests);
      expect(
        (await repository.restoreContribution('missing')).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });

    test('does not revive a contribution whose goal was deleted', () async {
      final goal = await createGoal();
      final c = await contribute(goal.id);
      await repository.delete(goal.id);

      expect(reasonOf(await repository.restoreContribution(c.id)), GoalValidator.goalNotFound);
      expect((await db.goalsDao.getContributionById(userId, c.id))!.deletedAt, isNotNull);
    });
  });

  test('a database error becomes a StorageFailure instead of throwing', () async {
    final goal = await createGoal();
    await db.customStatement('DROP TABLE goal_contributions');

    expect((await repository.delete(goal.id)).failureOrNull, isA<StorageFailure>());
    expect(
      (await repository.addContribution(contribution(goal.id))).failureOrNull,
      isA<StorageFailure>(),
    );
  });
}
