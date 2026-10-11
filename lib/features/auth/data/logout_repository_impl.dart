import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/local_data_repository.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';

/// [LogoutRepository] over the auth repository and the local data (DB, secure storage).
class LogoutRepositoryImpl implements LogoutRepository {
  LogoutRepositoryImpl({
    required this.auth,
    required this.db,
    required this.localData,
    required this.sync,
    this.syncTimeout = defaultSyncTimeout,
  });

  /// How long logout waits for the final sync before signing out anyway.
  static const defaultSyncTimeout = Duration(seconds: 10);

  final AuthRepository auth;
  final AppDatabase db;
  final LocalDataRepository localData;
  final SyncService sync;
  final Duration syncTimeout;

  @override
  Future<Result<int>> pendingChangesCount() async {
    try {
      return Result.success(await db.countPendingRows());
    } catch (error, stackTrace) {
      AppLogger.error('pendingChangesCount failed', error, stackTrace);
      return Result.failure(StorageFailure('pendingChangesCount: $error'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    // Send pending changes first. Offline the push fails at once; a hanging network is cut off
    // by the timeout. Either way logout continues (the user was warned about pending rows).
    final synced = await sync.run().timeout(
      syncTimeout,
      onTimeout: () => const Result.failure(NetworkFailure('sync before logout: timeout')),
    );
    if (synced case Failure(:final failure)) {
      AppLogger.info('logout: final sync failed (${failure.runtimeType}), continuing');
    }

    // Sign out first: clearing the DB while still signed in would make the onboarding gate flash
    // `/onboarding` before `/login`. Never fails; the local session is cleared even offline.
    await auth.signOut();

    // Also removes the local-data owner record, so the next sign-in starts fresh. Waits for a
    // sync still in flight (e.g. after the timeout) before wiping.
    return localData.clear();
  }
}
