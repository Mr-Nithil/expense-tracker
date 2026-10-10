import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
/// the last attempt (`AsyncError`).
///
/// Never navigates: once the profile has a currency, the router's onboarding gate leaves.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  Future<void> confirm(String currencyCode) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(profileRepositoryProvider).setCurrency(currencyCode);
    // The redirect may already have disposed the onboarding screen (and this controller).
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
