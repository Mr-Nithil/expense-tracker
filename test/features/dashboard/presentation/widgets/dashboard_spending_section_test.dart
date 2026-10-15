import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/progress_bar.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_spending_section.dart';
import 'package:expense_tracker/features/transactions/domain/entities/category_spending.dart';
import 'package:expense_tracker/features/transactions/domain/entities/spending_breakdown.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final october = DateTime(2026, 10);
  final at = DateTime.utc(2026, 10, 1);

  Category category(String id, {bool archived = false}) => Category(
    id: id,
    name: id,
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: false,
    sortOrder: 0,
    isArchived: archived,
    createdAt: at,
    updatedAt: at,
  );

  CategorySpending spent(String id, int minor) =>
      CategorySpending(categoryId: id, amount: Money(minor));

  List<Override> categoryOverrides(List<String> ids) => [
    for (final id in ids)
      categoryByIdProvider(id).overrideWith((ref) => Stream.value(category(id))),
  ];

  Future<void> pump(
    WidgetTester tester,
    Stream<SpendingBreakdown> Function() breakdown, {
    List<Override> extra = const [],
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpApp(
      SingleChildScrollView(
        child: DashboardSpendingSection(month: october, currencyCode: 'USD'),
      ),
      brightness: brightness,
      overrides: [spendingBreakdownProvider(october).overrideWith((ref) => breakdown()), ...extra],
    );
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('lists categories largest first with amount, share and a bar', (
    tester,
    brightness,
  ) async {
    await pump(
      tester,
      () => Stream.value(
        SpendingBreakdown.of([spent('Food', 42000), spent('Rent', 58000)].reversed.toList()),
      ),
      extra: categoryOverrides(['Food', 'Rent']),
      brightness: brightness,
    );

    expect(findText(l10n.dashboardSpendingTitle), findsOneWidget);
    expect(findText('Rent'), findsOneWidget);
    expect(findText(r'$580.00'), findsOneWidget);
    expect(findText(l10n.dashboardSpendingPercent(58)), findsOneWidget);
    expect(findText(l10n.dashboardSpendingPercent(42)), findsOneWidget);
    expect(
      tester.getTopLeft(findText('Rent')).dy,
      lessThan(tester.getTopLeft(findText('Food')).dy),
    );
    final bars = tester.widgetList<ProgressBar>(find.byType(ProgressBar)).toList();
    expect(bars.map((b) => b.value), [0.58, 0.42]);
    expect(bars.every((b) => b.level == ProgressLevel.normal), isTrue);
  });

  testWidgets('folded categories are counted, not called "Other"', (tester) async {
    final ids = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
    await pump(
      tester,
      () => Stream.value(
        SpendingBreakdown.of([for (var i = 0; i < ids.length; i++) spent(ids[i], 7000 - i * 1000)]),
      ),
      extra: categoryOverrides(ids),
    );

    expect(findText(l10n.dashboardSpendingOther(2)), findsOneWidget);
    expect(findText('f'), findsNothing);
  });

  testWidgets('a share that rounds to 0 shows "<1%"', (tester) async {
    await pump(
      tester,
      () => Stream.value(SpendingBreakdown.of([spent('Food', 100000), spent('Rent', 1)])),
      extra: categoryOverrides(['Food', 'Rent']),
    );

    expect(findText(l10n.dashboardSpendingPercentTiny), findsOneWidget);
  });

  testWidgets('marks archived categories and unknown ones', (tester) async {
    await pump(
      tester,
      () => Stream.value(SpendingBreakdown.of([spent('Old', 200), spent('Gone', 100)])),
      extra: [
        categoryByIdProvider(
          'Old',
        ).overrideWith((ref) => Stream.value(category('Old', archived: true))),
        categoryByIdProvider('Gone').overrideWith((ref) => Stream.value(null)),
      ],
    );

    expect(findText(l10n.categoryChipArchived('Old')), findsOneWidget);
    expect(findText(l10n.categoryUnknown), findsOneWidget);
  });

  testWidgets('a month without expenses says so', (tester) async {
    await pump(tester, () => Stream.value(SpendingBreakdown.empty));

    expect(findText(l10n.dashboardSpendingEmpty('October 2026')), findsOneWidget);
    expect(find.byType(ProgressBar), findsNothing);
  });

  testWidgets('an error offers a retry that reloads', (tester) async {
    var loads = 0;
    await pump(tester, () {
      loads++;
      return loads == 1
          ? Stream.error(const StorageFailure('db'))
          : Stream.value(SpendingBreakdown.of([spent('Food', 100)]));
    }, extra: categoryOverrides(['Food']));
    expect(findText(l10n.errorStorage), findsOneWidget);

    await tester.tap(findText(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(findText('Food'), findsOneWidget);
  });

  testWidgets('each row is read as name, amount and share; the bar is not read twice', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      () => Stream.value(SpendingBreakdown.of([spent('Food', 100)])),
      extra: categoryOverrides(['Food']),
    );

    expect(find.bySemanticsLabel(RegExp(r'Food.*\$1\.00.*100%', dotAll: true)), findsOneWidget);
    handle.dispose();
  });

  testWidgets('shows no name while a category loads', (tester) async {
    final pending = StreamController<Category?>();
    addTearDown(pending.close);
    await tester.pumpApp(
      SingleChildScrollView(
        child: DashboardSpendingSection(month: october, currencyCode: 'USD'),
      ),
      overrides: [
        spendingBreakdownProvider(october).overrideWith(
          (ref) => Stream.value(SpendingBreakdown.of([spent('Food', 100)])),
        ),
        categoryByIdProvider('Food').overrideWith((ref) => pending.stream),
      ],
    );
    await tester.pump();
    await tester.pump();

    expect(findText(l10n.categoryUnknown), findsNothing);
    expect(findText(r'$1.00'), findsOneWidget);
  });

  testWidgets('fits a small phone at 1.5x text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: SingleChildScrollView(
          child: DashboardSpendingSection(month: october, currencyCode: 'USD'),
        ),
      ),
      overrides: [
        spendingBreakdownProvider(october).overrideWith(
          (ref) => Stream.value(
            SpendingBreakdown.of([spent('Entertainment and subscriptions', 98765432100)]),
          ),
        ),
        ...categoryOverrides(['Entertainment and subscriptions']),
      ],
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
