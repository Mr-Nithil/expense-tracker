import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// A half-open date range: [start] inclusive, [end] exclusive.
@immutable
class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) => !value.isBefore(start) && value.isBefore(end);

  @override
  bool operator ==(Object other) => other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start, $end)';
}

/// Date-only helpers and locale-aware formatting.
///
/// "Date-only" values are local `DateTime`s at midnight. They are stored as `yyyy-MM-dd` text
/// (`*_on` columns) so they never shift across time zones.
abstract final class AppDateUtils {
  /// Strips the time: midnight (local) of the same calendar day.
  static DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  static DateTime monthStart(DateTime value) => DateTime(value.year, value.month);

  /// The first day of the following month.
  static DateTime nextMonthStart(DateTime value) => DateTime(value.year, value.month + 1);

  /// The whole month containing [value], as `[first day, first day of next month)`.
  static DateRange monthRange(DateTime value) =>
      DateRange(monthStart(value), nextMonthStart(value));

  static int daysInMonth(DateTime value) => DateTime(value.year, value.month + 1, 0).day;

  /// Adds [months] and clamps the day to the target month (Jan 31 + 1 month = Feb 28/29).
  static DateTime addMonths(DateTime value, int months) {
    final target = DateTime(value.year, value.month + months);
    final day = value.day.clamp(1, daysInMonth(target));
    return DateTime(target.year, target.month, day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  /// `yyyy-MM-dd`, the storage format for date-only columns.
  static String toIsoDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses `yyyy-MM-dd` into a date-only value. Throws [FormatException] if invalid.
  static DateTime parseIsoDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) throw FormatException('Invalid ISO date', value);
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    final date = DateTime(y, m, d);
    if (date.year != y || date.month != m || date.day != d) {
      throw FormatException('Invalid ISO date', value);
    }
    return date;
  }

  /// e.g. `Oct 3, 2026`.
  static String formatShortDate(DateTime value, String locale) =>
      DateFormat.yMMMd(locale).format(value);

  /// e.g. `Sat, Oct 3` (no year), for list headers within a month.
  static String formatWeekdayDate(DateTime value, String locale) =>
      DateFormat.MMMEd(locale).format(value);

  /// e.g. `Saturday, October 3, 2026`.
  static String formatLongDate(DateTime value, String locale) =>
      DateFormat.yMMMMEEEEd(locale).format(value);

  /// e.g. `October 2026`.
  static String formatMonthYear(DateTime value, String locale) =>
      DateFormat.yMMMM(locale).format(value);

  /// e.g. `14:05` or `2:05 PM`, depending on the locale.
  static String formatTime(DateTime value, String locale) => DateFormat.jm(locale).format(value);
}
