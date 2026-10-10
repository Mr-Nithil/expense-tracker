import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/local_data_repository.dart';
import 'package:expense_tracker/features/auth/domain/logout_repository.dart';

/// [LogoutRepository] over the auth repository and the local data (DB, secure storage).
class LogoutRepositoryImpl implements LogoutRepository {
  LogoutRepositoryImpl({required this.auth, required this.db, required this.localData});

  final AuthRepository auth;
  final AppDatabase db;
  final LocalDataRepository localData;

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
    // TODO(M3.5): if online, run SyncService first so pending changes are not lost.

    // Sign out first: clearing the DB while still signed in would make the onboarding gate flash
    // `/onboarding` before `/login`. Never fails; the local session is cleared even offline.
    await auth.signOut();

    // Also removes the local-data owner record, so the next sign-in starts fresh.
    return localData.clear();
  }
}
