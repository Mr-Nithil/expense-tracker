import 'package:expense_tracker/core/db/daos/app_settings_dao.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/features/budget/domain/budget_alert_preferences.dart';

/// [BudgetAlertPreferences] in the local, device-only `app_settings` table.
class BudgetAlertPreferencesImpl implements BudgetAlertPreferences {
  BudgetAlertPreferencesImpl(this.dao);

  final AppSettingsDao dao;

  static const key = 'budget_alerts_enabled';

  @override
  Stream<bool> watchEnabled() => dao.watchValue(key).map((value) => value == 'true');

  @override
  Future<Result<void>> setEnabled({required bool enabled}) async {
    try {
      await dao.setValue(key, enabled.toString());
      return Result.ok;
    } catch (error, stackTrace) {
      AppLogger.error('budget alerts: saving the setting failed', error, stackTrace);
      return Result.failure(StorageFailure('budget alerts setting: $error'));
    }
  }
}
