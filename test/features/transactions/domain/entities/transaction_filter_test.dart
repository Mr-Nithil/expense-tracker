import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final month = DateTime(2026, 10, 17);

  test('range is the whole month', () {
    expect(
      TransactionFilter(month: month).range,
      DateRange(DateTime(2026, 10), DateTime(2026, 11)),
    );
  });

  test('isNarrowed when a type or category is set', () {
    expect(TransactionFilter(month: month).isNarrowed, isFalse);
    expect(TransactionFilter(month: month, type: TransactionType.income).isNarrowed, isTrue);
    expect(TransactionFilter(month: month, categoryId: 'food').isNarrowed, isTrue);
  });
}
