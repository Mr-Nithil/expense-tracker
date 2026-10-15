import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_overall_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);

  BudgetProgress overall({required int limit, required int spent}) => BudgetProgress(
    budget: Budget(
      id: 'overall',
      month: DateTime(2026, 10),
      limit: Money(limit),
      createdAt: at,
      updatedAt: at,
    ),
    spent: Money(spent),
  );

  testWidgetsBothThemes('shows spent, limit, percent and what is left', (tester, brightness) async {
    await tester.pumpApp(
      BudgetOverallCard(overall: overall(limit: 50000, spent: 12500), currencyCode: 'USD'),
      brightness: brightness,
    );

    expect(findText(l10n.budgetOverallTitle), findsOneWidget);
    expect(findText(l10n.budgetSpentOfLimit(r'$125.00', r'$500.00')), findsOneWidget);
    expect(findText(l10n.budgetPercentUsed(25)), findsOneWidget);
    expect(findText(l10n.budgetRemaining(r'$375.00')), findsOneWidget);
    expect(tester.widget<ProgressBar>(find.byType(ProgressBar)).value, 0.25);
  });

  testWidgets('over budget: says how far over and fills the bar', (tester) async {
    await tester.pumpApp(
      BudgetOverallCard(overall: overall(limit: 10000, spent: 12000), currencyCode: 'USD'),
    );

    expect(findText(l10n.budgetPercentUsed(120)), findsOneWidget);
    expect(findText(l10n.budgetOver(r'$20.00')), findsOneWidget);
    expect(tester.widget<ProgressBar>(find.byType(ProgressBar)).value, 1.0);
  });

  testWidgets('without an overall budget it says none is set', (tester) async {
    await tester.pumpApp(const BudgetOverallCard(overall: null, currencyCode: 'USD'));

    expect(findText(l10n.budgetOverallEmptyTitle), findsOneWidget);
    expect(findText(l10n.budgetOverallEmptyMessage), findsOneWidget);
    expect(find.byType(ProgressBar), findsNothing);
  });

  testWidgets('fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      BudgetOverallCard(overall: null, currencyCode: 'USD', onTap: () => taps++),
    );

    await tester.tap(findText(l10n.budgetOverallEmptyTitle));

    expect(taps, 1);
  });

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: BudgetOverallCard(
          overall: overall(limit: 123456789, spent: 98765432),
          currencyCode: 'USD',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
