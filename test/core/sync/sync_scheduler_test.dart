import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/sync/sync_scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_connectivity_service.dart';
import '../../helpers/fake_sync_trigger.dart';
import '../../helpers/test_database.dart';

void main() {
  late FakeSyncTrigger trigger;
  late FakeConnectivityService connectivity;

  ProviderContainer start({AuthStatus status = AuthStatus.signedIn}) {
    trigger = FakeSyncTrigger();
    connectivity = FakeConnectivityService();
    final container = createTestContainer(
      syncTrigger: trigger,
      overrides: [connectivity.providerOverride],
    );
    container.read(authStatusControllerProvider.notifier).set(status);
    // The app keeps the scheduler alive the same way (App.build).
    container.listen(syncSchedulerProvider, (_, _) {});
    return container;
  }

  /// Background, then foreground, in the order the engine reports it.
  Future<void> resume(WidgetTester tester) async {
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
  }

  testWidgets('a signed-in session syncs once at start', (tester) async {
    start();
    await tester.pump();

    expect(trigger.immediate, 1);
    expect(trigger.requests, 0);
  });

  testWidgets('signed out, nothing runs until sign-in', (tester) async {
    final container = start(status: AuthStatus.signedOut);
    await resume(tester);
    connectivity.emit(online: true);
    await tester.pump();
    expect(trigger.immediate + trigger.requests, 0);

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedIn);
    await tester.pump();

    expect(trigger.immediate, 1);
  });

  testWidgets('resuming the app asks for a sync', (tester) async {
    start();
    await resume(tester);

    expect(trigger.requests, 1);
  });

  testWidgets('coming back online asks for a sync; going offline does not', (tester) async {
    start();

    connectivity.emit(online: false);
    await tester.pump();
    expect(trigger.requests, 0);

    connectivity.emit(online: true);
    await tester.pump();
    expect(trigger.requests, 1);
  });

  testWidgets('after sign-out, nothing reacts and the pending run is dropped', (tester) async {
    final container = start();
    await tester.pump();

    container.read(authStatusControllerProvider.notifier).set(AuthStatus.signedOut);
    await tester.pump();
    await resume(tester);
    connectivity.emit(online: true);
    await tester.pump();

    expect(trigger.cancels, 1);
    expect(trigger.requests, 0);
  });
}
