import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

/// Login form state: idle/success (`AsyncData`), submitting (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`).
///
/// Never navigates: on success the session changes and the router redirect leaves `/login`.
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(authRepositoryProvider).signIn(email: email, password: password);
    // The redirect may already have disposed the login screen (and this controller).
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Sends the sign-up confirmation email again (after `emailNotConfirmed`). Leaves the sign-in
  /// state alone; the screen shows the result directly.
  Future<Result<void>> resendConfirmation(String email) =>
      ref.read(authRepositoryProvider).resendConfirmation(email: email);
}
