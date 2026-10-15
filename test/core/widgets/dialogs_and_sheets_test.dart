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
      await tester.tap(findText('Open'));
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
      await tester.tap(findText('Open'));
      await tester.pumpAndSettle();
      expect(findText('Sure?'), findsOneWidget);
      await tester.tap(findText(l10n.commonConfirm));
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
      await tester.tap(findText('Open'));
      await tester.pumpAndSettle();
      await tester.tap(findText(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('destructive variant uses the danger button', (tester) async {
      await open(tester, isDestructive: true);
      final danger = tester.widget<FilledButton>(
        find.ancestor(of: findText(l10n.commonConfirm), matching: find.byType(FilledButton)),
      );
      final context = tester.element(findText('Delete?'));
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
      await tester.tap(findText('Open'));
      await tester.pumpAndSettle();
      expect(findText('Add item'), findsOneWidget);
      expect(findText('Sheet body'), findsOneWidget);

      // Sprout sheet: 28 px top corners and the 40x5 handle.
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      final theme = Theme.of(tester.element(find.text('Sheet body'))).bottomSheetTheme;
      expect(
        (theme.shape! as RoundedRectangleBorder).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(28)),
      );
      expect(theme.dragHandleSize, const Size(40, 5));
      expect(sheet.showDragHandle ?? theme.showDragHandle, isTrue);
    });
  });
}
