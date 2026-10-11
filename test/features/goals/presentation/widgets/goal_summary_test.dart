import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/presentation/widgets/goal_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final today = DateTime(2026, 10, 11);

  GoalProgress progress(int saved, {DateTime? deadline}) => GoalProgress(
    goal: Goal(
      id: 'g',
      name: 'Laptop',
      target: const Money(150000),
      deadlineOn: deadline,
      icon: 'savings',
      color: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    saved: Money(saved),
  );

  Future<void> pump(WidgetTester tester, GoalProgress p, {Brightness b = Brightness.light}) =>
      tester.pumpApp(
        SingleChildScrollView(
          child: GoalSummary(progress: p, today: today, currencyCode: 'USD'),
        ),
        brightness: b,
      );

  ProgressRing ring(WidgetTester tester) => tester.widget(find.byType(ProgressRing));

  testWidgetsBothThemes('on track with a deadline: what is left and what to save monthly', (
    tester,
    brightness,
  ) async {
    await pump(tester, progress(50000, deadline: DateTime(2027, 1, 15)), b: brightness);

    expect(find.text(l10n.goalsPercent(33)), findsOneWidget);
    expect(find.text(l10n.goalsSavedOfTarget(r'$500.00', r'$1,500.00')), findsOneWidget);
    expect(find.text(l10n.goalDetailRemaining(r'$1,000.00')), findsOneWidget);
    expect(
      find.text(l10n.goalDetailNeededPerMonth(r'$250.00', 'Jan 15, 2027')),
      findsOneWidget,
    );
    expect(ring(tester).level, ProgressLevel.normal);
  });

  testWidgets('without a deadline only what is left', (tester) async {
    await pump(tester, progress(50000));

    expect(find.text(l10n.goalDetailRemaining(r'$1,000.00')), findsOneWidget);
    expect(find.textContaining('a month'), findsNothing);
  });

  testWidgets('a reached goal says so with a full success ring', (tester) async {
    await pump(tester, progress(150000, deadline: DateTime(2026, 1)));

    expect(find.text(l10n.goalDetailCompleted), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(ring(tester).value, 1.0);
    expect(ring(tester).level, ProgressLevel.complete);
    expect(find.text(l10n.goalDetailOverdue('Jan 1, 2026')), findsNothing);
  });

  testWidgets('past its deadline and not reached: overdue', (tester) async {
    await pump(tester, progress(20000, deadline: DateTime(2026, 9, 30)));

    expect(find.text(l10n.goalDetailOverdue('Sep 30, 2026')), findsOneWidget);
    expect(find.textContaining('a month'), findsNothing);
  });
}
