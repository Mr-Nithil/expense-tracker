import 'dart:async';

import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Records what the app asks of notifications; never touches the plugin.
class FakeNotificationService implements NotificationService {
  NotificationChannelLabels? labels;
  var permissionGranted = true;
  var permissionRequests = 0;
  final shown = <({int id, String title, String? body, NotificationChannel channel})>[];
  final scheduled =
      <int, ({String title, String? body, DateTime firstAt, RepeatEvery every, String? payload})>{};
  final once = <int, ({String title, String? body, DateTime at, String? payload})>{};
  final cancelled = <int>[];
  var cancelledAll = 0;

  @override
  Future<void> init(NotificationChannelLabels labels) async => this.labels = labels;

  /// Every [updateChannelLabels] call, in order. Set [failRenames] to make them throw.
  final labelUpdates = <NotificationChannelLabels>[];
  var failRenames = false;

  @override
  Future<void> updateChannelLabels(NotificationChannelLabels labels) async {
    if (failRenames) throw StateError('plugin failed');
    labelUpdates.add(labels);
    this.labels = labels;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    String? body,
    required NotificationChannel channel,
    String? payload,
  }) async => shown.add((id: id, title: title, body: body, channel: channel));

  @override
  Future<void> scheduleRepeating({
    required int id,
    required String title,
    String? body,
    required DateTime firstAt,
    required RepeatEvery every,
    String? payload,
  }) async => scheduled[id] = (
    title: title,
    body: body,
    firstAt: firstAt,
    every: every,
    payload: payload,
  );

  @override
  Future<void> scheduleOnce({
    required int id,
    required String title,
    String? body,
    required DateTime at,
    String? payload,
  }) async => once[id] = (title: title, body: body, at: at, payload: payload);

  /// Ids also set here by tests stand for notifications scheduled by someone else.
  final otherPending = <int>{};

  @override
  Future<List<int>> pendingIds() async => [...scheduled.keys, ...once.keys, ...otherPending];

  final _taps = StreamController<String>.broadcast();

  /// What [launchPayload] reports (a tap that launched the app).
  String? launchedWith;

  /// Simulates the user tapping a notification while the app runs.
  void tap(String payload) => _taps.add(payload);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> launchPayload() async => launchedWith;

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
    once.remove(id);
    otherPending.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelledAll++;
    scheduled.clear();
    once.clear();
    otherPending.clear();
  }

  Override get providerOverride => notificationServiceProvider.overrideWithValue(this);
}
