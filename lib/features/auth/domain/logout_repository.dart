import 'package:expense_tracker/core/error/result.dart';

/// Ends the session on this device and removes all local user data.
abstract interface class LogoutRepository {
  /// Local changes that have not synced yet and would be lost by [logout].
  Future<Result<int>> pendingChangesCount();

  /// Signs out (works offline), then clears the local DB and secure storage. The user is always
  /// signed out; a `StorageFailure` means the local cleanup did not finish.
  Future<Result<void>> logout();
}
