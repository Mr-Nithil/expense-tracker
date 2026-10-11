import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionType { expense, income }

/// An income or expense. [amount] is always positive; [type] gives the direction.
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required Money amount,
    required String categoryId,

    /// Date-only (local midnight).
    required DateTime occurredOn,
    String? note,

    /// Soft-deleted (only visible by id, e.g. for undo).
    required bool isDeleted,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;
}

/// The user-entered part of a new transaction. The repository sets id and timestamps.
@freezed
abstract class TransactionDraft with _$TransactionDraft {
  const factory TransactionDraft({
    required TransactionType type,
    required Money amount,
    required String categoryId,
    required DateTime occurredOn,
    String? note,
  }) = _TransactionDraft;
}

/// Which transactions to list: one month, optionally narrowed by type and category.
@freezed
abstract class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    /// Any day in the month; only year and month are used.
    required DateTime month,
    TransactionType? type,
    String? categoryId,
  }) = _TransactionFilter;

  const TransactionFilter._();

  DateRange get range => AppDateUtils.monthRange(month);

  /// Whether a type or category narrows the month.
  bool get isNarrowed => type != null || categoryId != null;
}
