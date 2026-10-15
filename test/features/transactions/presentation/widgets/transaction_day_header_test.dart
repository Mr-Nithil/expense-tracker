import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_grouping.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_day_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final today = DateTime(2026, 10, 11, 8);

  TransactionDay day(DateTime date, {int income = 0, int expense = 0}) => TransactionDay(
    date: date,
    transactions: const [],
    income: Money(income),
    expense: Money(expense),
  );

  Future<void> pumpHeader(WidgetTester tester, TransactionDay d, {Brightness? brightness}) =>
      tester.pumpApp(
        TransactionDayHeader(day: d, today: today, currencyCode: 'USD'),
        brightness: brightness ?? Brightness.light,
      );

  testWidgetsBothThemes('labels today and shows the net', (tester, brightness) async {
    await pumpHeader(
      tester,
      day(DateTime(2026, 10, 11), income: 85000, expense: 1250),
      brightness: brightness,
    );

    expect(findText(l10n.commonToday), findsOneWidget);
    expect(findText(r'$837.50'), findsOneWidget);
  });

  testWidgets('labels yesterday, then weekday dates', (tester) async {
    await pumpHeader(tester, day(DateTime(2026, 10, 10)));
    expect(findText(l10n.commonYesterday), findsOneWidget);

    await pumpHeader(tester, day(DateTime(2026, 10, 9)));
    expect(findText('Fri, Oct 9'), findsOneWidget);
  });

  testWidgets('a negative day uses the expense color', (tester) async {
    await pumpHeader(tester, day(DateTime(2026, 10, 9), expense: 1250));

    final text = tester.widget<Text>(findText(r'-$12.50'));
    expect(text.style?.color, AppColors.light.expense);
  });
}
