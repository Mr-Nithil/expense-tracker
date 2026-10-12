import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/core/widgets/category_chip.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/domain/entities/profile.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_provider.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transactions_providers.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/shared/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 1);

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

  Transaction lunch({String? note = 'Team lunch', bool deleted = false}) => Transaction(
    id: 't1',
    type: TransactionType.expense,
    amount: const Money(1250),
    categoryId: 'food',
    occurredOn: DateTime(2026, 10, 11),
    note: note,
    isDeleted: deleted,
    createdAt: at,
    updatedAt: at,
  );

  late _MockTransactionRepository repository;

  setUp(() {
    repository = _MockTransactionRepository();
    when(() => repository.delete(any())).thenAnswer((_) async => Result.ok);
    when(() => repository.restore(any())).thenAnswer((_) async => Result.ok);
  });

  /// The detail page opened on top of a list stub, like in the app.
  Future<void> pumpDetail(
    WidgetTester tester, {
    Transaction? transaction,
    Category? category,
    Brightness brightness = Brightness.light,
    Stream<Transaction?> Function()? stream,
    Stream<Profile?> Function()? profile,
  }) => tester.pumpRouterApp(
    initialLocation: '${Routes.transactionsPath}/t1',
    brightness: brightness,
    overrides: [
      transactionRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 10, 11))),
      if (profile == null)
        currencyCodeProvider.overrideWith((ref) async => 'USD')
      else
        profileProvider.overrideWith((ref) => profile()),
      transactionByIdProvider(
        't1',
      ).overrideWith((ref) => (stream ?? () => Stream.value(transaction))()),
      categoryByIdProvider('food').overrideWith((ref) => Stream.value(category ?? food())),
      categoriesProvider(CategoryType.expense).overrideWith((ref) => Stream.value([food()])),
    ],
    routes: [
      GoRoute(
        path: Routes.transactionsPath,
        builder: (_, _) => const Scaffold(body: Text('list')),
        routes: [
          GoRoute(
            path: ':${Routes.transactionIdParam}',
            builder: (_, state) =>
                TransactionDetailScreen(id: state.pathParameters[Routes.transactionIdParam]!),
          ),
        ],
      ),
    ],
  );

  testWidgetsBothThemes('shows amount, type, category, date and note', (tester, brightness) async {
    await pumpDetail(tester, transaction: lunch(), brightness: brightness);

    expect(find.text(l10n.transactionDetailTitle), findsOneWidget);
    expect(find.text(r'-$12.50'), findsOneWidget);
    expect(find.text(l10n.commonExpense), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Sunday, October 11, 2026'), findsOneWidget);
    expect(find.text('Team lunch'), findsOneWidget);
  });

  testWidgets('no note means no note row', (tester) async {
    await pumpDetail(tester, transaction: lunch(note: null));
    expect(find.text(l10n.transactionDetailNoteLabel), findsNothing);
  });

  testWidgets('an archived category is shown as archived', (tester) async {
    await pumpDetail(tester, transaction: lunch(), category: food(archived: true));
    expect(tester.widget<CategoryChip>(find.byType(CategoryChip)).isArchived, isTrue);
  });

  testWidgets('a missing or deleted transaction is not found, with no actions', (tester) async {
    await pumpDetail(tester);
    expect(find.text(l10n.transactionNotFoundTitle), findsOneWidget);
    expect(find.byTooltip(l10n.commonDelete), findsNothing);

    await pumpDetail(tester, transaction: lunch(deleted: true));
    expect(find.text(l10n.transactionNotFoundTitle), findsOneWidget);
  });

  testWidgets('Edit opens the edit sheet', (tester) async {
    await pumpDetail(tester, transaction: lunch());

    await tester.tap(find.byTooltip(l10n.commonEdit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.transactionFormEditTitle), findsOneWidget);
    expect(
      tester.widget<TransactionFormSheet>(find.byType(TransactionFormSheet)).transaction?.id,
      't1',
    );
  });

  testWidgets('Delete goes back to the list with Undo', (tester) async {
    await pumpDetail(tester, transaction: lunch());

    await tester.tap(find.byTooltip(l10n.commonDelete));
    await tester.pumpAndSettle();

    verify(() => repository.delete('t1')).called(1);
    expect(find.text('list'), findsOneWidget);
    expect(find.text(l10n.transactionDeleted), findsOneWidget);

    await tester.tap(find.text(l10n.commonUndo));
    await tester.pumpAndSettle();
    verify(() => repository.restore('t1')).called(1);
  });

  testWidgets('a failed delete stays on the page with the error', (tester) async {
    when(
      () => repository.delete(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
    await pumpDetail(tester, transaction: lunch());

    await tester.tap(find.byTooltip(l10n.commonDelete));
    await tester.pumpAndSettle();

    expect(find.text(l10n.transactionDetailTitle), findsOneWidget);
    expect(find.text(l10n.errorStorage), findsOneWidget);
  });

  testWidgets('a load error offers a retry that reloads the transaction', (tester) async {
    var loads = 0;
    await pumpDetail(
      tester,
      stream: () {
        loads++;
        return loads == 1 ? Stream.error(const StorageFailure('db')) : Stream.value(lunch());
      },
    );
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.text(r'-$12.50'), findsOneWidget);
  });

  testWidgets('an income shows a positive amount and its type', (tester) async {
    await pumpDetail(
      tester,
      transaction: lunch().copyWith(type: TransactionType.income, amount: const Money(85000)),
    );

    expect(find.text(r'+$850.00'), findsOneWidget);
    expect(find.text(l10n.commonIncome), findsOneWidget);
  });

  testWidgets('a failed profile (currency) load offers a retry that shows the details', (
    tester,
  ) async {
    var loads = 0;
    await pumpDetail(
      tester,
      transaction: lunch(),
      profile: () {
        loads++;
        return loads == 1
            ? Stream.error(const StorageFailure('db'))
            : Stream.value(const Profile(id: 'u1', currencyCode: 'USD'));
      },
    );
    expect(find.text(l10n.errorStorage), findsOneWidget);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.text(r'-$12.50'), findsOneWidget);
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await pumpDetail(tester, transaction: lunch(), brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await pumpDetail(tester, transaction: lunch());
      await scrollThrough(tester);
    });
  });
}
