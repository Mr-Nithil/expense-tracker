import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_form_sheet.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_database.dart';

void main() {
  final l10n = AppLocalizationsEn();

  late FakeNotificationService notifications;
  late ProviderContainer container;

  /// The real repository on an in-memory DB; notifications and sync are fakes.
  Future<void> pump(WidgetTester tester, {List<String> titles = const []}) async {
    notifications = FakeNotificationService();
    await tester.pumpApp(
      const RemindersScreen(),
      overrides: [
        databaseProvider.overrideWithValue(createTestDatabase()),
        FakeSyncTrigger().providerOverride,
        notifications.providerOverride,
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9))),
      ],
    );
    container = ProviderScope.containerOf(tester.element(find.byType(RemindersScreen)));
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    await tester.runAsync(() async {
      for (final title in titles) {
        await container
            .read(reminderRepositoryProvider)
            .create(
              ReminderDraft(
                title: title,
                time: const ReminderTime(hour: 20, minute: 0),
                repeat: ReminderRepeat.daily,
              ),
            );
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }

  testWidgets('without reminders it offers to add one', (tester) async {
    await pump(tester);

    expect(find.text(l10n.remindersEmptyTitle), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, l10n.remindersAdd));
    await tester.pumpAndSettle();

    expect(find.byType(ReminderFormSheet), findsOneWidget);
  });

  testWidgets('lists reminders; tapping one edits it', (tester) async {
    await pump(tester, titles: ['Log expenses', 'Check budget']);

    expect(find.byType(ReminderTile), findsNWidgets(2));
    await tester.tap(find.text('Log expenses'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.reminderFormEditTitle), findsOneWidget);
  });

  testWidgets('switching a reminder off does not ask for permission', (tester) async {
    await pump(tester, titles: ['Log expenses']);

    await tester.tap(find.byType(Switch));
    await settle(tester);

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(notifications.permissionRequests, 0);
  });

  testWidgets('switching one on asks for permission; a refusal is explained', (tester) async {
    await pump(tester, titles: ['Log expenses']);
    await tester.tap(find.byType(Switch));
    await settle(tester);
    notifications.permissionGranted = false;

    await tester.tap(find.byType(Switch));
    await settle(tester);

    expect(notifications.permissionRequests, 1);
    expect(find.text(l10n.remindersPermissionDenied), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('saving a new reminder asks for permission', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip(l10n.remindersAdd));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.reminderFormTitleLabel),
      'Log expenses',
    );
    await tester.tap(find.text(l10n.commonSave));
    await settle(tester);

    expect(find.byType(ReminderTile), findsOneWidget);
    expect(notifications.permissionRequests, 1);
  });
}
