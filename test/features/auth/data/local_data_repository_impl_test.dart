import 'dart:async';

import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_database.dart';

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockSyncService extends Mock implements SyncService {}

void main() {
  final now = DateTime.utc(2026, 10, 10);

  late AppDatabase db;
  late _MockSecureStorage storage;
  late _MockSyncService sync;
  late LocalDataRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    storage = _MockSecureStorage();
    when(() => storage.deleteAll()).thenAnswer((_) async {});
    sync = _MockSyncService();
    when(() => sync.whenIdle()).thenAnswer((_) async {});
    repository = LocalDataRepositoryImpl(db: db, secureStorage: storage, sync: sync);
  });

  Future<void> seedProfile(String userId) => db.profilesDao.insertProfile(
    ProfilesCompanion.insert(id: userId, userId: userId, createdAt: now, updatedAt: now),
  );
  Future<String?> owner() => db.appSettingsDao.getValue(LocalDataRepositoryImpl.ownerKey);

  test('the first claim records the owner without clearing', () async {
    await seedProfile('a');

    final result = await repository.claimFor('a');

    expect(result.valueOrNull, isFalse);
    expect(await owner(), 'a');
    expect(await db.profilesDao.getProfile('a'), isNotNull);
    verifyNever(() => storage.deleteAll());
  });

  test('the same user keeps their data', () async {
    await repository.claimFor('a');
    await seedProfile('a');

    final result = await repository.claimFor('a');

    expect(result.valueOrNull, isFalse);
    expect(await db.profilesDao.getProfile('a'), isNotNull);
  });

  test('a different user clears the previous data and becomes the owner', () async {
    await repository.claimFor('a');
    await seedProfile('a');

    final result = await repository.claimFor('b');

    expect(result.valueOrNull, isTrue);
    expect(await db.profilesDao.getProfile('a'), isNull);
    expect(await owner(), 'b');
    verify(() => storage.deleteAll()).called(1);
  });

  test('clear removes data, secrets and the owner record', () async {
    await repository.claimFor('a');
    await seedProfile('a');

    final result = await repository.clear();

    expect(result.isSuccess, isTrue);
    expect(await db.profilesDao.getProfile('a'), isNull);
    expect(await owner(), isNull);
    verify(() => storage.deleteAll()).called(1);
  });

  test('a database error becomes a StorageFailure', () async {
    await db.customStatement('DROP TABLE app_settings');

    final result = await repository.claimFor('a');

    expect(result.failureOrNull, isA<StorageFailure>());
  });

  test('never wipes while a sync is still running', () async {
    await repository.claimFor('a');
    await seedProfile('a');
    final idle = Completer<void>();
    when(() => sync.whenIdle()).thenAnswer((_) => idle.future);

    final claiming = repository.claimFor('b');
    await pumpEventQueue();
    expect(await db.profilesDao.getProfile('a'), isNotNull);

    idle.complete();
    await claiming;
    expect(await db.profilesDao.getProfile('a'), isNull);
  });
}
