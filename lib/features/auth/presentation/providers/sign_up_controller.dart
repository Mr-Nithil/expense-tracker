import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_controller.g.dart';

/// Sign-up form state: idle (`AsyncData(null)`), submitting (`AsyncLoading`), the outcome of a
/// successful sign-up (`AsyncData(outcome)`), or the `AppFailure` of the last attempt.
///
/// Never navigates. On [SignUpOutcome.signedIn] the router redirect leaves the screen; the screen
/// handles [SignUpOutcome.emailConfirmationRequired].
@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<SignUpOutcome?> build() => null;

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password, displayName: displayName);
    // The redirect may already have disposed the sign-up screen (and this controller).
    if (!ref.mounted) return;

    state = switch (result) {
      Success(:final value) => AsyncData(value),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
