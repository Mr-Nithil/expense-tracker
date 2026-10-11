import 'package:expense_tracker/features/transactions/data/mappers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every transaction type round-trips through its DB value', () {
    for (final type in TransactionType.values) {
      expect(TransactionTypeDb.fromDb(type.dbValue), type);
    }
    expect(TransactionType.values.map((t) => t.dbValue), ['expense', 'income']);
  });

  test('an unexpected DB value fails loudly instead of being guessed', () {
    expect(() => TransactionTypeDb.fromDb('transfer'), throwsArgumentError);
  });
}
