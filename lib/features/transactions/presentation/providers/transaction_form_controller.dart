import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_form_controller.g.dart';

/// Add/edit transaction form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
@riverpod
class TransactionFormController extends _$TransactionFormController {
  @override
  FutureOr<void> build() {}

  /// Creates a transaction, or updates [existing] when given. The repository validates (M2.8).
  Future<void> save({
    Transaction? existing,
    required TransactionType type,
    required Money amount,
    required String categoryId,
    required DateTime occurredOn,
    String? note,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final repository = ref.read(transactionRepositoryProvider);
    final result = existing == null
        ? await repository.create(
            TransactionDraft(
              type: type,
              amount: amount,
              categoryId: categoryId,
              occurredOn: occurredOn,
              note: note,
            ),
          )
        : await repository.update(
            existing.copyWith(
              type: type,
              amount: amount,
              categoryId: categoryId,
              occurredOn: occurredOn,
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
