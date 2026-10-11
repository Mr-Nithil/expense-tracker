import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'month_totals.freezed.dart';

/// A month's income and expenses (non-deleted transactions), and what is left.
@freezed
abstract class MonthTotals with _$MonthTotals {
  const factory MonthTotals({required Money income, required Money expense}) = _MonthTotals;

  const MonthTotals._();

  static const zero = MonthTotals(income: Money.zero, expense: Money.zero);

  /// Income minus expenses; negative when more was spent than earned.
  Money get balance => income - expense;
}
