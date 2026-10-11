import 'dart:async';

import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/presentation/shared/budget_progress_tile.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);
  final food = Category(
    id: 'food',
    name: 'Food',
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: true,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );
  final progress = BudgetProgress(
    budget: Budget(
      id: 'b1',
      month: DateTime(2026, 10),
      categoryId: 'food',
      limit: const Money(20000),
      createdAt: at,
      updatedAt: at,
    ),
    spent: const Money(5000),
  );

  Future<void> pumpTile(WidgetTester tester, Stream<Category?> category) async {
    await tester.pumpApp(
      BudgetProgressTile(progress: progress, currencyCode: 'USD'),
      overrides: [categoryByIdProvider('food').overrideWith((ref) => category)],
    );
    await tester.pump();
  }

  testWidgetsBothThemes('shows the category and its progress', (tester, brightness) async {
    await tester.pumpApp(
      BudgetProgressTile(progress: progress, currencyCode: 'USD'),
      brightness: brightness,
      overrides: [categoryByIdProvider('food').overrideWith((ref) => Stream.value(food))],
    );
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.byType(CategoryIcon), findsOneWidget);
    expect(find.text(l10n.budgetSpentOfLimit(r'$50.00', r'$200.00')), findsOneWidget);
    expect(find.text(l10n.budgetRemaining(r'$150.00')), findsOneWidget);
  });

  testWidgets('fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      BudgetProgressTile(progress: progress, currencyCode: 'USD', onTap: () => taps++),
      overrides: [categoryByIdProvider('food').overrideWith((ref) => Stream.value(food))],
    );
    await tester.pump();

    await tester.tap(find.text('Food'));

    expect(taps, 1);
  });

  testWidgets('marks an archived category', (tester) async {
    await pumpTile(tester, Stream.value(food.copyWith(isArchived: true)));

    expect(find.text(l10n.categoryChipArchived('Food')), findsOneWidget);
  });

  testWidgets('a category not on this device shows as unknown', (tester) async {
    await pumpTile(tester, Stream.value(null));

    expect(find.text(l10n.categoryUnknown), findsOneWidget);
  });

  testWidgets('shows no name while the category loads', (tester) async {
    final controller = StreamController<Category?>();
    addTearDown(controller.close);
    await pumpTile(tester, controller.stream);

    expect(find.text(l10n.categoryUnknown), findsNothing);
    expect(find.text(l10n.budgetRemaining(r'$150.00')), findsOneWidget);
  });
}
