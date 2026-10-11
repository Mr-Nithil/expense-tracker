import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('colors are unique and fully opaque', () {
    expect(CategoryPalette.colors.toSet(), hasLength(CategoryPalette.colors.length));
    for (final color in CategoryPalette.colors) {
      expect(color >> 24, 0xFF, reason: color.toRadixString(16));
    }
  });

  test('every default category color can be picked', () {
    for (final spec in DefaultCategories.all) {
      expect(CategoryPalette.colors, contains(spec.color), reason: spec.key);
    }
  });
}
