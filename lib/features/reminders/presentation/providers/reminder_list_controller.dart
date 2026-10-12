import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_list_controller.g.dart';

/// Reminder list actions. Notification permission is asked only when a reminder is switched on
/// (ARCHITECTURE §11). Kept alive because it is only used from callbacks.
@Riverpod(keepAlive: true)
class ReminderListController extends _$ReminderListController {
  @override
  void build() {}

  Future<Result<void>> setEnabled(String id, {required bool enabled}) =>
      ref.read(reminderRepositoryProvider).setEnabled(id, enabled: enabled);

  /// Asks the OS for notification permission; false when the user refused (or it was refused
  /// before), so the screen can explain how to allow it.
  Future<bool> ensurePermission() => ref.read(notificationServiceProvider).requestPermission();
}
