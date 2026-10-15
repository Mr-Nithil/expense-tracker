import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_summary_cards.dart';
import 'package:expense_tracker/features/transactions/domain/entities/month_totals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<void> pump(
    WidgetTester tester,
    MonthTotals totals, {
    Brightness brightness = Brightness.light,
  }) => tester.pumpApp(
    DashboardSummaryCards(totals: totals, currencyCode: 'USD'),
    brightness: brightness,
  );

  AmountText amountOf(WidgetTester tester, String label) => tester.widget(
    find.descendant(
      of: find.ancestor(of: findText(label), matching: find.byType(MergeSemantics)),
      matching: find.byType(AmountText),
    ),
  );

  testWidgetsBothThemes('shows balance, income and expenses', (tester, brightness) async {
    await pump(
      tester,
      const MonthTotals(income: Money(500000), expense: Money(120050)),
      brightness: brightness,
    );

    expect(findText(l10n.dashboardBalance), findsOneWidget);
    expect(findText(r'$3,799.50'), findsOneWidget);
    expect(findText(r'$5,000.00'), findsOneWidget);
    expect(findText(r'$1,200.50'), findsOneWidget);
    expect(amountOf(tester, l10n.commonIncome).type, AmountType.income);
    expect(amountOf(tester, l10n.commonExpense).type, AmountType.expense);
    expect(amountOf(tester, l10n.dashboardBalance).type, AmountType.neutral);
  });

  testWidgets('a negative balance shows in the expense color', (tester) async {
    await pump(tester, const MonthTotals(income: Money(1000), expense: Money(2500)));

    final balance = tester.widget<Text>(findText(r'-$15.00'));
    final colors = Theme.of(tester.element(findText(r'-$15.00'))).extension<AppColors>()!;
    expect(balance.style?.color, colors.expense);
  });

  testWidgets('each card is read as its label and amount', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const MonthTotals(income: Money(500000), expense: Money.zero));

    expect(
      find.bySemanticsLabel(RegExp('${l10n.commonIncome}.*5,000.00', dotAll: true)),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('large amounts fit a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: DashboardSummaryCards(
          totals: MonthTotals(income: Money(98765432100), expense: Money(12345678900)),
          currencyCode: 'USD',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
