import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/core/widgets/progress_ring.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal_progress.dart';
import 'package:expense_tracker/features/goals/presentation/shared/goal_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  GoalProgress progress({int saved = 50000, DateTime? deadline}) => GoalProgress(
    goal: Goal(
      id: 'g',
      name: 'Laptop',
      target: const Money(150000),
      deadlineOn: deadline,
      icon: 'savings',
      color: 0xFF2E7D32,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    saved: Money(saved),
  );

  Future<void> pump(WidgetTester tester, GoalProgress p, {Brightness b = Brightness.light}) =>
      tester.pumpApp(
        GoalTile(progress: p, currencyCode: 'USD'),
        brightness: b,
      );

  ProgressRing ring(WidgetTester tester) => tester.widget(find.byType(ProgressRing));

  testWidgetsBothThemes('shows the goal, saved of target, deadline and a ring', (
    tester,
    brightness,
  ) async {
    await pump(tester, progress(deadline: DateTime(2027, 6)), b: brightness);

    expect(findText('Laptop'), findsOneWidget);
    expect(find.byType(CategoryIcon), findsOneWidget);
    expect(
      findText(
        l10n.goalsListSubtitle(
          l10n.goalsSavedOfTarget(r'$500.00', r'$1,500.00'),
          l10n.goalsDeadline('Jun 1, 2027'),
        ),
      ),
      findsOneWidget,
    );
    expect(findText(l10n.goalsPercent(33)), findsOneWidget);
    expect(ring(tester).value, closeTo(1 / 3, 1e-9));
    expect(ring(tester).level, ProgressLevel.normal);
  });

  testWidgets('without a deadline shows only the amounts', (tester) async {
    await pump(tester, progress());

    expect(findText(l10n.goalsSavedOfTarget(r'$500.00', r'$1,500.00')), findsOneWidget);
  });

  testWidgets('a reached goal says Completed (over the deadline) with a full success ring', (
    tester,
  ) async {
    await pump(tester, progress(saved: 160000, deadline: DateTime(2027, 6)));

    expect(
      findText(
        l10n.goalsListSubtitle(
          l10n.goalsSavedOfTarget(r'$1,600.00', r'$1,500.00'),
          l10n.goalsCompleted,
        ),
      ),
      findsOneWidget,
    );
    expect(findText(l10n.goalsPercent(106)), findsOneWidget);
    expect(ring(tester).value, 1.0);
    expect(ring(tester).level, ProgressLevel.complete);
  });

  testWidgets('is read out as one item', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, progress());

    expect(
      find.bySemanticsLabel(RegExp(r'Laptop.*\$500\.00 of \$1,500\.00', dotAll: true)),
      findsOneWidget,
    );
    handle.dispose();
  });
}
