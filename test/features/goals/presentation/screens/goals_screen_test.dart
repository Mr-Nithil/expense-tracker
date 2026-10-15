import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/presentation/providers/goals_providers.dart';
import 'package:expense_tracker/features/goals/presentation/screens/goals_screen.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_tile.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_form_sheet.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/fake_sync_trigger.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  GoalProgress progress(String id, String name, int saved) => GoalProgress(
    goal: Goal(
      id: id,
      name: name,
      target: const Money(100000),
      icon: 'savings',
      color: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    saved: Money(saved),
  );

  final two = [progress('a', 'Laptop', 25000), progress('b', 'Bike', 100000)];

  List<Override> overrides(Stream<List<GoalProgress>> Function() goals) => [
    clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11, 9))),
    currencyCodeProvider.overrideWith((ref) async => 'USD'),
    goalsProvider.overrideWith((ref) => goals()),
    syncStatusProvider.overrideWith(
      (ref) => Stream.value(const SyncStatusInfo(SyncIndicator.synced)),
    ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    List<GoalProgress> goals, {
    Brightness brightness = Brightness.light,
    List<Override> extra = const [],
  }) async {
    await tester.pumpApp(
      const GoalsScreen(),
      brightness: brightness,
      overrides: [...overrides(() => Stream.value(goals)), ...extra],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('lists every goal', (tester, brightness) async {
    await pumpScreen(tester, two, brightness: brightness);

    expect(findText(l10n.goalsTitle), findsOneWidget);
    expect(find.byType(GoalTile), findsNWidgets(2));
    expect(findText('Laptop'), findsOneWidget);
    expect(findText('Bike'), findsOneWidget);
  });

  testWidgets('without goals shows the empty state', (tester) async {
    await pumpScreen(tester, const []);

    expect(findText(l10n.goalsEmptyTitle), findsOneWidget);
    expect(findText(l10n.goalsEmptyMessage), findsOneWidget);
  });

  testWidgets('the + button opens the new-goal sheet', (tester) async {
    await pumpScreen(tester, two);

    await tester.tap(find.byTooltip(l10n.goalsAdd));
    await tester.pumpAndSettle();

    expect(findText(l10n.goalFormNewTitle), findsOneWidget);
    expect(tester.widget<GoalFormSheet>(find.byType(GoalFormSheet)).goal, isNull);
  });

  testWidgets('the empty state offers to add a goal', (tester) async {
    await pumpScreen(tester, const []);

    await tester.tap(findWidgetWithText(FilledButton, l10n.goalsAdd));
    await tester.pumpAndSettle();

    expect(findText(l10n.goalFormNewTitle), findsOneWidget);
  });

  testWidgets('the app bar shows the sync state', (tester) async {
    await pumpScreen(tester, two);

    expect(find.byType(SyncStatusIndicator), findsOneWidget);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const GoalsScreen(),
      overrides: overrides(() {
        loads++;
        return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(two);
      }),
    );
    await tester.pumpAndSettle();
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.byType(GoalTile), findsNWidgets(2));
  });

  testWidgets('pulling the list syncs now', (tester) async {
    final trigger = FakeSyncTrigger();
    await pumpScreen(tester, two, extra: [trigger.providerOverride]);

    await tester.fling(findText('Laptop'), const Offset(0, 500), 1000);
    await tester.pumpAndSettle();

    expect(trigger.immediate, 1);
  });

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: GoalsScreen(),
      ),
      overrides: overrides(
        () => Stream.value([progress('a', 'Emergency fund for the house', 98765432100)]),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpScreen(tester, two, brightness: brightness);
      await expectAccessible(tester);
      await scrollThrough(tester);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpScreen(tester, two);
      await scrollThrough(tester);
    });
  });
}
