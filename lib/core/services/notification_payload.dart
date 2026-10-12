/// What a notification opens when tapped, as its payload string. Written by the features that
/// schedule notifications and read by the tap router, so both sides share one format.
sealed class NotificationPayload {
  const NotificationPayload();

  /// `null` for anything unknown or malformed (e.g. left by an older app version).
  static NotificationPayload? parse(String? payload) {
    if (payload == null) return null;
    if (payload.startsWith(ReminderPayload.prefix)) {
      final id = payload.substring(ReminderPayload.prefix.length);
      return id.isEmpty ? null : ReminderPayload(id);
    }
    if (payload.startsWith(BudgetPayload.prefix)) {
      final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(
        payload.substring(BudgetPayload.prefix.length),
      );
      if (match == null) return null;
      final month = int.parse(match.group(2)!);
      if (month < 1 || month > 12) return null;
      return BudgetPayload(DateTime(int.parse(match.group(1)!), month));
    }
    return null;
  }

  String encode();
}

/// A reminder's notification: opens the reminders screen.
final class ReminderPayload extends NotificationPayload {
  const ReminderPayload(this.reminderId);

  static const prefix = 'reminder:';

  final String reminderId;

  @override
  String encode() => '$prefix$reminderId';

  @override
  bool operator ==(Object other) => other is ReminderPayload && other.reminderId == reminderId;

  @override
  int get hashCode => reminderId.hashCode;
}

/// A budget alert: opens the Budget tab on [month] (its first day).
final class BudgetPayload extends NotificationPayload {
  const BudgetPayload(this.month);

  static const prefix = 'budget:';

  final DateTime month;

  @override
  String encode() =>
      '$prefix${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is BudgetPayload && other.month.year == month.year && other.month.month == month.month;

  @override
  int get hashCode => Object.hash(month.year, month.month);
}
