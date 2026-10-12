import 'package:expense_tracker/core/utils/stable_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FNV-1a matches its reference values', () {
    expect(StableHash.fnv1a(''), 0x811c9dc5);
    expect(StableHash.fnv1a('a'), 0xe40c292c);
    expect(StableHash.fnv1a('foobar'), 0xbf9cf968);
  });

  test('stays within 32 bits', () {
    expect(StableHash.fnv1a('3f2c0d8e-0000-4000-8000-000000000001'), lessThan(1 << 32));
  });
}
