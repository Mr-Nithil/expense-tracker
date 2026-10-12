import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_alerts_controller.g.dart';

/// Whether this device shows budget alerts. Off until the user turns them on.
@riverpod
Stream<bool> budgetAlertsEnabled(Ref ref) =>
    ref.watch(budgetAlertPreferencesProvider).watchEnabled();

/// The budget alerts switch. Kept alive because it is only used from callbacks.
@Riverpod(keepAlive: true)
class BudgetAlertsController extends _$BudgetAlertsController {
  @override
  void build() {}

  /// Saves the choice. Turning alerts on asks for notification permission (ARCHITECTURE §11):
  /// the result is false when saving failed or the permission was refused.
  Future<({Result<void> saved, bool permitted})> setEnabled({required bool enabled}) async {
    final saved = await ref.read(budgetAlertPreferencesProvider).setEnabled(enabled: enabled);
    if (!enabled || !saved.isSuccess) return (saved: saved, permitted: true);
    final permitted = await ref.read(notificationServiceProvider).requestPermission();
    return (saved: saved, permitted: permitted);
  }
}
