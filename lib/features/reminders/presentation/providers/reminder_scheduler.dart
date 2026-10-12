import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/services/notification_payload.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_notification_plan.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_scheduler.g.dart';

/// Keeps this device's reminder notifications in line with its reminders (watched by `App`).
///
/// Whenever the reminders change (edited here, pulled by sync, signed in or out) it cancels the
/// pending reminder notifications and schedules [ReminderNotificationPlan] again. Notifications
/// never sync: every device derives its own. Other notifications (budget alerts) are left alone.
@Riverpod(keepAlive: true)
class ReminderScheduler extends _$ReminderScheduler {
  bool _running = false;
  List<Reminder>? _next;

  @override
  void build() {
    ref.listen(remindersProvider, (_, next) {
      if (next case AsyncData(:final value)) _apply(value);
    }, fireImmediately: true);
  }

  /// One run at a time; changes during a run are applied right after it (only the latest).
  Future<void> _apply(List<Reminder> reminders) async {
    _next = reminders;
    if (_running) return;
    _running = true;
    try {
      for (var latest = _next; latest != null; latest = _next) {
        _next = null;
        await _schedule(latest);
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _schedule(List<Reminder> reminders) async {
    try {
      await ref.read(notificationSetupProvider.future);
      final notifications = ref.read(notificationServiceProvider);
      final plan = ReminderNotificationPlan.of(reminders, ref.read(clockProvider).now());

      for (final id in await notifications.pendingIds()) {
        if (ReminderNotificationIds.isReminderId(id)) await notifications.cancel(id);
      }
      for (final item in plan) {
        final payload = ReminderPayload(item.reminderId).encode();
        switch (item.repeat) {
          case PlannedRepeat.none:
            await notifications.scheduleOnce(
              id: item.id,
              title: item.title,
              at: item.at,
              payload: payload,
            );
          case PlannedRepeat.daily || PlannedRepeat.weekly || PlannedRepeat.monthly:
            await notifications.scheduleRepeating(
              id: item.id,
              title: item.title,
              firstAt: item.at,
              every: switch (item.repeat) {
                PlannedRepeat.weekly => RepeatEvery.week,
                PlannedRepeat.monthly => RepeatEvery.month,
                _ => RepeatEvery.day,
              },
              payload: payload,
            );
        }
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error('reminders: scheduling failed', error, stackTrace);
    }
  }
}
