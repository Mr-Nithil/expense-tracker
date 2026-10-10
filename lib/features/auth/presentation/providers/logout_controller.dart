import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/logout_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logout_controller.g.dart';

/// Logout for any screen (used by Settings; ARCHITECTURE §3, cross-feature UI).
///
/// State: idle/success (`AsyncData`), logging out (`AsyncLoading`) or the `AppFailure` of the
/// last attempt. Never navigates: the sign-out event makes the router redirect to `/login`.
@riverpod
class LogoutController extends _$LogoutController {
  @override
  FutureOr<void> build() {}

  /// Unsynced local changes that logging out would delete.
  Future<Result<int>> pendingChanges() => ref.read(logoutRepositoryProvider).pendingChangesCount();

  Future<void> logout() async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(logoutRepositoryProvider).logout();
    // The redirect to /login usually disposes the calling screen (and this controller) first.
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
