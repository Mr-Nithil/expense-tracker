import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contribution_form_controller.g.dart';

/// Add-money form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure`
/// of the last attempt (`AsyncError`). The sheet closes itself once saved.
@riverpod
class ContributionFormController extends _$ContributionFormController {
  @override
  FutureOr<void> build() {}

  /// Adds a contribution to [goalId]. The repository validates.
  Future<void> add({
    required String goalId,
    required Money amount,
    required DateTime contributedOn,
    String? note,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref
        .read(goalRepositoryProvider)
        .addContribution(
          ContributionDraft(
            goalId: goalId,
            amount: amount,
            contributedOn: contributedOn,
            note: note,
          ),
        );
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
