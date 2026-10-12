import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 10);

  Category category(String name, CategoryType type) => Category(
    id: name,
    name: name,
    icon: 'food',
    color: 0xFFEF6C00,
    type: type,
    isDefault: true,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  Override listOf(CategoryType type, Stream<List<Category>> Function() stream) =>
      categoriesProvider(type).overrideWith((ref) => stream());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    List<Category> expense = const [],
    List<Category> income = const [],
  }) async {
    await tester.pumpApp(
      const CategoriesScreen(),
      brightness: brightness,
      overrides: [
        listOf(CategoryType.expense, () => Stream.value(expense)),
        listOf(CategoryType.income, () => Stream.value(income)),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows the expense tab first', (tester, brightness) async {
    await pumpScreen(
      tester,
      brightness: brightness,
      expense: [category('Food', CategoryType.expense), category('Bills', CategoryType.expense)],
    );

    expect(find.text(l10n.categoriesTitle), findsOneWidget);
    expect(find.text(l10n.commonExpense), findsOneWidget);
    expect(find.text(l10n.commonIncome), findsOneWidget);
    expect(find.byType(CategoryTile), findsNWidgets(2));
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('switching tabs shows the income categories', (tester) async {
    await pumpScreen(
      tester,
      expense: [category('Food', CategoryType.expense)],
      income: [category('Salary', CategoryType.income)],
    );

    await tester.tap(find.text(l10n.commonIncome));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('an empty type shows the empty state', (tester) async {
    await pumpScreen(tester);

    expect(find.text(l10n.categoriesEmptyTitle), findsOneWidget);
  });

  testWidgets('an error shows a retry that reloads', (tester) async {
    var loads = 0;
    await tester.pumpApp(
      const CategoriesScreen(),
      overrides: [
        listOf(CategoryType.expense, () {
          loads++;
          return Stream.error(const StorageFailure('db'));
        }),
        listOf(CategoryType.income, () => Stream.value(const [])),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorStorage), findsOneWidget);
    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(loads, greaterThan(1));
  });

  testWidgets('the add button opens a new-category sheet for the current tab', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text(l10n.commonIncome));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.categoriesAdd));
    await tester.pumpAndSettle();

    expect(find.text(l10n.categoryFormNewTitle), findsOneWidget);
    final sheet = tester.widget<CategoryFormSheet>(find.byType(CategoryFormSheet));
    expect(sheet.initialType, CategoryType.income);
    expect(sheet.category, isNull);
  });

  testWidgets('tapping a category opens it for editing', (tester) async {
    await pumpScreen(tester, expense: [category('Food', CategoryType.expense)]);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.categoryFormEditTitle), findsOneWidget);
    expect(tester.widget<CategoryFormSheet>(find.byType(CategoryFormSheet)).category?.name, 'Food');
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpScreen(
        tester,
        expense: [category('Food', CategoryType.expense)],
        brightness: brightness,
      );
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpScreen(tester, expense: [category('Food', CategoryType.expense)]);
      await scrollThrough(tester);
    });
  });
}
