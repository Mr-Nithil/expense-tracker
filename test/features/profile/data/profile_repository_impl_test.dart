import 'package:drift/drift.dart' show Value;
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_impl.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_sync_trigger.dart';
import '../../../helpers/test_database.dart';

void main() {
  const userId = 'user-1';
  final created = DateTime.utc(2026, 10, 1);
  final now = DateTime.utc(2026, 10, 10, 12);

  late AppDatabase db;
  late Session session;
  late ProfileRepositoryImpl repository;
  late FakeSyncTrigger trigger;

  setUp(() {
    db = createTestDatabase();
    trigger = FakeSyncTrigger();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)
      ..set(const SessionUser(userId: userId, displayName: 'Nithil'));
    repository = ProfileRepositoryImpl(
      dao: db.profilesDao,
      clock: FixedClock(now),
      session: session,
      syncTrigger: trigger,
    );
  });

  Future<ProfileRow?> storedRow() => db.profilesDao.getProfile(userId);

  Future<void> seedRow({String? currency}) => db.profilesDao.insertProfile(
    ProfilesCompanion.insert(
      id: userId,
      userId: userId,
      createdAt: created,
      updatedAt: created,
      displayName: const Value('Server name'),
      currencyCode: Value(currency),
      syncStatus: const Value(SyncStatus.synced),
    ),
  );

  test('creates the local profile with system fields when none exists', () async {
    final result = await repository.setCurrency('LKR');

    expect(
      result.valueOrNull,
      const Profile(id: userId, displayName: 'Nithil', currencyCode: 'LKR'),
    );
    final row = (await storedRow())!;
    expect(row.userId, userId);
    expect(row.createdAt, now);
    expect(row.updatedAt, now);
    expect(row.syncStatus, SyncStatus.pending);
    expect(row.displayName, 'Nithil');
  });

  test('updates an existing profile and marks it pending', () async {
    await seedRow();

    final result = await repository.setCurrency('EUR');

    expect(result.valueOrNull?.currencyCode, 'EUR');
    final row = (await storedRow())!;
    expect(row.currencyCode, 'EUR');
    expect(row.updatedAt, now);
    expect(row.createdAt, created);
    expect(row.syncStatus, SyncStatus.pending);
    expect(row.displayName, 'Server name');
  });

  test('rejects an unsupported currency without writing', () async {
    final result = await repository.setCurrency('XXX');

    expect((result.failureOrNull! as ValidationFailure).field, 'currencyCode');
    expect(await storedRow(), isNull);
  });

  test('refuses to change a currency that is already set', () async {
    await seedRow(currency: 'USD');

    final result = await repository.setCurrency('EUR');

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect((await storedRow())!.currencyCode, 'USD');
  });

  test('fails with AuthFailure without a session', () async {
    session.set(null);

    final result = await repository.setCurrency('USD');

    expect(result.failureOrNull, isA<AuthFailure>());
  });

  test('watchProfile follows the stored row', () async {
    final profiles = repository.watchProfile().map((p) => p?.currencyCode);
    final expectation = expectLater(profiles, emitsInOrder([null, 'INR']));
    await pumpEventQueue();

    await repository.setCurrency('INR');

    await expectation;
  });

  test('watchProfile is null without a session', () async {
    session.set(null);
    expect(await repository.watchProfile().first, isNull);
  });

  test('a database error becomes a StorageFailure instead of throwing', () async {
    // A missing table makes the write throw a real SqliteException.
    await db.customStatement('DROP TABLE profiles');

    final result = await repository.setCurrency('USD');

    expect(result.failureOrNull, isA<StorageFailure>());
  });

  test('saving the currency asks for a sync; a rejected one does not', () async {
    await repository.setCurrency('XXX');
    expect(trigger.requests, 0);

    await repository.setCurrency('LKR');
    expect(trigger.requests, 1);
  });

  group('setThemeMode', () {
    test('updates the theme, marks the row pending and asks for a sync', () async {
      await seedRow(currency: 'USD');

      final result = await repository.setThemeMode(AppThemeMode.dark);

      expect(result.valueOrNull?.themeMode, AppThemeMode.dark);
      final row = (await storedRow())!;
      expect(row.themeMode, 'dark');
      expect(row.updatedAt, now);
      expect(row.syncStatus, SyncStatus.pending);
      expect(row.currencyCode, 'USD');
      expect(trigger.requests, 1);
    });

    test('saving the current theme again changes nothing', () async {
      await seedRow(currency: 'USD');
      await repository.setThemeMode(AppThemeMode.light);
      trigger.requests = 0;

      await repository.setThemeMode(AppThemeMode.light);

      expect(trigger.requests, 0);
    });

    test('creates the profile row when there is none yet', () async {
      final result = await repository.setThemeMode(AppThemeMode.light);

      expect(result.valueOrNull?.themeMode, AppThemeMode.light);
      expect((await storedRow())?.displayName, 'Nithil');
    });

    test('fails with AuthFailure without a session', () async {
      session.set(null);
      expect((await repository.setThemeMode(AppThemeMode.dark)).failureOrNull, isA<AuthFailure>());
    });
  });
}
