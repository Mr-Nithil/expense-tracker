import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 10);

  Category food({bool archived = false}) => Category(
    id: 'food',
    name: 'Food',
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: true,
    sortOrder: 0,
    isArchived: archived,
    createdAt: at,
    updatedAt: at,
  );

  testWidgets('an active category shows its icon and name only', (tester) async {
    await tester.pumpApp(CategoryTile(category: food()));

    expect(find.text('Food'), findsOneWidget);
    expect(find.text(l10n.categoryArchivedLabel), findsNothing);
    expect(tester.widget<CategoryIcon>(find.byType(CategoryIcon)).iconKey, 'food');
  });

  testWidgetsBothThemes('an archived category is labelled', (tester, brightness) async {
    await tester.pumpApp(CategoryTile(category: food(archived: true)), brightness: brightness);

    expect(find.text('Food'), findsOneWidget);
    expect(find.text(l10n.categoryArchivedLabel), findsOneWidget);
  });

  testWidgetsBothThemes('a missing category shows as unknown', (tester, brightness) async {
    await tester.pumpApp(const CategoryTile(category: null), brightness: brightness);

    expect(find.text(l10n.categoryUnknown), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byType(Icon)).icon,
      CategoryIcon.fallback,
    );
  });
}
