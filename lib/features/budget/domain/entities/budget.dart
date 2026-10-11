import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

/// A monthly spending limit: the overall budget ([categoryId] null) or one expense category's.
///
/// There is at most one budget per (month, category); its id is derived from that key
/// (`BudgetValidator.idFor`), so it is the same on every device.
@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,

    /// First day of the month (local midnight).
    required DateTime month,
    String? categoryId,
    required Money limit,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;

  const Budget._();

  bool get isOverall => categoryId == null;
}
