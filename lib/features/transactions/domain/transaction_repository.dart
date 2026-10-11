import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

/// The signed-in user's transactions, in the local DB (synced later).
///
/// Writes validate input (see `TransactionValidator`, plus: the category must exist, match the
/// type and not be archived unless the transaction already uses it) and fail with
/// `ValidationFailure`, `NotFoundFailure`, `AuthFailure` (no session) or `StorageFailure`.
/// They never throw.
abstract interface class TransactionRepository {
  /// Non-deleted transactions matching [filter], newest first.
  Stream<List<Transaction>> watch(TransactionFilter filter);

  /// One transaction, including a soft-deleted one (`isDeleted`).
  Stream<Transaction?> watchById(String id);

  /// One non-deleted transaction, or `NotFoundFailure`.
  Future<Result<Transaction>> getById(String id);

  Future<Result<Transaction>> create(TransactionDraft draft);

  Future<Result<Transaction>> update(Transaction transaction);

  /// Soft delete. Restorable with [restore] (undo).
  Future<Result<void>> delete(String id);

  /// Undoes [delete].
  Future<Result<void>> restore(String id);
}
