import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/category_chip.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();

  CategoryChip food({bool archived = false, bool selected = false, VoidCallback? onTap}) =>
      CategoryChip(
        label: 'Food',
        iconKey: 'food',
        color: 0xFFEF6C00,
        isArchived: archived,
        selected: selected,
        onTap: onTap,
      );

  testWidgetsBothThemes('shows the icon and name', (tester, brightness) async {
    await tester.pumpApp(food(), brightness: brightness);

    expect(findText('Food'), findsOneWidget);
    expect(tester.widget<CategoryIcon>(find.byType(CategoryIcon)).iconKey, 'food');
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
  });

  testWidgetsBothThemes('an archived category is marked and announced', (tester, brightness) async {
    await tester.pumpApp(food(archived: true), brightness: brightness);

    expect(findText('Food'), findsOneWidget);
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.categoryChipArchived('Food')), findsOneWidget);
  });

  testWidgetsBothThemes('unknown shows the localized label and fallback icon', (
    tester,
    brightness,
  ) async {
    await tester.pumpApp(const CategoryChip.unknown(), brightness: brightness);

    expect(findText(l10n.categoryUnknown), findsOneWidget);
    expect(tester.widget<Icon>(find.byType(Icon)).icon, CategoryIcon.fallback);
  });

  testWidgets('a tappable chip calls back and announces its selection', (tester) async {
    var taps = 0;
    await tester.pumpApp(food(selected: true, onTap: () => taps++));

    await tester.tap(find.byType(CategoryChip));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(CategoryChip)),
      isSemantics(label: 'Food', isButton: true, isSelected: true, hasTapAction: true),
    );
  });

  testWidgets('a display-only chip has no tap action', (tester) async {
    await tester.pumpApp(food());

    expect(
      tester.getSemantics(find.byType(CategoryChip)),
      isSemantics(label: 'Food', hasTapAction: false, isButton: false),
    );
  });
}
