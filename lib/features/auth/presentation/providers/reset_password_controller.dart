import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_password_controller.g.dart';

/// Set-new-password state (after opening a reset link): idle/success (`AsyncData`), saving
/// (`AsyncLoading`) or the `AppFailure` of the last attempt.
///
/// Never navigates: saving ends recovery (and [cancel] signs out), and the router redirect leaves.
@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> save(String newPassword) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(authRepositoryProvider).updatePassword(newPassword: newPassword);
    // The redirect may already have disposed the screen (and this controller).
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Leaves recovery without a new password. A plain sign-out: local data stays, since it is
  /// still this user's.
  Future<void> cancel() async {
    if (state.isLoading) return;
    await ref.read(authRepositoryProvider).signOut();
  }
}
