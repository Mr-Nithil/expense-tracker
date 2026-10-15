import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);

  BudgetProgress progress(int spent) => BudgetProgress(
    budget: Budget(
      id: 'b',
      month: DateTime(2026, 10),
      limit: const Money(10000),
      createdAt: at,
      updatedAt: at,
    ),
    spent: Money(spent),
  );

  Future<void> pump(WidgetTester tester, int spent, {Brightness brightness = Brightness.light}) =>
      tester.pumpApp(
        BudgetProgressDetails(progress: progress(spent), currencyCode: 'USD', label: 'Food'),
        brightness: brightness,
      );

  ProgressLevel level(WidgetTester tester) =>
      tester.widget<ProgressBar>(find.byType(ProgressBar)).level;

  AppColors colors(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(ProgressBar))).extension<AppColors>()!;

  testWidgets('below 80%: normal bar, no status label', (tester) async {
    await pump(tester, 7999);

    expect(level(tester), ProgressLevel.normal);
    expect(findText(l10n.budgetStatusWarning), findsNothing);
    expect(findText(l10n.budgetStatusExceeded), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgetsBothThemes('from 80%: warning bar and "Close to limit"', (tester, brightness) async {
    await pump(tester, 8000, brightness: brightness);

    expect(level(tester), ProgressLevel.warning);
    expect(findText(l10n.budgetRemaining(r'$20.00')), findsOneWidget);
    final label = tester.widget<Text>(findText(l10n.budgetStatusWarning));
    expect(label.style?.color, colors(tester).warning);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded)).color,
      colors(tester).warning,
    );
  });

  testWidgetsBothThemes('at the limit: exceeded bar and "Limit reached"', (
    tester,
    brightness,
  ) async {
    await pump(tester, 10000, brightness: brightness);

    expect(level(tester), ProgressLevel.exceeded);
    expect(findText(l10n.budgetRemaining(r'$0.00')), findsOneWidget);
    final label = tester.widget<Text>(findText(l10n.budgetStatusExceeded));
    expect(label.style?.color, colors(tester).expense);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('over the limit: says how far over, still exceeded', (tester) async {
    await pump(tester, 12500);

    expect(level(tester), ProgressLevel.exceeded);
    expect(findText(l10n.budgetOver(r'$25.00')), findsOneWidget);
    expect(findText(l10n.budgetStatusExceeded), findsOneWidget);
  });

  testWidgets('the status icon is not read out; the label is', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, 9000);

    expect(find.bySemanticsLabel(l10n.budgetStatusWarning), findsOneWidget);
    handle.dispose();
  });

  testWidgets('wraps instead of overflowing on a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: BudgetProgressDetails(
          progress: BudgetProgress(
            budget: Budget(
              id: 'b',
              month: DateTime(2026, 10),
              limit: const Money(123456789),
              createdAt: at,
              updatedAt: at,
            ),
            spent: const Money(987654321),
          ),
          currencyCode: 'USD',
          label: 'Food',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(findText(l10n.budgetStatusExceeded), findsOneWidget);
  });
}
