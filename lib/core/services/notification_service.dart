/// Which Android channel a notification goes to. Users can turn each off in system settings.
enum NotificationChannel { reminders, budgetAlerts }

/// How often a scheduled notification repeats, at the same local time.
enum RepeatEvery { day, week, month }

/// Localized channel names and descriptions (shown in Android system settings).
class NotificationChannelLabels {
  const NotificationChannelLabels({
    required this.reminders,
    required this.remindersDescription,
    required this.budgetAlerts,
    required this.budgetAlertsDescription,
  });

  final String reminders;
  final String remindersDescription;
  final String budgetAlerts;
  final String budgetAlertsDescription;
}

/// Local notifications: setup, permission, show now, schedule repeating, cancel. Implemented by
/// `LocalNotificationService`; fake it in tests. Nothing here talks to a server.
abstract interface class NotificationService {
  /// Time zone, plugin and channels. Never asks for permission (see [requestPermission]).
  Future<void> init(NotificationChannelLabels labels);

  /// Asks the OS for permission (Android 13+, iOS). True when notifications are allowed.
  Future<bool> requestPermission();

  /// Shows a notification now.
  Future<void> show({
    required int id,
    required String title,
    String? body,
    required NotificationChannel channel,
    String? payload,
  });

  /// Shows a notification at [firstAt] (local wall-clock time), then again every [every] at the
  /// same local time (same weekday for weeks, same day of the month for months).
  Future<void> scheduleRepeating({
    required int id,
    required String title,
    String? body,
    required DateTime firstAt,
    required RepeatEvery every,
    String? payload,
  });

  /// Shows a notification once at [at] (local wall-clock time).
  Future<void> scheduleOnce({
    required int id,
    required String title,
    String? body,
    required DateTime at,
    String? payload,
  });

  /// Ids of the notifications scheduled and not shown yet.
  Future<List<int>> pendingIds();

  /// Payloads of notifications the user taps while the app runs.
  Stream<String> get taps;

  /// The payload of the notification whose tap launched the app, if one did.
  Future<String?> launchPayload();

  Future<void> cancel(int id);

  Future<void> cancelAll();
}
