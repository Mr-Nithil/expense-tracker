import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);

  Category category({bool archived = false}) => Category(
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

  Transaction tx({
    TransactionType type = TransactionType.expense,
    int amount = 1250,
    String? note,
  }) => Transaction(
    id: 't1',
    type: type,
    amount: Money(amount),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, 9),
    note: note,
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  Future<void> pumpTile(
    WidgetTester tester,
    Transaction transaction, {
    Category? category,
    Brightness brightness = Brightness.light,
    VoidCallback? onTap,
  }) async {
    await tester.pumpApp(
      TransactionTile(transaction: transaction, currencyCode: 'USD', onTap: onTap),
      brightness: brightness,
      overrides: [categoryByIdProvider('food').overrideWith((ref) => Stream.value(category))],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('shows category, note and a signed expense', (tester, brightness) async {
    await pumpTile(
      tester,
      tx(note: 'Team lunch'),
      category: category(),
      brightness: brightness,
    );

    expect(findText('Food'), findsOneWidget);
    expect(findText('Team lunch'), findsOneWidget);
    expect(findText(r'-$12.50'), findsOneWidget);
  });

  testWidgets('an income is signed positive', (tester) async {
    await pumpTile(tester, tx(type: TransactionType.income, amount: 85000), category: category());
    expect(findText(r'+$850.00'), findsOneWidget);
  });

  testWidgets('an archived category is marked', (tester) async {
    await pumpTile(tester, tx(), category: category(archived: true));
    expect(findText(l10n.categoryChipArchived('Food')), findsOneWidget);
  });

  testWidgets('a missing category shows as unknown', (tester) async {
    await pumpTile(tester, tx());
    expect(findText(l10n.categoryUnknown), findsOneWidget);
  });

  testWidgets('tapping calls back', (tester) async {
    var taps = 0;
    await pumpTile(tester, tx(), category: category(), onTap: () => taps++);
    await tester.tap(find.byType(TransactionTile));
    expect(taps, 1);
  });
}
