import 'package:drift/drift.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';

/// Stores date-only values (`*_on` columns) as `yyyy-MM-dd` text.
///
/// Text sorts and compares correctly, maps 1:1 to the Postgres `date` type, and never shifts
/// across time zones.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) => AppDateUtils.parseIsoDate(fromDb);

  @override
  String toSql(DateTime value) => AppDateUtils.toIsoDate(value);
}
