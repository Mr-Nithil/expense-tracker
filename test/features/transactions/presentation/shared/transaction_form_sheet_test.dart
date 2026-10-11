import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/category_chip.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 11, 9, 30);
  final at = DateTime.utc(2026, 10, 1);

  Category category(String id, CategoryType type, {bool archived = false}) => Category(
    id: id,
    name: id,
    icon: 'food',
    color: 0xFFEF6C00,
    type: type,
    isDefault: false,
    sortOrder: 0,
    isArchived: archived,
    createdAt: at,
    updatedAt: at,
  );

  final food = category('Food', CategoryType.expense);
  final bills = category('Bills', CategoryType.expense);
  final salary = category('Salary', CategoryType.income);
  final oldCategory = category('Old', CategoryType.expense, archived: true);

  final lunch = Transaction(
    id: 't1',
    type: TransactionType.expense,
    amount: const Money(1200),
    categoryId: 'Food',
    occurredOn: DateTime(2026, 10, 3),
    note: 'Lunch',
    isDeleted: false,
    createdAt: at,
    updatedAt: at,
  );

  late _MockTransactionRepository repository;

  setUpAll(() {
    registerFallbackValue(
      TransactionDraft(
        type: TransactionType.expense,
        amount: Money.zero,
        categoryId: 'x',
        occurredOn: DateTime(2026),
      ),
    );
    registerFallbackValue(lunch);
  });

  setUp(() => repository = _MockTransactionRepository());

  Future<void> openSheet(
    WidgetTester tester, {
    Transaction? transaction,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => TransactionFormSheet.show(context, transaction: transaction),
          child: const Text('open'),
        ),
      ),
      brightness: brightness,
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(now)),
        currencyCodeProvider.overrideWith((ref) async => 'USD'),
        categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food, bills])),
        categoriesProvider(CategoryType.income).overrideWith((ref) => Stream.value([salary])),
        categoryByIdProvider('Old').overrideWith((ref) => Stream.value(oldCategory)),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder amountField() => find.widgetWithText(TextFormField, l10n.transactionFormAmountLabel);
  Finder noteField() => find.widgetWithText(TextFormField, l10n.transactionFormNoteLabel);
  Finder sheet() => find.byType(TransactionFormSheet);
  CategoryChip chip(WidgetTester tester, String name) => tester.widget(
    find.ancestor(of: find.text(name), matching: find.byType(CategoryChip)),
  );

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) => tapVisible(tester, find.text(l10n.commonSave));

  testWidgetsBothThemes('renders a new expense dated today', (tester, brightness) async {
    await openSheet(tester, brightness: brightness);

    expect(find.text(l10n.transactionFormNewTitle), findsOneWidget);
    expect(amountField(), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Oct 11, 2026'), findsOneWidget);
  });

  testWidgets('saves a new expense and closes', (tester) async {
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(lunch));
    await openSheet(tester);

    await tester.enterText(amountField(), '12.50');
    await tapVisible(tester, find.text('Food'));
    await tester.enterText(noteField(), 'Team lunch');
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as TransactionDraft;
    expect(draft.type, TransactionType.expense);
    expect(draft.amount, const Money(1250));
    expect(draft.categoryId, 'Food');
    expect(draft.occurredOn, DateTime(2026, 10, 11));
    expect(draft.note, 'Team lunch');
    expect(sheet(), findsNothing);
  });

  testWidgets('an empty form requires an amount and a category', (tester) async {
    await openSheet(tester);

    await save(tester);

    expect(find.text(l10n.errorFieldRequired), findsOneWidget);
    expect(find.text(l10n.errorTransactionCategoryRequired), findsOneWidget);
    verifyNever(() => repository.create(any()));
  });

  testWidgets('switching to income shows income categories and clears the choice', (
    tester,
  ) async {
    await openSheet(tester);
    await tapVisible(tester, find.text('Food'));
    expect(chip(tester, 'Food').selected, isTrue);

    await tester.tap(find.text(l10n.commonIncome));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
    expect(chip(tester, 'Salary').selected, isFalse);
  });

  testWidgets('editing pre-fills the form and updates', (tester) async {
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(lunch));
    await openSheet(tester, transaction: lunch);

    expect(find.text(l10n.transactionFormEditTitle), findsOneWidget);
    expect(find.text('12.00'), findsOneWidget);
    expect(chip(tester, 'Food').selected, isTrue);
    expect(find.text('Oct 3, 2026'), findsOneWidget);

    await tester.enterText(amountField(), '15');
    await save(tester);

    final saved = verify(() => repository.update(captureAny())).captured.single as Transaction;
    expect(saved.id, 't1');
    expect(saved.amount, const Money(1500));
  });

  testWidgets('keeps showing an archived category the transaction already uses', (tester) async {
    await openSheet(tester, transaction: lunch.copyWith(categoryId: 'Old'));

    final old = chip(tester, 'Old');
    expect(old.selected, isTrue);
    expect(old.isArchived, isTrue);
  });

  testWidgets('a category error from the repository shows under the picker', (tester) async {
    when(() => repository.create(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(
          TransactionValidator.categoryArchived,
          field: TransactionValidator.categoryField,
        ),
      ),
    );
    await openSheet(tester);

    await tester.enterText(amountField(), '5');
    await tapVisible(tester, find.text('Food'));
    await save(tester);

    expect(find.text(l10n.errorTransactionCategoryArchived), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });

  testWidgets('the date button opens a picker and updates the date', (tester) async {
    await openSheet(tester);

    await tapVisible(tester, find.text('Oct 11, 2026'));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Oct 5, 2026'), findsOneWidget);
  });

  testWidgets('a failed profile (currency) load offers a retry that shows the form', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => TransactionFormSheet.show(context),
          child: const Text('open'),
        ),
      ),
      overrides: [
        transactionRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(FixedClock(now)),
        profileProvider.overrideWith((ref) {
          loads++;
          return loads == 1
              ? Stream.error(const StorageFailure('db'))
              : Stream.value(const Profile(id: 'u1', currencyCode: 'USD'));
        }),
        categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food])),
      ],
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(amountField(), findsOneWidget);
  });

  group('repository failures land next to the field they concern', () {
    final cases = <String, (AppFailure, String)>{
      'category not found': (
        const ValidationFailure(TransactionValidator.categoryNotFound, field: 'categoryId'),
        l10n.errorTransactionCategoryRequired,
      ),
      'category type mismatch': (
        const ValidationFailure(TransactionValidator.categoryTypeMismatch, field: 'categoryId'),
        l10n.errorTransactionCategoryMismatch,
      ),
      'date out of range': (
        const ValidationFailure(TransactionValidator.dateOutOfRange, field: 'occurredOn'),
        l10n.errorTransactionDateOutOfRange,
      ),
      'amount not positive': (
        const ValidationFailure(TransactionValidator.amountNotPositive, field: 'amount'),
        l10n.errorAmountInvalid,
      ),
      'storage failure': (const StorageFailure('db'), l10n.errorStorage),
    };

    for (final MapEntry(key: name, value: (failure, message)) in cases.entries) {
      testWidgets(name, (tester) async {
        when(() => repository.create(any())).thenAnswer((_) async => Result.failure(failure));
        await openSheet(tester);

        await tester.enterText(amountField(), '5');
        await tapVisible(tester, find.text('Food'));
        await save(tester);

        expect(find.text(message), findsOneWidget);
        expect(sheet(), findsOneWidget);
      });
    }
  });
}
