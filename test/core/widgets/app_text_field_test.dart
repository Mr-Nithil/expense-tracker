import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgetsBothThemes('shows label and hint and reports changes', (tester, brightness) async {
    String? changed;
    await tester.pumpApp(
      AppTextField(label: 'Email', hint: 'you@example.com', onChanged: (v) => changed = v),
      brightness: brightness,
    );
    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'a@b.c');
    expect(changed, 'a@b.c');
  });

  testWidgets('runs the validator inside a Form', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpApp(
      Form(
        key: formKey,
        child: AppTextField(label: 'Name', validator: (v) => v!.isEmpty ? 'Required' : null),
      ),
    );
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('shows an explicit error text', (tester) async {
    await tester.pumpApp(const AppTextField(label: 'Amount', errorText: 'Too small'));
    expect(find.text('Too small'), findsOneWidget);
  });

  testWidgets('shows a prefix text', (tester) async {
    await tester.pumpApp(const AppTextField(label: 'Amount', prefixText: r'$ '));
    await tester.enterText(find.byType(TextFormField), '12');
    await tester.pump();
    expect(find.text(r'$ '), findsOneWidget);
  });
}
