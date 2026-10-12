/// Weekdays ↔ the stored bitmask: bit 0 = Monday … bit 6 = Sunday (`reminders.weekdays`).
/// Weekdays use `DateTime.monday` (1) … `DateTime.sunday` (7).
abstract final class WeekdayMask {
  static int encode(Set<int> weekdays) =>
      weekdays.fold(0, (mask, weekday) => mask | (1 << (weekday - DateTime.monday)));

  static Set<int> decode(int? mask) => {
    if (mask != null)
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        if (mask & (1 << (weekday - DateTime.monday)) != 0) weekday,
  };
}
