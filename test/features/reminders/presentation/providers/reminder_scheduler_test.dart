import 'package:expense_tracker/core/services/notification_payload.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/reminder_repository.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_notification_plan.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_notification_service.dart';
import '../../../../helpers/test_database.dart';

void main() {
  // Sunday, October 11 2026, 18:00.
  final now = DateTime(2026, 10, 11, 18);

  late ProviderContainer container;
  late FakeNotificationService notifications;
  late ReminderRepository repository;

  setUp(() {
    notifications = FakeNotificationService();
    container = createTestContainer(
      overrides: [clockProvider.overrideWithValue(FixedClock(now)), notifications.providerOverride],
    );
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
    repository = container.read(reminderRepositoryProvider);
    // Listened, as `App` watches it: a provider that is only read is paused (Riverpod 3).
    container.listen(reminderSchedulerProvider, (_, _) {});
  });

  Future<Reminder> create(ReminderDraft draft) async {
    final reminder = (await repository.create(draft)).valueOrNull!;
    await pumpEventQueue();
    return reminder;
  }

  const daily = ReminderDraft(
    title: 'Log expenses',
    time: ReminderTime(hour: 20, minute: 0),
    repeat: ReminderRepeat.daily,
  );

  test('schedules a new reminder, repeating daily with its payload', () async {
    final reminder = await create(daily);

    final scheduled = notifications.scheduled[ReminderNotificationIds.of(reminder.id, 0)]!;
    expect(scheduled.title, 'Log expenses');
    expect(scheduled.firstAt, DateTime(2026, 10, 11, 20));
    expect(scheduled.every, RepeatEvery.day);
    expect(NotificationPayload.parse(scheduled.payload), ReminderPayload(reminder.id));
  });

  test('a weekly reminder gets one notification per day', () async {
    await create(
      const ReminderDraft(
        title: 'Budget check',
        time: ReminderTime(hour: 9, minute: 0),
        repeat: ReminderRepeat.weekly,
        weekdays: {DateTime.monday, DateTime.thursday},
      ),
    );

    expect(notifications.scheduled.values.map((s) => (s.every, s.firstAt)), [
      (RepeatEvery.week, DateTime(2026, 10, 12, 9)),
      (RepeatEvery.week, DateTime(2026, 10, 15, 9)),
    ]);
  });

  test('the 31st is scheduled as the next three dates, short months on their last day', () async {
    await create(
      const ReminderDraft(
        title: 'Pay rent',
        time: ReminderTime(hour: 9, minute: 0),
        repeat: ReminderRepeat.monthly,
        dayOfMonth: 31,
      ),
    );

    expect(notifications.scheduled, isEmpty);
    expect(notifications.once.values.map((o) => o.at), [
      DateTime(2026, 10, 31, 9),
      DateTime(2026, 11, 30, 9),
      DateTime(2026, 12, 31, 9),
    ]);
  });

  test('switching off or deleting cancels it', () async {
    final first = await create(daily);
    final second = await create(daily.copyWith(title: 'Check budget'));

    await repository.setEnabled(first.id, enabled: false);
    await pumpEventQueue();
    expect(notifications.scheduled.keys, [ReminderNotificationIds.of(second.id, 0)]);

    await repository.delete(second.id);
    await pumpEventQueue();
    expect(notifications.scheduled, isEmpty);
  });

  test('editing the time reschedules it', () async {
    final reminder = await create(daily);

    await repository.update(reminder.copyWith(time: const ReminderTime(hour: 7, minute: 30)));
    await pumpEventQueue();

    expect(notifications.scheduled.values.single.firstAt, DateTime(2026, 10, 12, 7, 30));
  });

  test('leaves other notifications alone', () async {
    notifications.otherPending.add(42);

    await create(daily);

    expect(notifications.otherPending, {42});
    expect(notifications.cancelled, isNot(contains(42)));
  });

  test('signing out cancels this user\'s reminder notifications', () async {
    await create(daily);

    container.read(sessionProvider.notifier).set(null);
    await pumpEventQueue();

    expect(notifications.scheduled, isEmpty);
  });

  test('rapid changes end with the latest reminders scheduled', () async {
    final reminder = (await repository.create(daily)).valueOrNull!;
    await repository.update(reminder.copyWith(title: 'Log today'));
    await repository.update(reminder.copyWith(title: 'Log today now'));
    await pumpEventQueue();

    expect(notifications.scheduled.values.single.title, 'Log today now');
  });
}
