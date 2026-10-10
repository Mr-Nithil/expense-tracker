import 'package:expense_tracker/core/error/result.dart';

/// Which user the data on this device belongs to, and wiping it.
abstract interface class LocalDataRepository {
  /// Makes [userId] the owner of the local data. When another user owned it (e.g. after Supabase
  /// signed them out and someone else signed in), their data is cleared first. Returns `true` when
  /// something was cleared.
  Future<Result<bool>> claimFor(String userId);

  /// Removes all local user data (DB and secure storage), including the owner record.
  Future<Result<void>> clear();
}
