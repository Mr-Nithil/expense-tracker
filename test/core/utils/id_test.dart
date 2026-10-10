import 'package:expense_tracker/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final uuidV4 = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');
  final uuidV5 = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

  test('newId returns unique UUID v4 values', () {
    final ids = List.generate(1000, (_) => IdGenerator.newId());
    expect(ids.every(uuidV4.hasMatch), isTrue);
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('deterministic returns the same UUID v5 for the same parts', () {
    final a = IdGenerator.deterministic(['user-1', '2026-10-01', 'overall']);
    final b = IdGenerator.deterministic(['user-1', '2026-10-01', 'overall']);
    final c = IdGenerator.deterministic(['user-1', '2026-11-01', 'overall']);
    expect(a, matches(uuidV5));
    expect(a, b);
    expect(a, isNot(c));
  });
}
