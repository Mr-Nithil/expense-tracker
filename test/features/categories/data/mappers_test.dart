import 'package:expense_tracker/features/categories/data/mappers.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every category type round-trips through its DB value', () {
    for (final type in CategoryType.values) {
      expect(CategoryTypeDb.fromDb(type.dbValue), type);
    }
    expect(CategoryType.values.map((t) => t.dbValue), ['expense', 'income']);
  });

  test('an unexpected DB value fails loudly instead of being guessed', () {
    expect(() => CategoryTypeDb.fromDb('savings'), throwsArgumentError);
  });
}
