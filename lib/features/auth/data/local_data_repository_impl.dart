import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/features/auth/domain/local_data_repository.dart';

/// [LocalDataRepository] that records the owner in `app_settings` (device-local, never synced).
class LocalDataRepositoryImpl implements LocalDataRepository {
  LocalDataRepositoryImpl({required this.db, required this.secureStorage, required this.sync});

  final AppDatabase db;
  final SecureStorageService secureStorage;
  final SyncService sync;

  static const ownerKey = 'local_data_owner';

  @override
  Future<Result<bool>> claimFor(String userId) async {
    try {
      final owner = await db.appSettingsDao.getValue(ownerKey);
      if (owner == userId) return const Result.success(false);

      var cleared = false;
      if (owner != null) {
        // Another user's data, possibly with unsynced rows that could never sync under this user.
        AppLogger.info('local data belongs to another user, clearing it');
        await _clear();
        cleared = true;
      }
      await db.appSettingsDao.setValue(ownerKey, userId);
      return Result.success(cleared);
    } catch (error, stackTrace) {
      AppLogger.error('claimFor failed', error, stackTrace);
      return Result.failure(StorageFailure('claimFor: $error'));
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _clear();
      return Result.ok;
    } catch (error, stackTrace) {
      AppLogger.error('clear local data failed', error, stackTrace);
      return Result.failure(StorageFailure('clear: $error'));
    }
  }

  /// `clearAllData` also empties `app_settings`, so the owner record goes with it.
  ///
  /// Waits for any sync in flight first: a pull still writing would otherwise put the previous
  /// user's rows back after the wipe.
  Future<void> _clear() async {
    await sync.whenIdle();
    await db.clearAllData();
    await secureStorage.deleteAll();
  }
}
