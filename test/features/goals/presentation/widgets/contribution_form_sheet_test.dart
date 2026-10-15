import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/contribution_form_sheet.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final saved = GoalContribution(
    id: 'c',
    goalId: 'g',
    amount: const Money(5000),
    contributedOn: DateTime(2026, 10, 11),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  late _MockGoalRepository repository;

  setUpAll(() {
    registerFallbackValue(
      ContributionDraft(goalId: 'x', amount: Money.zero, contributedOn: DateTime(2026)),
    );
  });

  setUp(() {
    repository = _MockGoalRepository();
    when(() => repository.addContribution(any())).thenAnswer((_) async => Result.success(saved));
  });

  Future<void> open(WidgetTester tester, {Brightness b = Brightness.light}) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => ContributionFormSheet.show(context, goalId: 'g'),
          child: const Text('open'),
        ),
      ),
      brightness: b,
      overrides: [
        goalRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(now)),
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
      ],
    );
    await tester.tap(findText('open'));
    await tester.pumpAndSettle();
  }

  Finder amountField() => findWidgetWithText(TextFormField, l10n.goalContributionAmountLabel);
  Finder noteField() => findWidgetWithText(TextFormField, l10n.goalContributionNoteLabel);

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(findText(l10n.commonSave));
    await tester.tap(findText(l10n.commonSave));
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('starts on today', (tester, brightness) async {
    await open(tester, b: brightness);

    expect(findText(l10n.goalsAddMoney), findsOneWidget);
    expect(findText('Oct 11, 2026'), findsOneWidget);
  });

  testWidgets('adds money with a note and closes', (tester) async {
    await open(tester);

    await tester.enterText(amountField(), '50');
    await tester.enterText(noteField(), 'bonus');
    await save(tester);

    final draft =
        verify(() => repository.addContribution(captureAny())).captured.single as ContributionDraft;
    expect(draft.goalId, 'g');
    expect(draft.amount, const Money(5000));
    expect(draft.contributedOn, DateTime(2026, 10, 11));
    expect(draft.note, 'bonus');
    expect(find.byType(ContributionFormSheet), findsNothing);
  });

  testWidgets('an earlier date can be picked', (tester) async {
    await open(tester);
    await tester.enterText(amountField(), '50');

    await tester.tap(findText('Oct 11, 2026'));
    await tester.pumpAndSettle();
    await tester.tap(findText('3'));
    await tester.tap(findText('OK'));
    await tester.pumpAndSettle();
    await save(tester);

    final draft =
        verify(() => repository.addContribution(captureAny())).captured.single as ContributionDraft;
    expect(draft.contributedOn, DateTime(2026, 10, 3));
  });

  testWidgets('the amount is required', (tester) async {
    await open(tester);

    await save(tester);

    expect(findText(l10n.errorFieldRequired), findsOneWidget);
    verifyNever(() => repository.addContribution(any()));
  });

  testWidgets('a deleted goal is explained and the sheet stays', (tester) async {
    when(() => repository.addContribution(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(GoalValidator.goalNotFound, field: GoalValidator.goalField),
      ),
    );
    await open(tester);
    await tester.enterText(amountField(), '50');

    await save(tester);

    expect(findText(l10n.errorGoalNotFound), findsOneWidget);
    expect(find.byType(ContributionFormSheet), findsOneWidget);
  });

  testWidgets('a future date from the repository is shown under the date', (tester) async {
    when(() => repository.addContribution(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(GoalValidator.dateOutOfRange, field: GoalValidator.dateField),
      ),
    );
    await open(tester);
    await tester.enterText(amountField(), '50');

    await save(tester);

    expect(findText(l10n.errorGoalContributionDateOutOfRange), findsOneWidget);
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
