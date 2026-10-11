import 'package:expense_tracker/features/categories/domain/services/category_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? reasonOf({String name = 'Food', String icon = 'food', int color = 0xFF4CAF50}) =>
      CategoryValidator.validate(name: name, icon: icon, color: color)?.message;

  test('accepts a valid category', () {
    expect(reasonOf(), isNull);
    expect(reasonOf(name: 'x' * CategoryValidator.maxNameLength), isNull);
    expect(reasonOf(color: 0), isNull);
    expect(reasonOf(color: 0xFFFFFFFF), isNull);
  });

  test('requires a name, ignoring surrounding whitespace', () {
    expect(reasonOf(name: ''), 'nameRequired');
    expect(reasonOf(name: '   '), 'nameRequired');
    expect(reasonOf(name: '  Food  '), isNull);
  });

  test('limits the trimmed name length', () {
    expect(reasonOf(name: 'x' * (CategoryValidator.maxNameLength + 1)), 'nameTooLong');
    expect(reasonOf(name: ' ${'x' * CategoryValidator.maxNameLength} '), isNull);
  });

  test('requires an icon key', () {
    expect(reasonOf(icon: ''), 'iconRequired');
    expect(reasonOf(icon: ' '), 'iconRequired');
  });

  test('rejects colors outside 32-bit ARGB', () {
    expect(reasonOf(color: -1), 'invalidColor');
    expect(reasonOf(color: 0x100000000), 'invalidColor');
  });

  test('reports the field that failed', () {
    final failure = CategoryValidator.validate(name: '', icon: 'food', color: 0);
    expect(failure?.field, CategoryValidator.nameField);
  });
}
