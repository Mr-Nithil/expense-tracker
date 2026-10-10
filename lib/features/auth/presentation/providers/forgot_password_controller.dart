import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forgot_password_controller.g.dart';

/// Forgot-password state: idle (`AsyncData(null)`), sending (`AsyncLoading`), sent
/// (`AsyncData(email)`, the address the link went to), or the `AppFailure` of the last attempt.
@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  FutureOr<String?> build() => null;

  Future<void> sendReset({required String email}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(authRepositoryProvider).sendPasswordReset(email: email);
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => AsyncData(email.trim()),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Back to the form, e.g. to use another address.
  void reset() => state = const AsyncData(null);
}
