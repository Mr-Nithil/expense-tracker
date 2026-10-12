import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_impl.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
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
  late ReminderRepositoryImpl repository;
  late FakeSyncTrigger trigger;

  ReminderRepositoryImpl repositoryFor() => ReminderRepositoryImpl(
    dao: db.remindersDao,
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

  ReminderDraft draft({
    String title = 'Log expenses',
    ReminderRepeat repeat = ReminderRepeat.daily,
    Set<int> weekdays = const {},
    int? dayOfMonth,
  }) => ReminderDraft(
    title: title,
    time: const ReminderTime(hour: 20, minute: 30),
    repeat: repeat,
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
  );

  Future<Reminder> create([ReminderDraft? d]) async =>
      (await repository.create(d ?? draft())).valueOrNull!;

  Future<ReminderRow> row(String id) async => (await db.remindersDao.getById(userId, id))!;

  String? reasonOf<T>(Result<T> result) => result.failureOrNull?.message;

  group('create', () {
    test('stores a trimmed, pending reminder with its HH:mm time', () async {
      final reminder = await create(draft(title: '  Log expenses '));

      expect(reminder.title, 'Log expenses');
      expect(reminder.time, const ReminderTime(hour: 20, minute: 30));
      expect(reminder.enabled, isTrue);
      final stored = await row(reminder.id);
      expect(stored.timeOfDay, '20:30');
      expect(stored.repeatRule, 'daily');
      expect(stored.syncStatus, SyncStatus.pending);
      expect(trigger.requests, 1);
    });

    test('weekly keeps its weekdays as the mask; monthly keeps its day', () async {
      final weekly = await create(
        draft(repeat: ReminderRepeat.weekly, weekdays: {DateTime.monday, DateTime.friday}),
      );
      final monthly = await create(draft(repeat: ReminderRepeat.monthly, dayOfMonth: 31));

      expect(weekly.weekdays, {DateTime.monday, DateTime.friday});
      expect((await row(weekly.id)).weekdays, 0x11);
      expect((await row(weekly.id)).dayOfMonth, isNull);
      expect(monthly.dayOfMonth, 31);
      expect((await row(monthly.id)).weekdays, isNull);
    });

    test('drops fields the repeat does not use', () async {
      final daily = await create(draft(weekdays: {DateTime.monday}, dayOfMonth: 5));

      expect(daily.weekdays, isEmpty);
      expect(daily.dayOfMonth, isNull);
    });

    test('rejects invalid input before touching the DB', () async {
      expect(reasonOf(await repository.create(draft(title: ' '))), ReminderValidator.titleRequired);
      expect(
        reasonOf(await repository.create(draft(repeat: ReminderRepeat.weekly))),
        ReminderValidator.weekdaysRequired,
      );
      expect(await repository.watchAll().first, isEmpty);
    });

    test('fails without a session', () async {
      session.set(null);
      expect((await repository.create(draft())).failureOrNull, isA<AuthFailure>());
    });
  });

  group('update', () {
    test('switching weekly → monthly replaces the mask with the day, pending sync', () async {
      final reminder = await create(
        draft(repeat: ReminderRepeat.weekly, weekdays: {DateTime.sunday}),
      );
      await db.remindersDao.updateReminder(
        userId,
        reminder.id,
        const RemindersCompanion(syncStatus: Value(SyncStatus.synced)),
      );
      clock = FixedClock(later);
      repository = repositoryFor();

      final result = await repository.update(
        reminder.copyWith(repeat: ReminderRepeat.monthly, dayOfMonth: 1, title: 'Rent'),
      );

      expect(result.valueOrNull?.title, 'Rent');
      final stored = await row(reminder.id);
      expect(stored.weekdays, isNull);
      expect(stored.dayOfMonth, 1);
      expect(stored.repeatRule, 'monthly');
      expect(stored.updatedAt, later);
      expect(stored.syncStatus, SyncStatus.pending);
    });

    test('a missing or deleted reminder is NotFound', () async {
      final reminder = await create();
      await repository.delete(reminder.id);

      expect((await repository.update(reminder)).failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('setEnabled', () {
    test('turns a reminder off, pending sync; the same value again is a no-op', () async {
      final reminder = await create();
      final requests = trigger.requests;

      expect(await repository.setEnabled(reminder.id, enabled: false), Result.ok);
      expect((await row(reminder.id)).enabled, isFalse);
      expect((await row(reminder.id)).syncStatus, SyncStatus.pending);
      expect(trigger.requests, requests + 1);

      expect(await repository.setEnabled(reminder.id, enabled: false), Result.ok);
      expect(trigger.requests, requests + 1);
    });

    test('a deleted reminder is NotFound', () async {
      final reminder = await create();
      await repository.delete(reminder.id);

      expect(
        (await repository.setEnabled(reminder.id, enabled: true)).failureOrNull,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('delete', () {
    test('soft-deletes, pending sync; twice is a no-op; unknown is NotFound', () async {
      final reminder = await create();

      expect(await repository.delete(reminder.id), Result.ok);
      expect((await row(reminder.id)).deletedAt, created);
      expect(await repository.watchAll().first, isEmpty);
      expect(await repository.watchById(reminder.id).first, isNull);
      expect(await repository.delete(reminder.id), Result.ok);
      expect((await repository.delete('missing')).failureOrNull, isA<NotFoundFailure>());
    });
  });

  test('watchAll lists by time and is empty when signed out', () async {
    await create(draft(title: 'B'));
    final early = (await repository.create(
      const ReminderDraft(
        title: 'Coffee check',
        time: ReminderTime(hour: 7, minute: 0),
        repeat: ReminderRepeat.daily,
      ),
    )).valueOrNull!;

    expect((await repository.watchAll().first).first.id, early.id);
    session.set(null);
    expect(await repository.watchAll().first, isEmpty);
  });

  test('a database error becomes a StorageFailure instead of throwing', () async {
    await db.customStatement('DROP TABLE reminders');

    expect((await repository.create(draft())).failureOrNull, isA<StorageFailure>());
  });
}
