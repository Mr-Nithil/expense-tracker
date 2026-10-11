import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/goals/data/goal_repository_provider.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/goal_repository.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockGoalRepository extends Mock implements GoalRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9);
  final laptop = Goal(
    id: 'g',
    name: 'Laptop',
    target: const Money(150000),
    deadlineOn: DateTime(2027, 6),
    icon: 'phone',
    color: CategoryPalette.colors[2],
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  late _MockGoalRepository repository;

  setUpAll(() {
    registerFallbackValue(const GoalDraft(name: 'x', target: Money(1), icon: 'x', color: 0));
    registerFallbackValue(laptop);
  });

  setUp(() {
    repository = _MockGoalRepository();
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(laptop));
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(laptop));
  });

  Future<void> open(WidgetTester tester, {Goal? goal, Brightness b = Brightness.light}) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => GoalFormSheet.show(context, goal: goal),
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
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.widgetWithText(TextFormField, l10n.goalFormNameLabel);
  Finder targetField() => find.widgetWithText(TextFormField, l10n.goalFormTargetLabel);
  Finder sheet() => find.byType(GoalFormSheet);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) => tapVisible(tester, find.text(l10n.commonSave));

  testWidgetsBothThemes('a new goal starts without a deadline, with the default icon', (
    tester,
    brightness,
  ) async {
    await open(tester, b: brightness);

    expect(find.text(l10n.goalFormNewTitle), findsOneWidget);
    expect(find.text(l10n.goalFormNoDeadline), findsOneWidget);
    expect(find.byTooltip(l10n.goalFormClearDeadline), findsNothing);
    final preview = tester.widget<CategoryIcon>(find.byType(CategoryIcon).first);
    expect(preview.iconKey, GoalFormSheet.defaultIcon);
  });

  testWidgets('creates a goal and closes', (tester) async {
    await open(tester);

    await tester.enterText(nameField(), '  Bike ');
    await tester.enterText(targetField(), '400');
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as GoalDraft;
    expect(draft.name, '  Bike ');
    expect(draft.target, const Money(40000));
    expect(draft.deadlineOn, isNull);
    expect(draft.icon, GoalFormSheet.defaultIcon);
    expect(draft.color, CategoryPalette.colors.first);
    expect(sheet(), findsNothing);
  });

  testWidgets('picks a deadline from the date picker', (tester) async {
    await open(tester);
    await tester.enterText(nameField(), 'Bike');
    await tester.enterText(targetField(), '400');

    await tapVisible(tester, find.text(l10n.goalFormNoDeadline));
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Oct 20, 2026'), findsOneWidget);
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as GoalDraft;
    expect(draft.deadlineOn, DateTime(2026, 10, 20));
  });

  testWidgets('edits a goal: fields are filled, the deadline can be removed', (tester) async {
    await open(tester, goal: laptop);

    expect(find.text(l10n.goalFormEditTitle), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('1500.00'), findsOneWidget);
    expect(find.text('Jun 1, 2027'), findsOneWidget);

    await tapVisible(tester, find.byTooltip(l10n.goalFormClearDeadline));
    expect(find.text(l10n.goalFormNoDeadline), findsOneWidget);
    await save(tester);

    final updated = verify(() => repository.update(captureAny())).captured.single as Goal;
    expect(updated.id, 'g');
    expect(updated.deadlineOn, isNull);
    expect(updated.icon, 'phone');
    expect(sheet(), findsNothing);
  });

  testWidgets('choosing an icon and a color updates the preview and is saved', (tester) async {
    await open(tester);
    await tester.enterText(nameField(), 'Trip');
    await tester.enterText(targetField(), '900');

    await tapVisible(
      tester,
      find.bySemanticsLabel(l10n.categoryFormIconOption(2, CategoryIcon.keys.length)),
    );
    await tapVisible(
      tester,
      find.bySemanticsLabel(l10n.categoryFormColorOption(3, CategoryPalette.colors.length)),
    );
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as GoalDraft;
    expect(draft.icon, CategoryIcon.keys.elementAt(1));
    expect(draft.color, CategoryPalette.colors[2]);
  });

  testWidgets('name and target are required before saving', (tester) async {
    await open(tester);

    await save(tester);

    expect(find.text(l10n.errorFieldRequired), findsNWidgets(2));
    verifyNever(() => repository.create(any()));
    expect(sheet(), findsOneWidget);
  });

  testWidgets('shows a deadline the repository rejects next to the deadline', (tester) async {
    when(() => repository.create(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(GoalValidator.deadlineOutOfRange, field: GoalValidator.deadlineField),
      ),
    );
    await open(tester);
    await tester.enterText(nameField(), 'Bike');
    await tester.enterText(targetField(), '400');

    await save(tester);

    expect(
      find.text(l10n.errorGoalDeadlineOutOfRange(GoalValidator.maxDeadlineYearsAhead)),
      findsOneWidget,
    );
    expect(sheet(), findsOneWidget);
  });

  testWidgets('a storage error shows above Save and keeps the sheet', (tester) async {
    when(
      () => repository.create(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
    await open(tester);
    await tester.enterText(nameField(), 'Bike');
    await tester.enterText(targetField(), '400');

    await save(tester);

    expect(find.text(l10n.errorStorage), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });
}
