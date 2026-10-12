import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_form_controller.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_list_controller.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/test_database.dart';

void main() {
  late ProviderContainer container;
  late FakeNotificationService notifications;

  setUp(() {
    notifications = FakeNotificationService();
    container = createTestContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9))),
        notifications.providerOverride,
      ],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    container
      ..listen(remindersProvider, (_, _) {})
      ..listen(reminderFormControllerProvider, (_, _) {});
  });

  ReminderFormController form() => container.read(reminderFormControllerProvider.notifier);

  Future<void> save({ReminderRepeat repeat = ReminderRepeat.daily, Set<int> weekdays = const {}}) =>
      form().save(
        title: 'Log expenses',
        time: const ReminderTime(hour: 20, minute: 0),
        repeat: repeat,
        weekdays: weekdays,
        dayOfMonth: null,
      );

  test('saving a reminder lists it, switched on', () async {
    await save();
    await pumpEventQueue();

    expect(container.read(reminderFormControllerProvider), isA<AsyncData<void>>());
    final reminders = await container.read(remindersProvider.future);
    expect(reminders.single.title, 'Log expenses');
    expect(reminders.single.enabled, isTrue);
  });

  test('an invalid reminder keeps the failure for the form', () async {
    await save(repeat: ReminderRepeat.weekly);

    expect(
      (container.read(reminderFormControllerProvider).error! as ValidationFailure).message,
      ReminderValidator.weekdaysRequired,
    );
  });

  test('deleting removes it from the list', () async {
    await save();
    await pumpEventQueue();
    final id = (await container.read(remindersProvider.future)).single.id;

    await form().delete(id);
    await pumpEventQueue();

    expect(await container.read(remindersProvider.future), isEmpty);
  });

  test('the list controller switches reminders and asks for permission', () async {
    await save();
    await pumpEventQueue();
    final id = (await container.read(remindersProvider.future)).single.id;
    final list = container.read(reminderListControllerProvider.notifier);

    expect(await list.setEnabled(id, enabled: false), Result.ok);
    await pumpEventQueue();
    expect((await container.read(remindersProvider.future)).single.enabled, isFalse);

    notifications.permissionGranted = false;
    expect(await list.ensurePermission(), isFalse);
    expect(notifications.permissionRequests, 1);
  });

  test('saving does not ask for permission by itself', () async {
    await save();

    expect(notifications.permissionRequests, 0);
  });
}
