import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart' as tz;

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAndroid extends Mock implements AndroidFlutterLocalNotificationsPlugin {}

class _MockIos extends Mock implements IOSFlutterLocalNotificationsPlugin {}

void main() {
  const labels = NotificationChannelLabels(
    reminders: 'Reminders',
    remindersDescription: 'Reminders you set',
    budgetAlerts: 'Budget alerts',
    budgetAlertsDescription: 'Budget limits',
  );

  late _MockPlugin plugin;
  late _MockAndroid android;
  late _MockIos ios;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const AndroidNotificationChannel('x', 'x'));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime.utc(2026));
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
  });

  setUp(() {
    plugin = _MockPlugin();
    android = _MockAndroid();
    ios = _MockIos();
    when(
      () => plugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
      ),
    ).thenAnswer((_) async => true);
    when(() => android.createNotificationChannel(any())).thenAnswer((_) async {});
  });

  LocalNotificationService service({String zone = 'Europe/Berlin', bool onAndroid = true}) {
    when(
      () => plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(),
    ).thenReturn(onAndroid ? android : null);
    when(
      () => plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>(),
    ).thenReturn(onAndroid ? null : ios);
    return LocalNotificationService(plugin: plugin, localTimezone: () async => zone);
  }

  group('init', () {
    test('sets the device time zone and never asks for permission', () async {
      await service().init(labels);

      expect(tz.local.name, 'Europe/Berlin');
      final settings =
          verify(
                () => plugin.initialize(
                  settings: captureAny(named: 'settings'),
                  onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
                ),
              ).captured.single
              as InitializationSettings;
      expect(settings.iOS?.requestAlertPermission, isFalse);
      expect(settings.iOS?.requestSoundPermission, isFalse);
      expect(settings.iOS?.requestBadgePermission, isFalse);
    });

    test('creates the two Android channels with the given names', () async {
      await service().init(labels);

      final channels = verify(
        () => android.createNotificationChannel(captureAny()),
      ).captured.cast<AndroidNotificationChannel>();
      expect(channels.map((c) => (c.id, c.name)), [
        ('reminders', 'Reminders'),
        ('budget_alerts', 'Budget alerts'),
      ]);
      expect(channels.first.description, 'Reminders you set');
    });

    test('an unknown time zone falls back to UTC instead of failing', () async {
      await service(zone: 'Not/AZone').init(labels);

      verify(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).called(1);
    });
  });

  group('requestPermission', () {
    test('asks Android 13+ for notifications', () async {
      when(() => android.requestNotificationsPermission()).thenAnswer((_) async => true);

      expect(await service().requestPermission(), isTrue);
    });

    test('asks iOS for alert, badge and sound', () async {
      when(
        () => ios.requestPermissions(alert: true, badge: true, sound: true),
      ).thenAnswer((_) async => false);

      expect(await service(onAndroid: false).requestPermission(), isFalse);
    });
  });

  test('schedules a weekly reminder at the local time, inexact on Android', () async {
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    final notifications = service();
    await notifications.init(labels);

    await notifications.scheduleRepeating(
      id: 7,
      title: 'Log expenses',
      firstAt: DateTime(2026, 10, 12, 20, 30),
      every: RepeatEvery.week,
      payload: 'reminder:7',
    );

    final call = verify(
      () => plugin.zonedSchedule(
        id: 7,
        title: 'Log expenses',
        body: null,
        scheduledDate: captureAny(named: 'scheduledDate'),
        notificationDetails: captureAny(named: 'notificationDetails'),
        androidScheduleMode: captureAny(named: 'androidScheduleMode'),
        matchDateTimeComponents: captureAny(named: 'matchDateTimeComponents'),
        payload: 'reminder:7',
      ),
    ).captured;
    final fireAt = call[0] as tz.TZDateTime;
    expect(
      (fireAt.location.name, fireAt.hour, fireAt.minute, fireAt.day),
      ('Europe/Berlin', 20, 30, 12),
    );
    expect((call[1] as NotificationDetails).android?.channelId, 'reminders');
    expect(call[2], AndroidScheduleMode.inexactAllowWhileIdle);
    expect(call[3], DateTimeComponents.dayOfWeekAndTime);
  });

  test('shows a budget alert now on its channel, and cancels by id', () async {
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    final notifications = service();
    await notifications.init(labels);

    await notifications.show(
      id: 3,
      title: 'Food budget at 80%',
      channel: NotificationChannel.budgetAlerts,
    );
    await notifications.cancel(3);

    final details =
        verify(
              () => plugin.show(
                id: 3,
                title: 'Food budget at 80%',
                body: null,
                notificationDetails: captureAny(named: 'notificationDetails'),
                payload: null,
              ),
            ).captured.single
            as NotificationDetails;
    expect(details.android?.channelId, 'budget_alerts');
    verify(() => plugin.cancel(id: 3)).called(1);
  });

  test('schedules a one-off at the local time without repeating; lists pending ids', () async {
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.pendingNotificationRequests()).thenAnswer(
      (_) async => const [
        PendingNotificationRequest(4, 'a', null, null),
        PendingNotificationRequest(9, 'b', null, null),
      ],
    );
    final notifications = service();
    await notifications.init(labels);

    await notifications.scheduleOnce(id: 4, title: 'Pay rent', at: DateTime(2027, 2, 28, 9));

    final captured = verify(
      () => plugin.zonedSchedule(
        id: 4,
        title: 'Pay rent',
        body: null,
        scheduledDate: captureAny(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: captureAny(named: 'matchDateTimeComponents'),
        payload: null,
      ),
    ).captured;
    final at = captured[0] as tz.TZDateTime;
    expect(
      (at.year, at.month, at.day, at.hour, at.location.name),
      (2027, 2, 28, 9, 'Europe/Berlin'),
    );
    expect(captured[1], isNull);
    expect(await notifications.pendingIds(), [4, 9]);
  });

  group('taps', () {
    test('a tap while running reaches the taps stream', () async {
      final notifications = service();
      await notifications.init(labels);
      final onTap =
          verify(
                () => plugin.initialize(
                  settings: any(named: 'settings'),
                  onDidReceiveNotificationResponse: captureAny(
                    named: 'onDidReceiveNotificationResponse',
                  ),
                ),
              ).captured.single
              as DidReceiveNotificationResponseCallback;

      final next = notifications.taps.first;
      onTap(
        const NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: 'budget:2026-10',
        ),
      );

      expect(await next, 'budget:2026-10');
    });

    test('reports the payload only when a notification launched the app', () async {
      when(() => plugin.getNotificationAppLaunchDetails()).thenAnswer(
        (_) async => const NotificationAppLaunchDetails(
          true,
          notificationResponse: NotificationResponse(
            notificationResponseType: NotificationResponseType.selectedNotification,
            payload: 'reminder:r1',
          ),
        ),
      );
      expect(await service().launchPayload(), 'reminder:r1');

      when(
        () => plugin.getNotificationAppLaunchDetails(),
      ).thenAnswer((_) async => const NotificationAppLaunchDetails(false));
      expect(await service().launchPayload(), isNull);
    });
  });
}
