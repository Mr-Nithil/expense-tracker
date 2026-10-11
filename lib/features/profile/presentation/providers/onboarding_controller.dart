import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/presentation/providers/default_categories_seeder.dart';
import 'package:expense_tracker/features/profile/data/profile_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Onboarding state: idle/success (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure` of
/// the last attempt (`AsyncError`).
///
/// Seeds the default categories, then saves the currency. Never navigates: once the profile has a
/// currency, the router's onboarding gate leaves.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  Future<void> confirm(String currencyCode) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    // Seed first: setting the currency is what lets the user into the app, so a failed seed
    // keeps them here (with an error and a retry) instead of in an app with no categories.
    final seeded = await ref.read(defaultCategoriesSeederProvider).seed();
    if (!ref.mounted) return;
    if (seeded case Failure(:final failure)) {
      state = AsyncError(failure, StackTrace.current);
      return;
    }

    final result = await ref.read(profileRepositoryProvider).setCurrency(currencyCode);
    // The redirect may already have disposed the onboarding screen (and this controller).
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
