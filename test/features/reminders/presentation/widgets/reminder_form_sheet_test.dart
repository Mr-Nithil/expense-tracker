import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/reminder_repository.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  // A Sunday.
  final now = DateTime(2026, 10, 11, 9);
  final existing = Reminder(
    id: 'r',
    title: 'Pay rent',
    time: const ReminderTime(hour: 9, minute: 0),
    repeat: ReminderRepeat.monthly,
    dayOfMonth: 1,
    enabled: true,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  late _MockReminderRepository repository;
  bool? popped;

  setUpAll(() {
    registerFallbackValue(
      const ReminderDraft(
        title: 'x',
        time: ReminderTime(hour: 0, minute: 0),
        repeat: ReminderRepeat.daily,
      ),
    );
    registerFallbackValue(existing);
  });

  setUp(() {
    popped = null;
    repository = _MockReminderRepository();
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(existing));
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(existing));
    when(() => repository.delete(any())).thenAnswer((_) async => Result.ok);
  });

  Future<void> open(
    WidgetTester tester, {
    Reminder? reminder,
    Brightness b = Brightness.light,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => popped = await ReminderFormSheet.show(context, reminder: reminder),
          child: const Text('open'),
        ),
      ),
      brightness: b,
      overrides: [
        reminderRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(now)),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder titleField() => find.widgetWithText(TextFormField, l10n.reminderFormTitleLabel);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) => tapVisible(tester, find.text(l10n.commonSave));

  testWidgetsBothThemes('a new reminder is daily at 8:00 PM', (tester, brightness) async {
    await open(tester, b: brightness);

    expect(find.text(l10n.reminderFormNewTitle), findsOneWidget);
    expect(find.text('8:00 PM'), findsOneWidget);
    expect(find.text(l10n.reminderFormDaysLabel), findsNothing);
  });

  testWidgets('creates a daily reminder and pops true', (tester) async {
    await open(tester);

    await tester.enterText(titleField(), 'Log expenses');
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as ReminderDraft;
    expect(draft.title, 'Log expenses');
    expect(draft.repeat, ReminderRepeat.daily);
    expect(draft.time, ReminderFormSheet.defaultTime);
    expect(popped, isTrue);
  });

  testWidgets('weekly starts on today\'s weekday and saves the chosen days', (tester) async {
    await open(tester);
    await tester.enterText(titleField(), 'Gym budget check');

    await tapVisible(tester, find.text(l10n.reminderRepeatWeekly));
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Sun')).selected, isTrue);
    await tapVisible(tester, find.widgetWithText(FilterChip, 'Wed'));
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as ReminderDraft;
    expect(draft.repeat, ReminderRepeat.weekly);
    expect(draft.weekdays, {DateTime.sunday, DateTime.wednesday});
  });

  testWidgets('monthly offers days 1–31 with the short-month note', (tester) async {
    await open(tester);
    await tester.enterText(titleField(), 'Rent');

    await tapVisible(tester, find.text(l10n.reminderRepeatMonthly));
    expect(find.text(l10n.reminderFormDayOfMonthHint), findsOneWidget);
    await tapVisible(tester, find.byType(DropdownButtonFormField<int>));
    // The menu builds the days around the current one (today, the 11th).
    await tester.tap(find.text('12').last);
    await tester.pumpAndSettle();
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as ReminderDraft;
    expect(draft.repeat, ReminderRepeat.monthly);
    expect(draft.dayOfMonth, 12);
  });

  testWidgets('the title is required', (tester) async {
    await open(tester);

    await save(tester);

    expect(find.text(l10n.errorFieldRequired), findsOneWidget);
    verifyNever(() => repository.create(any()));
  });

  testWidgets('shows the repository\'s weekday reason next to the days', (tester) async {
    when(() => repository.create(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(
          ReminderValidator.weekdaysRequired,
          field: ReminderValidator.weekdaysField,
        ),
      ),
    );
    await open(tester);
    await tester.enterText(titleField(), 'x');
    await tapVisible(tester, find.text(l10n.reminderRepeatWeekly));

    await save(tester);

    expect(find.text(l10n.errorReminderWeekdaysRequired), findsOneWidget);
    expect(find.byType(ReminderFormSheet), findsOneWidget);
  });

  testWidgets('edits keep the reminder; delete asks first and pops false', (tester) async {
    await open(tester, reminder: existing);

    expect(find.text(l10n.reminderFormEditTitle), findsOneWidget);
    expect(find.text('Pay rent'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget);

    await tapVisible(tester, find.text(l10n.reminderFormDelete));
    expect(find.text(l10n.reminderDeleteConfirmTitle('Pay rent')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, l10n.commonDelete));
    await tester.pumpAndSettle();

    verify(() => repository.delete('r')).called(1);
    expect(popped, isFalse);
  });

  testWidgets('saving an edit updates it', (tester) async {
    await open(tester, reminder: existing);

    await tester.enterText(titleField(), 'Pay the rent');
    await save(tester);

    final updated = verify(() => repository.update(captureAny())).captured.single as Reminder;
    expect(updated.id, 'r');
    expect(updated.title, 'Pay the rent');
    expect(updated.dayOfMonth, 1);
    expect(popped, isTrue);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await open(tester, b: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await open(tester);
      await scrollThrough(tester);
    });
  });
}
