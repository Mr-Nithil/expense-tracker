import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/data/budget_repository_provider.dart';
import 'package:expense_tracker/features/budget/domain/budget_repository.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';
import 'package:expense_tracker/features/budget/presentation/widgets/budget_form_sheet.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final october = DateTime(2026, 10);
  final at = DateTime.utc(2026, 10, 1);

  Category category(String id) => Category(
    id: id,
    name: id,
    icon: 'food',
    color: 0xFFEF6C00,
    type: CategoryType.expense,
    isDefault: false,
    sortOrder: 0,
    isArchived: false,
    createdAt: at,
    updatedAt: at,
  );

  Budget budget({String? categoryId, int limit = 20000}) => Budget(
    id: categoryId ?? 'overall',
    month: october,
    categoryId: categoryId,
    limit: Money(limit),
    createdAt: at,
    updatedAt: at,
  );

  BudgetProgress progress(Budget budget) => BudgetProgress(budget: budget, spent: Money.zero);

  late _MockBudgetRepository repository;

  setUpAll(() => registerFallbackValue(Money.zero));

  setUp(() {
    repository = _MockBudgetRepository();
    when(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Result.success(budget()));
  });

  Future<void> open(
    WidgetTester tester,
    void Function(BuildContext context) show, {
    Brightness brightness = Brightness.light,
    List<Category>? categories,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(onPressed: () => show(context), child: const Text('open')),
      ),
      brightness: brightness,
      overrides: [
        budgetRepositoryProvider.overrideWithValue(repository),
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
        categoriesProvider(CategoryType.expense).overrideWith(
          (ref) => Stream.value(categories ?? [category('Food'), category('Bills')]),
        ),
        categoryByIdProvider('Food').overrideWith((ref) => Stream.value(category('Food'))),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> openAdd(
    WidgetTester tester, {
    BudgetOverview overview = const BudgetOverview(),
    Brightness brightness = Brightness.light,
    List<Category>? categories,
  }) => open(
    tester,
    (context) => BudgetFormSheet.showAdd(context, month: october, overview: overview),
    brightness: brightness,
    categories: categories,
  );

  Finder limitField() => find.widgetWithText(TextFormField, l10n.budgetFormLimitLabel);
  Finder sheet() => find.byType(BudgetFormSheet);

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) => tapVisible(tester, find.text(l10n.commonSave));

  testWidgetsBothThemes('a month without budgets starts with the overall budget', (
    tester,
    brightness,
  ) async {
    await openAdd(tester, brightness: brightness);

    expect(find.text(l10n.budgetFormNewTitle), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text(l10n.budgetFormOverallHint), findsOneWidget);
    expect(find.text('Food'), findsNothing);
  });

  testWidgets('saves the overall budget and closes', (tester) async {
    await openAdd(tester);

    await tester.enterText(limitField(), '500');
    await save(tester);

    verify(() => repository.set(month: october, limit: const Money(50000))).called(1);
    expect(sheet(), findsNothing);
  });

  testWidgets('saves a category budget', (tester) async {
    await openAdd(tester);

    await tapVisible(tester, find.text(l10n.budgetFormCategory));
    await tapVisible(tester, find.text('Bills'));
    await tester.enterText(limitField(), '120.50');
    await save(tester);

    verify(
      () => repository.set(month: october, categoryId: 'Bills', limit: const Money(12050)),
    ).called(1);
    expect(sheet(), findsNothing);
  });

  testWidgets('a category budget needs a category', (tester) async {
    await openAdd(tester);

    await tapVisible(tester, find.text(l10n.budgetFormCategory));
    await tester.enterText(limitField(), '100');
    await save(tester);

    expect(find.text(l10n.errorBudgetCategoryRequired), findsOneWidget);
    verifyNever(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    );
  });

  testWidgets('an empty limit is rejected by the field', (tester) async {
    await openAdd(tester);

    await save(tester);

    expect(find.text(l10n.errorFieldRequired), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });

  testWidgets('with an overall budget set, only categories without a budget are offered', (
    tester,
  ) async {
    await openAdd(
      tester,
      overview: BudgetOverview(
        overall: progress(budget()),
        categories: [progress(budget(categoryId: 'Food'))],
      ),
    );

    expect(find.text(l10n.budgetFormOverall), findsNothing);
    expect(find.text('Food'), findsNothing);
    expect(find.text('Bills'), findsOneWidget);
  });

  testWidgets('says so when every category has a budget', (tester) async {
    await openAdd(
      tester,
      overview: BudgetOverview(
        overall: progress(budget()),
        categories: [progress(budget(categoryId: 'Food'))],
      ),
      categories: [category('Food')],
    );

    expect(find.text(l10n.budgetFormNoCategoriesLeft), findsOneWidget);
  });

  testWidgets('shows the repository\'s reason next to the category', (tester) async {
    when(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(
          BudgetValidator.categoryArchived,
          field: BudgetValidator.categoryField,
        ),
      ),
    );
    await openAdd(tester);

    await tapVisible(tester, find.text(l10n.budgetFormCategory));
    await tapVisible(tester, find.text('Food'));
    await tester.enterText(limitField(), '100');
    await save(tester);

    expect(find.text(l10n.errorBudgetCategoryArchived), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });

  testWidgets('a month out of range is explained', (tester) async {
    when(
      () => repository.set(
        month: any(named: 'month'),
        categoryId: any(named: 'categoryId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(BudgetValidator.monthOutOfRange, field: BudgetValidator.monthField),
      ),
    );
    await openAdd(tester);

    await tester.enterText(limitField(), '100');
    await save(tester);

    expect(
      find.text(l10n.errorBudgetMonthOutOfRange(BudgetValidator.maxMonthsAhead)),
      findsOneWidget,
    );
  });

  group('edit', () {
    testWidgets('a category budget shows its category and limit, and saves the new limit', (
      tester,
    ) async {
      await open(
        tester,
        (context) => BudgetFormSheet.showEdit(context, budget(categoryId: 'Food')),
      );

      expect(find.text(l10n.budgetFormEditTitle), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Bills'), findsNothing);
      expect(find.text('200.00'), findsOneWidget);

      await tester.enterText(limitField(), '250');
      await save(tester);

      verify(
        () => repository.set(month: october, categoryId: 'Food', limit: const Money(25000)),
      ).called(1);
      expect(sheet(), findsNothing);
    });

    testWidgets('the overall budget offers no switch to a category', (tester) async {
      await open(tester, (context) => BudgetFormSheet.showEdit(context, budget()));

      expect(find.text(l10n.budgetOverallTitle), findsOneWidget);
      expect(find.text(l10n.budgetFormCategory), findsNothing);
    });

    testWidgets('remove asks first, then deletes and closes', (tester) async {
      when(() => repository.delete('Food')).thenAnswer((_) async => Result.ok);
      await open(
        tester,
        (context) => BudgetFormSheet.showEdit(context, budget(categoryId: 'Food')),
      );

      await tapVisible(tester, find.text(l10n.budgetFormRemove));
      expect(find.text(l10n.budgetRemoveConfirmTitle), findsOneWidget);
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      verifyNever(() => repository.delete(any()));

      await tapVisible(tester, find.text(l10n.budgetFormRemove));
      await tester.tap(find.widgetWithText(FilledButton, l10n.budgetFormRemove));
      await tester.pumpAndSettle();

      verify(() => repository.delete('Food')).called(1);
      expect(sheet(), findsNothing);
    });

    testWidgets('a failed remove keeps the sheet open with the error', (tester) async {
      when(
        () => repository.delete('Food'),
      ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
      await open(
        tester,
        (context) => BudgetFormSheet.showEdit(context, budget(categoryId: 'Food')),
      );

      await tapVisible(tester, find.text(l10n.budgetFormRemove));
      await tester.tap(find.widgetWithText(FilledButton, l10n.budgetFormRemove));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorStorage), findsOneWidget);
      expect(sheet(), findsOneWidget);
    });
  });
}
