import 'package:expense_tracker/core/services/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminder payloads round-trip', () {
    const payload = ReminderPayload('3f2c0d8e-0000-4000-8000-000000000001');

    expect(payload.encode(), 'reminder:3f2c0d8e-0000-4000-8000-000000000001');
    expect(NotificationPayload.parse(payload.encode()), payload);
  });

  test('budget payloads round-trip as yyyy-MM', () {
    final payload = BudgetPayload(DateTime(2026, 3));

    expect(payload.encode(), 'budget:2026-03');
    expect(NotificationPayload.parse('budget:2026-03'), payload);
  });

  test('unknown or malformed payloads are null', () {
    for (final bad in [
      null,
      '',
      'reminder:',
      'budget:2026-13',
      'budget:2026-3',
      'budget:march',
      'goal:abc',
    ]) {
      expect(NotificationPayload.parse(bad), isNull, reason: '$bad');
    }
  });
}
