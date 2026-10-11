import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_form_controller.g.dart';

/// Create/edit goal form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
@riverpod
class GoalFormController extends _$GoalFormController {
  @override
  FutureOr<void> build() {}

  /// Creates a goal, or updates [existing] when given. The repository validates.
  Future<void> save({
    Goal? existing,
    required String name,
    required Money target,
    required DateTime? deadlineOn,
    required String icon,
    required int color,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final repository = ref.read(goalRepositoryProvider);
    final result = existing == null
        ? await repository.create(
            GoalDraft(
              name: name,
              target: target,
              deadlineOn: deadlineOn,
              icon: icon,
              color: color,
            ),
          )
        : await repository.update(
            existing.copyWith(
              name: name,
              target: target,
              deadlineOn: deadlineOn,
              icon: icon,
              color: color,
            ),
          );
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
