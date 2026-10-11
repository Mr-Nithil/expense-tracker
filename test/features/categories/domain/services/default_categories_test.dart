import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keys are unique, valid icon keys, and both types are covered', () {
    final keys = DefaultCategories.all.map((s) => s.key);
    expect(keys.toSet(), hasLength(DefaultCategories.all.length));
    for (final key in keys) {
      expect(key, matches(RegExp(r'^[a-z_]+$')));
    }
    final types = DefaultCategories.all.map((s) => s.type).toSet();
    expect(types, CategoryType.values.toSet());
  });

  test('ids are deterministic per user and differ between users', () {
    expect(DefaultCategories.idFor('u1', 'food'), DefaultCategories.idFor('u1', 'food'));
    expect(DefaultCategories.idFor('u1', 'food'), isNot(DefaultCategories.idFor('u2', 'food')));
    expect(DefaultCategories.idFor('u1', 'food'), isNot(DefaultCategories.idFor('u1', 'bills')));
  });

  test('the seed timestamp is UTC and older than any real edit', () {
    expect(DefaultCategories.seedTimestamp.isUtc, isTrue);
    expect(DefaultCategories.seedTimestamp.year, 2000);
  });
}
