import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
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
/// Until the initial pull on login exists (M3.8), a second device sees onboarding again.
@Riverpod(keepAlive: true)
Stream<OnboardingStatus> onboardingStatus(Ref ref) {
  final userId = ref.watch(sessionProvider.select((user) => user?.userId));
  if (userId == null) return Stream.value(OnboardingStatus.unknown);
  return ref
      .watch(databaseProvider)
      .profilesDao
      .watchProfile(userId)
      .map(
        (row) => row?.currencyCode == null ? OnboardingStatus.required : OnboardingStatus.complete,
      );
}
