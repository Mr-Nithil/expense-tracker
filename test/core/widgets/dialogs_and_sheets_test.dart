import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/app_bottom_sheet.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('ConfirmDialog', () {
    Future<bool?> open(WidgetTester tester, {bool isDestructive = false}) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await ConfirmDialog.show(
              context,
              title: 'Delete?',
              message: 'This cannot be undone',
              isDestructive: isDestructive,
            ),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns true on confirm', (tester) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await ConfirmDialog.show(context, title: 'Sure?', message: 'Really'),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sure?'), findsOneWidget);
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('returns false on cancel', (tester) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await ConfirmDialog.show(context, title: 'Sure?', message: 'Really'),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('destructive variant uses the danger button', (tester) async {
      await open(tester, isDestructive: true);
      final danger = tester.widget<FilledButton>(
        find.ancestor(of: find.text(l10n.commonConfirm), matching: find.byType(FilledButton)),
      );
      final context = tester.element(find.text('Delete?'));
      expect(danger.style?.backgroundColor?.resolve({}), Theme.of(context).colorScheme.error);
      expect(find.byType(AppButton), findsNWidgets(2));
    });
  });

  group('AppBottomSheet', () {
    testWidgetsBothThemes('shows title and content', (tester, brightness) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppBottomSheet.show<void>(
              context,
              title: 'Add item',
              child: const Text('Sheet body'),
            ),
            child: const Text('Open'),
          ),
        ),
        brightness: brightness,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Add item'), findsOneWidget);
      expect(find.text('Sheet body'), findsOneWidget);
    });
  });
}
