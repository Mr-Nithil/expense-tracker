import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/initial_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_status.g.dart';

enum OnboardingStatus {
  /// No session yet, or the local profile is still loading.
  unknown,

  /// Signed in, but no currency chosen yet.
  required,
  complete,
}

/// Whether the signed-in user has finished onboarding, read from the local profile.
///
/// Lives in core (like `AuthStatusController`) so the router does not import the profile feature.
/// Without a local currency it waits for the initial pull (M3.8): a second device then downloads
/// the profile instead of asking for the currency again. A failed pull falls back to onboarding.
@Riverpod(keepAlive: true)
Stream<OnboardingStatus> onboardingStatus(Ref ref) {
  final userId = ref.watch(sessionProvider.select((user) => user?.userId));
  if (userId == null) return Stream.value(OnboardingStatus.unknown);
  final initialSync = ref.watch(initialSyncProvider);
  final waitingForFirstPull =
      initialSync == InitialSyncStatus.checking || initialSync == InitialSyncStatus.running;
  return ref
      .watch(databaseProvider)
      .profilesDao
      .watchProfile(userId)
      .map(
        (row) => row?.currencyCode != null
            ? OnboardingStatus.complete
            : waitingForFirstPull
            ? OnboardingStatus.unknown
            : OnboardingStatus.required,
      );
}
