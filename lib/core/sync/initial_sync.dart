import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/sync/sync_puller.dart';
import 'package:expense_tracker/core/sync/sync_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initial_sync.g.dart';

enum InitialSyncStatus {
  /// Not signed in.
  idle,

  /// Looking up whether this device has pulled before.
  checking,

  /// First pull on this device in progress.
  running,

  /// Pulled before, or the first pull succeeded.
  done,

  /// The first pull failed or timed out; the app moves on (sync keeps retrying).
  failed,
}

/// The first full pull for the signed-in user on this device (M3.8): the onboarding gate waits
/// for it, so a second device downloads the profile (with its currency) instead of asking again.
///
/// Starts when the user becomes signed in, i.e. after the local-data claim (M1.15), so it never
/// reads a previous user's cursors.
@Riverpod(keepAlive: true)
class InitialSync extends _$InitialSync {
  @override
  InitialSyncStatus build() {
    if (ref.watch(authStatusControllerProvider) != AuthStatus.signedIn) {
      return InitialSyncStatus.idle;
    }
    unawaited(_start());
    return InitialSyncStatus.checking;
  }

  Future<void> _start() async {
    final pulledBefore = await ref.read(syncPullerProvider).hasCompletedFirstPull();
    if (!ref.mounted) return;
    if (pulledBefore) {
      state = InitialSyncStatus.done;
      return;
    }

    state = InitialSyncStatus.running;
    final result = await ref
        .read(syncServiceProvider)
        .run()
        .timeout(
          ref.read(initialSyncTimeoutProvider),
          onTimeout: () => const Result.failure(NetworkFailure('initial sync: timeout')),
        );
    if (!ref.mounted) return;
    state = result.isSuccess ? InitialSyncStatus.done : InitialSyncStatus.failed;
  }
}

/// How long sign-in waits for the initial pull before moving on (the run itself continues in the
/// background). A provider so tests can shorten it.
@Riverpod(keepAlive: true)
Duration initialSyncTimeout(Ref ref) => const Duration(seconds: 20);
