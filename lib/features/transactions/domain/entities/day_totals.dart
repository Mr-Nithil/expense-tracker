import 'package:expense_tracker/core/utils/money.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_totals.freezed.dart';

/// One day's income and expenses (non-deleted transactions), and what is left.
@freezed
abstract class DayTotals with _$DayTotals {
  const factory DayTotals({
    /// The day (local midnight).
    required DateTime date,
    required Money income,
    required Money expense,
  }) = _DayTotals;

  const DayTotals._();

  /// Income minus expenses; negative when more was spent than earned.
  Money get net => income - expense;
}
