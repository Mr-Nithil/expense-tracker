import 'dart:async';

import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'local_notification_service.g.dart';

/// [NotificationService] on `flutter_local_notifications`: the only place that touches the
/// plugin. Android delivery is inexact (no exact-alarm permission; decided 2026-10-11).
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    Future<String> Function()? localTimezone,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _localTimezone =
           localTimezone ?? (() async => (await FlutterTimezone.getLocalTimezone()).identifier);

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<String> Function() _localTimezone;
  final _taps = StreamController<String>.broadcast();
  NotificationChannelLabels? _labels;

  /// Android notification icon (the launcher icon until a monochrome one exists).
  static const androidIcon = '@mipmap/ic_launcher';

  static String channelId(NotificationChannel channel) => switch (channel) {
    NotificationChannel.reminders => 'reminders',
    NotificationChannel.budgetAlerts => 'budget_alerts',
  };

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init(NotificationChannelLabels labels) async {
    _labels = labels;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await _localTimezone()));
    } on Object catch (error, stackTrace) {
      // Unknown zone: schedule in UTC rather than not at all.
      AppLogger.error('notifications: local time zone unavailable', error, stackTrace);
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _taps.add(payload);
      },
    );

    final android = _android;
    if (android != null) {
      for (final channel in NotificationChannel.values) {
        final (name, description) = _label(channel);
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            channelId(channel),
            name,
            description: description,
            importance: Importance.defaultImportance,
          ),
        );
      }
    }
  }

  (String, String) _label(NotificationChannel channel) {
    final labels = _labels!;
    return switch (channel) {
      NotificationChannel.reminders => (labels.reminders, labels.remindersDescription),
      NotificationChannel.budgetAlerts => (labels.budgetAlerts, labels.budgetAlertsDescription),
    };
  }

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  NotificationDetails _details(NotificationChannel channel) {
    final (name, description) = _label(channel);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId(channel),
        name,
        channelDescription: description,
        icon: androidIcon,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    required NotificationChannel channel,
    String? payload,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: _details(channel),
    payload: payload,
  );

  @override
  Future<void> scheduleRepeating({
    required int id,
    required String title,
    String? body,
    required DateTime firstAt,
    required RepeatEvery every,
    String? payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: _localTime(firstAt),
    notificationDetails: _details(NotificationChannel.reminders),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: switch (every) {
      RepeatEvery.day => DateTimeComponents.time,
      RepeatEvery.week => DateTimeComponents.dayOfWeekAndTime,
      RepeatEvery.month => DateTimeComponents.dayOfMonthAndTime,
    },
    payload: payload,
  );

  @override
  Future<void> scheduleOnce({
    required int id,
    required String title,
    String? body,
    required DateTime at,
    String? payload,
  }) => _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: _localTime(at),
    notificationDetails: _details(NotificationChannel.reminders),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: payload,
  );

  @override
  Future<List<int>> pendingIds() async => [
    for (final request in await _plugin.pendingNotificationRequests()) request.id,
  ];

  /// [at]'s wall-clock time in the device's time zone (daylight saving included).
  static tz.TZDateTime _localTime(DateTime at) =>
      tz.TZDateTime(tz.local, at.year, at.month, at.day, at.hour, at.minute);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => LocalNotificationService();

/// Sets notifications up once for the app's lifetime (watched by `App`). Channel names follow
/// the app language. Failures are logged, never fatal: the app works without notifications.
@Riverpod(keepAlive: true)
Future<void> notificationSetup(Ref ref) async {
  final l10n = appLocalizationsFor(
    ref.read(localeControllerProvider),
    device: PlatformDispatcher.instance.locale,
  );
  try {
    await ref
        .read(notificationServiceProvider)
        .init(
          NotificationChannelLabels(
            reminders: l10n.notificationsChannelReminders,
            remindersDescription: l10n.notificationsChannelRemindersDescription,
            budgetAlerts: l10n.notificationsChannelBudgetAlerts,
            budgetAlertsDescription: l10n.notificationsChannelBudgetAlertsDescription,
          ),
        );
  } on Object catch (error, stackTrace) {
    AppLogger.error('notifications: setup failed', error, stackTrace);
  }
}
