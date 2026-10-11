import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_spending.freezed.dart';

/// What was spent in one category over a period (non-deleted expenses).
@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({required String categoryId, required Money amount}) =
      _CategorySpending;
}
