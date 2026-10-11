import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_list_controller.g.dart';

/// List actions: delete (soft) and its undo. Returns the [Result] so the list can show either
/// an Undo snackbar or the error. Kept alive because it is only used from callbacks.
@Riverpod(keepAlive: true)
class TransactionListController extends _$TransactionListController {
  @override
  void build() {}

  Future<Result<void>> delete(String id) => ref.read(transactionRepositoryProvider).delete(id);

  Future<Result<void>> restore(String id) => ref.read(transactionRepositoryProvider).restore(id);
}
