import 'package:expense_tracker/core/db/converters/date_only_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = DateOnlyConverter();

  test('drops the time and stores yyyy-MM-dd', () {
    expect(converter.toSql(DateTime(2026, 3, 9, 23, 59)), '2026-03-09');
  });

  test('reads a date-only local DateTime', () {
    expect(converter.fromSql('2026-03-09'), DateTime(2026, 3, 9));
  });
}
