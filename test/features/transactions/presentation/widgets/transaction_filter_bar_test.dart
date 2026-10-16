import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/widgets/category_chip.dart';
import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11);
  final at = DateTime.utc(2026, 10, 1);

  Category category(String id, CategoryType type) => Category(
    id: id,
    name: id,
    icon: 'food',
    color: 0xFFEF6C00,
    type: type,
    isDefault: false,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  final food = category('Food', CategoryType.expense);
  final salary = category('Salary', CategoryType.income);

  late TransactionFilter Function() filter;

  late TransactionFilterController Function() controller;

  Future<void> pumpBar(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Stream<List<Category>> Function()? expense,
    Stream<Category?> Function()? foodById,
  }) async {
    await tester.pumpApp(
      Consumer(
        builder: (context, ref, _) {
          filter = () => ref.read(transactionFilterControllerProvider);
          controller = () => ref.read(transactionFilterControllerProvider.notifier);
          return const TransactionFilterBar();
        },
      ),
      brightness: brightness,
      overrides: [
        clockProvider.overrideWithValue(FixedClock(now)),
        categoriesProvider(
          CategoryType.expense,
        ).overrideWith((ref) => (expense ?? () => Stream.value([food]))()),
        categoriesProvider(CategoryType.income).overrideWith((ref) => Stream.value([salary])),
        categoryByIdProvider(
          'Food',
        ).overrideWith((ref) => (foodById ?? () => Stream.value(food))()),
      ],
    );
    await tester.pumpAndSettle();
  }

  /// A stream that never emits: the provider stays loading.
  Stream<T> pending<T>() {
    final controller = StreamController<T>();
    addTearDown(controller.close);
    return controller.stream;
  }

  testWidgetsBothThemes('shows the month, the type options and the category filter', (
    tester,
    brightness,
  ) async {
    await pumpBar(tester, brightness: brightness);

    expect(findText('October 2026'), findsOneWidget);
    expect(findText(l10n.commonAll), findsOneWidget);
    expect(findText(l10n.transactionsFilterAllCategories), findsOneWidget);
  });

  testWidgets('the arrows change the month', (tester) async {
    await pumpBar(tester);

    await tester.tap(find.byTooltip(l10n.commonPreviousMonth));
    await tester.pumpAndSettle();

    expect(findText('September 2026'), findsOneWidget);
    expect(filter().month, DateTime(2026, 9));
  });

  testWidgets('the segments set the type', (tester) async {
    await pumpBar(tester);

    await tester.tap(findText(l10n.commonIncome));
    await tester.pumpAndSettle();
    expect(filter().type, TransactionType.income);

    await tester.tap(findText(l10n.commonAll));
    await tester.pumpAndSettle();
    expect(filter().type, isNull);
  });

  testWidgets('picking a category sets it, and the clear button removes it', (tester) async {
    await pumpBar(tester);

    await tester.tap(findText(l10n.transactionsFilterAllCategories));
    await tester.pumpAndSettle();
    expect(findText(l10n.transactionsFilterCategoryTitle), findsOneWidget);
    expect(findText('Salary'), findsOneWidget);
    await tester.tap(findText('Food'));
    await tester.pumpAndSettle();

    expect(filter().categoryId, 'Food');
    expect(find.byType(CategoryChip), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.transactionsFilterClearCategory));
    await tester.pumpAndSettle();
    expect(filter().categoryId, isNull);
    expect(findText(l10n.transactionsFilterAllCategories), findsOneWidget);
  });

  testWidgets('tapping the selected category reopens the picker', (tester) async {
    await pumpBar(tester);
    controller().setCategory('Food');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CategoryChip));
    await tester.pumpAndSettle();

    expect(findText(l10n.transactionsFilterCategoryTitle), findsOneWidget);
  });

  testWidgets('with a type chosen, only its categories are offered', (tester) async {
    await pumpBar(tester);
    await tester.tap(findText(l10n.commonIncome));
    await tester.pumpAndSettle();

    await tester.tap(findText(l10n.transactionsFilterAllCategories));
    await tester.pumpAndSettle();

    expect(findText('Salary'), findsOneWidget);
    expect(findText('Food'), findsNothing);
  });

  group('loading and errors', () {
    testWidgets('the category sheet shows a spinner while loading, not "no categories"', (
      tester,
    ) async {
      await pumpBar(tester, expense: pending);

      await tester.tap(findText(l10n.transactionsFilterAllCategories));
      await tester.pump();

      expect(find.byType(SproutLoader), findsOneWidget);
      expect(findText(l10n.categoriesEmptyTitle), findsNothing);
    });

    testWidgets('a category load error offers a retry that reloads', (tester) async {
      var loads = 0;
      await pumpBar(
        tester,
        expense: () {
          loads++;
          return Stream.error(const StorageFailure('db'));
        },
      );

      await tester.tap(findText(l10n.transactionsFilterAllCategories));
      await tester.pumpAndSettle();
      expect(findText(l10n.errorStorage), findsOneWidget);
      final before = loads;

      await tester.tap(findText(l10n.commonRetry));
      await tester.pumpAndSettle();
      expect(loads, greaterThan(before));
    });

    testWidgets('a selected category that is still loading never shows as unknown', (
      tester,
    ) async {
      await pumpBar(tester, foodById: pending);

      controller().setCategory('Food');
      await tester.pump();

      expect(findText(l10n.categoryUnknown), findsNothing);
      expect(find.byTooltip(l10n.transactionsFilterClearCategory), findsOneWidget);
    });
  });
}
