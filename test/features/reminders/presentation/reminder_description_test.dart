import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/presentation/reminder_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Reminder reminder({
    ReminderRepeat repeat = ReminderRepeat.daily,
    Set<int> weekdays = const {},
    int? dayOfMonth,
  }) => Reminder(
    id: 'r',
    title: 'Log expenses',
    time: const ReminderTime(hour: 20, minute: 30),
    repeat: repeat,
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
    enabled: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  Future<String> describe(WidgetTester tester, Reminder r, {bool use24h = false}) async {
    late String text;
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(alwaysUse24HourFormat: use24h),
        child: Builder(
          builder: (context) {
            text = ReminderDescription.of(context, r);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return text;
  }

  testWidgets('daily reads "Every day at …" in the device\'s 12-hour format', (tester) async {
    expect(await describe(tester, reminder()), l10n.reminderEveryDay('8:30 PM'));
  });

  testWidgets('follows the 24-hour setting', (tester) async {
    expect(await describe(tester, reminder(), use24h: true), l10n.reminderEveryDay('20:30'));
  });

  testWidgets('weekly lists the days in the locale\'s week order (Sunday first in en_US)', (
    tester,
  ) async {
    final text = await describe(
      tester,
      reminder(
        repeat: ReminderRepeat.weekly,
        weekdays: {DateTime.thursday, DateTime.sunday, DateTime.monday},
      ),
    );

    expect(text, l10n.reminderWeekly('Sun, Mon, Thu', '8:30 PM'));
  });

  testWidgets('monthly names the day', (tester) async {
    expect(
      await describe(tester, reminder(repeat: ReminderRepeat.monthly, dayOfMonth: 31)),
      l10n.reminderMonthly(31, '8:30 PM'),
    );
  });

  testWidgets('week order starts on the locale\'s first day', (tester) async {
    late List<int> order;
    await tester.pumpApp(
      Builder(
        builder: (context) {
          order = ReminderDescription.weekdaysInLocaleOrder(context);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(order, [7, 1, 2, 3, 4, 5, 6]);
  });
}
