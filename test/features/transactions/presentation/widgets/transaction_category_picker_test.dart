import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_category_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);
  final food = Category(
    id: 'Food',
    name: 'Food',
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: false,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  Future<void> pumpPicker(
    WidgetTester tester, {
    String? selectedId,
    required Stream<List<Category>> Function() active,
    Stream<Category?> Function()? byId,
  }) async {
    await tester.pumpApp(
      TransactionCategoryPicker(
        type: TransactionType.expense,
        selectedId: selectedId,
        onChanged: (_) {},
      ),
      overrides: [
        categoriesProvider(CategoryType.expense).overrideWith((ref) => active()),
        if (byId != null) categoryByIdProvider('Old').overrideWith((ref) => byId()),
      ],
    );
    await tester.pump();
  }

  testWidgets('an archived selected category that is still loading never shows as unknown', (
    tester,
  ) async {
    final pending = StreamController<Category?>();
    addTearDown(pending.close);

    await pumpPicker(
      tester,
      selectedId: 'Old',
      active: () => Stream.value([food]),
      byId: () => pending.stream,
    );
    await tester.pump();

    expect(findText('Food'), findsOneWidget);
    expect(findText(l10n.categoryUnknown), findsNothing);
  });

  testWidgets('a load error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pumpPicker(
      tester,
      active: () {
        loads++;
        return Stream.error(const StorageFailure('db'));
      },
    );
    await tester.pumpAndSettle();
    expect(findText(l10n.errorStorage), findsOneWidget);
    final before = loads;

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(loads, greaterThan(before));
  });

  testWidgets('no categories of the type shows a hint', (tester) async {
    await pumpPicker(tester, active: () => Stream.value(const []));
    await tester.pumpAndSettle();

    expect(findText(l10n.transactionFormNoCategories), findsOneWidget);
  });
}
