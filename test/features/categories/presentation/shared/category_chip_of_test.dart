import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/shared/category_chip_of.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 10);
  Category food({bool archived = false}) => Category(
    id: 'food',
    name: 'Food',
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: true,
    sortOrder: 0,
    isArchived: archived,
    createdAt: at,
    updatedAt: at,
  );

  test('maps an active category', () {
    final chip = categoryChipOf(food());
    expect(chip.label, 'Food');
    expect(chip.iconKey, 'food');
    expect(chip.color, 0xFFEF6C00);
    expect(chip.isArchived, isFalse);
  });

  test('marks an archived category', () {
    expect(categoryChipOf(food(archived: true)).isArchived, isTrue);
  });

  test('a missing category is unknown', () {
    final chip = categoryChipOf(null);
    expect(chip.label, isNull);
    expect(chip.color, isNull);
  });

  test('passes selection and taps through', () {
    var taps = 0;
    final chip = categoryChipOf(food(), selected: true, onTap: () => taps++);
    expect(chip.selected, isTrue);
    chip.onTap!();
    expect(taps, 1);
  });
}
