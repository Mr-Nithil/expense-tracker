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
    expect(findText('Email'), findsOneWidget);
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
    expect(findText('Required'), findsOneWidget);
  });

  testWidgets('shows an explicit error text', (tester) async {
    await tester.pumpApp(const AppTextField(label: 'Amount', errorText: 'Too small'));
    expect(findText('Too small'), findsOneWidget);
  });

  testWidgets('shows a prefix text', (tester) async {
    await tester.pumpApp(const AppTextField(label: 'Amount', prefixText: r'$ '));
    await tester.enterText(find.byType(TextFormField), '12');
    await tester.pump();
    expect(findText(r'$ '), findsOneWidget);
  });

  testWidgets('the label sits above the field and is announced once, by the field', (
    tester,
  ) async {
    await tester.pumpApp(const AppTextField(label: 'Email'));

    final label = find.byWidgetPredicate(
      (w) => w is Text && w.data == null && w.textSpan?.toPlainText() == 'Email',
    );
    expect(label, findsOneWidget);
    expect(
      tester.getBottomLeft(label).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(InputDecorator)).dy),
    );
    expect(find.bySemanticsLabel('Email'), findsOneWidget);
  });

  testWidgets('validator and explicit errors show the error row with its icon', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpApp(
      Column(
        children: [
          Form(
            key: formKey,
            child: AppTextField(label: 'Name', validator: (v) => v!.isEmpty ? 'Required' : null),
          ),
          const AppTextField(label: 'Amount', errorText: 'Too small'),
        ],
      ),
    );
    formKey.currentState!.validate();
    await tester.pump();

    expect(find.byIcon(Icons.error_rounded), findsNWidgets(2));
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Too small'), findsOneWidget);
  });

  testWidgets('the border turns primary when focused', (tester) async {
    await tester.pumpApp(const AppTextField(label: 'Email'));
    final context = tester.element(find.byType(TextFormField));
    final decoration = tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;

    expect(
      (decoration.focusedBorder! as OutlineInputBorder).borderSide.color,
      Theme.of(context).colorScheme.primary,
    );
    expect((decoration.enabledBorder! as OutlineInputBorder).borderSide.width, 2);
  });
}
