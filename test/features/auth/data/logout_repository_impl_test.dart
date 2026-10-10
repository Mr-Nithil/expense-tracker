import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_impl.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_database.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  const userId = 'u1';
  final now = DateTime.utc(2026, 10, 10);

  late AppDatabase db;
  late _MockAuthRepository auth;
  late _MockSecureStorage storage;
  late LogoutRepositoryImpl repository;

  setUp(() {
    db = createTestDatabase();
    auth = _MockAuthRepository();
    storage = _MockSecureStorage();
    when(() => auth.signOut()).thenAnswer((_) async => Result.ok);
    when(() => storage.deleteAll()).thenAnswer((_) async {});
    repository = LogoutRepositoryImpl(
      auth: auth,
      db: db,
      localData: LocalDataRepositoryImpl(db: db, secureStorage: storage),
    );
  });

  Future<void> seedPendingProfile() => db.profilesDao.insertProfile(
    ProfilesCompanion.insert(id: userId, userId: userId, createdAt: now, updatedAt: now),
  );

  test('pendingChangesCount reports unsynced rows', () async {
    expect((await repository.pendingChangesCount()).valueOrNull, 0);

    await seedPendingProfile();

    expect((await repository.pendingChangesCount()).valueOrNull, 1);
  });

  test('logout signs out, then clears the local DB and secure storage', () async {
    await seedPendingProfile();
    await db.appSettingsDao.setValue('theme_mode', 'dark');

    final result = await repository.logout();

    expect(result.isSuccess, isTrue);
    verify(() => auth.signOut()).called(1);
    verify(() => storage.deleteAll()).called(1);
    expect(await db.profilesDao.getProfile(userId), isNull);
    expect(await db.appSettingsDao.getValue('theme_mode'), isNull);
  });

  test('a cleanup failure is reported, but the user is still signed out', () async {
    when(() => storage.deleteAll()).thenThrow(Exception('keychain locked'));

    final result = await repository.logout();

    expect(result.failureOrNull, isA<StorageFailure>());
    verify(() => auth.signOut()).called(1);
  });

  test('pendingChangesCount reports a storage failure instead of throwing', () async {
    // A missing table makes the count query throw a real SqliteException.
    await db.customStatement('DROP TABLE reminders');

    final result = await repository.pendingChangesCount();

    expect(result.failureOrNull, isA<StorageFailure>());
  });
}
