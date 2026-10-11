import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_form_controller.g.dart';

/// Set/edit budget form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or removed.
@riverpod
class BudgetFormController extends _$BudgetFormController {
  @override
  FutureOr<void> build() {}

  /// Sets the budget for ([month], [categoryId]); `null` is the overall budget. The repository
  /// validates.
  Future<void> save({required DateTime month, String? categoryId, required Money limit}) => _run(
    () =>
        ref.read(budgetRepositoryProvider).set(month: month, categoryId: categoryId, limit: limit),
  );

  /// Removes (soft-deletes) the budget [id].
  Future<void> remove(String id) => _run(() => ref.read(budgetRepositoryProvider).delete(id));

  Future<void> _run(Future<Result<Object?>> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await action();
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
