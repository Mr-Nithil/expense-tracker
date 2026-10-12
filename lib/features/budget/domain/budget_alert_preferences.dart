import 'package:expense_tracker/core/error/result.dart';

/// Whether this device shows budget alerts (a per-device choice; never synced). Off by default.
abstract interface class BudgetAlertPreferences {
  Stream<bool> watchEnabled();

  Future<Result<void>> setEnabled({required bool enabled});
}
