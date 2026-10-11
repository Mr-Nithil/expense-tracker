import 'dart:async';

import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/services/connectivity_service.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_scheduler.g.dart';

/// Automatic sync while signed in (ARCHITECTURE §7): once when the session starts (app start
/// with a restored session, or a sign-in), and again on app resume and when the connection comes
/// back. Stops, and drops a pending debounced run, when the user is no longer signed in.
///
/// Must be kept alive by the app (see `App`). Writes trigger sync themselves (repositories).
@Riverpod(keepAlive: true)
void syncScheduler(Ref ref) {
  AppLifecycleListener? lifecycle;
  StreamSubscription<bool>? connectivity;
  SyncTrigger? active;

  void stop() {
    lifecycle?.dispose();
    lifecycle = null;
    unawaited(connectivity?.cancel());
    connectivity = null;
    active?.cancel();
    active = null;
  }

  void start() {
    final trigger = ref.read(syncTriggerProvider);
    active = trigger;
    lifecycle = AppLifecycleListener(onResume: trigger.requestSync);
    connectivity = ref.read(connectivityServiceProvider).onlineChanges.listen((online) {
      if (online) trigger.requestSync();
    });
    unawaited(trigger.syncNow());
  }

  ref.listen(authStatusControllerProvider, (previous, next) {
    final wasSignedIn = previous == AuthStatus.signedIn;
    final isSignedIn = next == AuthStatus.signedIn;
    if (isSignedIn && !wasSignedIn) {
      start();
    } else if (!isSignedIn && wasSignedIn) {
      stop();
    }
  }, fireImmediately: true);
  ref.onDispose(stop);
}
