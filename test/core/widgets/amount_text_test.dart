import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/amount_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Text textOf(WidgetTester tester) => tester.widget<Text>(find.byType(Text));

  testWidgetsBothThemes('income is green and signed', (tester, brightness) async {
    await tester.pumpApp(
      const AmountText(Money(1250), currencyCode: 'USD', type: AmountType.income, showSign: true),
      brightness: brightness,
    );
    final colors = brightness == Brightness.light ? AppColors.light : AppColors.dark;
    expect(textOf(tester).data, r'+$12.50');
    expect(textOf(tester).style?.color, colors.income);
  });

  testWidgets('expense is red and signed negative', (tester) async {
    await tester.pumpApp(
      const AmountText(Money(1250), currencyCode: 'USD', type: AmountType.expense, showSign: true),
    );
    expect(textOf(tester).data, r'-$12.50');
    expect(textOf(tester).style?.color, AppColors.light.expense);
  });

  testWidgets('neutral is uncolored unless negative', (tester) async {
    await tester.pumpApp(const AmountText(Money(500), currencyCode: 'USD'));
    expect(textOf(tester).data, r'$5.00');
    expect(textOf(tester).style?.color, isNot(AppColors.light.expense));

    await tester.pumpApp(const AmountText(Money(-500), currencyCode: 'USD'));
    expect(textOf(tester).data, r'-$5.00');
    expect(textOf(tester).style?.color, AppColors.light.expense);
  });
}
