import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/app_switch.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final reminder = Reminder(
    id: 'r',
    title: 'Log expenses',
    time: const ReminderTime(hour: 20, minute: 30),
    repeat: ReminderRepeat.daily,
    enabled: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  testWidgetsBothThemes('shows the title, schedule and switch; reports taps and toggles', (
    tester,
    brightness,
  ) async {
    var taps = 0;
    bool? toggled;
    await tester.pumpApp(
      ReminderTile(reminder: reminder, onTap: () => taps++, onToggle: (on) => toggled = on),
      brightness: brightness,
    );

    expect(findText('Log expenses'), findsOneWidget);
    expect(findText(l10n.reminderEveryDay('8:30 PM')), findsOneWidget);
    expect(tester.widget<AppSwitch>(find.byType(AppSwitch)).value, isTrue);

    await tester.tap(find.byType(AppSwitch));
    expect(toggled, isFalse);
    await tester.tap(findText('Log expenses'));
    expect(taps, 1);
  });

  testWidgets('the switch is labelled for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(ReminderTile(reminder: reminder, onToggle: (_) {}));

    expect(find.bySemanticsLabel(l10n.reminderSwitchLabel('Log expenses')), findsOneWidget);
    handle.dispose();
  });
}
