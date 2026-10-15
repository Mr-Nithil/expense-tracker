import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations_en.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/categories/domain/services/category_validator.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/accessibility.dart';
import '../../../../helpers/pump_app.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  final l10n = AppLocalizationsEn();
  final at = DateTime.utc(2026, 10, 10);
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

  late _MockCategoryRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const CategoryDraft(name: 'x', icon: 'x', color: 0, type: CategoryType.expense),
    );
    registerFallbackValue(food);
  });

  setUp(() => repository = _MockCategoryRepository());

  /// A page with a button that opens the sheet, like the categories screen does.
  Future<void> openSheet(
    WidgetTester tester, {
    Category? category,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => CategoryFormSheet.show(context, category: category),
          child: const Text('open'),
        ),
      ),
      brightness: brightness,
      overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.tap(findText('open'));
    await tester.pumpAndSettle();
  }

  Finder nameField() => findWidgetWithText(TextFormField, l10n.categoryFormNameLabel);
  Finder sheet() => find.byType(CategoryFormSheet);

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(findText(l10n.commonSave));
    await tester.tap(findText(l10n.commonSave));
    await tester.pumpAndSettle();
  }

  Future<void> tapOption(WidgetTester tester, String label) async {
    final option = find.bySemanticsLabel(label);
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  testWidgetsBothThemes('renders the new-category form', (tester, brightness) async {
    await openSheet(tester, brightness: brightness);

    expect(findText(l10n.categoryFormNewTitle), findsOneWidget);
    expect(nameField(), findsOneWidget);
    expect(findText(l10n.categoryFormIconLabel), findsOneWidget);
    expect(findText(l10n.categoryFormColorLabel), findsOneWidget);
  });

  testWidgets('saves a new category with the chosen type, icon and color, then closes', (
    tester,
  ) async {
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(food));
    await openSheet(tester);
    final icons = CategoryIcon.keys.toList();
    final colors = CategoryPalette.colors;

    await tester.enterText(nameField(), 'Coffee');
    await tester.tap(findText(l10n.commonIncome));
    await tapOption(tester, l10n.categoryFormIconOption(3, icons.length));
    await tapOption(tester, l10n.categoryFormColorOption(2, colors.length));
    await save(tester);

    final draft = verify(() => repository.create(captureAny())).captured.single as CategoryDraft;
    expect(draft.name, 'Coffee');
    expect(draft.type, CategoryType.income);
    expect(draft.icon, icons[2]);
    expect(draft.color, colors[1]);
    expect(sheet(), findsNothing);
  });

  testWidgets('an empty name is required and nothing is saved', (tester) async {
    await openSheet(tester);

    await save(tester);

    expect(findText(l10n.errorFieldRequired), findsOneWidget);
    verifyNever(() => repository.create(any()));
  });

  testWidgets('a duplicate name shows under the field and keeps the sheet open', (tester) async {
    when(() => repository.create(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(CategoryValidator.duplicateName, field: CategoryValidator.nameField),
      ),
    );
    await openSheet(tester);

    await tester.enterText(nameField(), 'Food');
    await save(tester);

    expect(findText(l10n.errorCategoryNameTaken), findsOneWidget);
    expect(sheet(), findsOneWidget);

    await tester.enterText(nameField(), 'Food 2');
    await tester.pump();
    expect(findText(l10n.errorCategoryNameTaken), findsNothing);
  });

  testWidgets('editing pre-fills the form and updates the category', (tester) async {
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(food));
    await openSheet(tester, category: food);

    expect(findText(l10n.categoryFormEditTitle), findsOneWidget);
    expect(findWidgetWithText(TextFormField, 'Food'), findsOneWidget);
    // The category's icon is preselected and announced as a selected, tappable button.
    final firstIcon = l10n.categoryFormIconOption(1, CategoryIcon.keys.length);
    expect(
      tester.getSemantics(find.bySemanticsLabel(firstIcon)),
      isSemantics(label: firstIcon, isButton: true, isSelected: true, hasTapAction: true),
    );

    await tester.enterText(nameField(), 'Groceries');
    await save(tester);

    final saved = verify(() => repository.update(captureAny())).captured.single as Category;
    expect(saved.id, 'food');
    expect(saved.name, 'Groceries');
    verifyNever(() => repository.create(any()));
  });

  testWidgets('a locked type shows an inline message', (tester) async {
    when(() => repository.update(any())).thenAnswer(
      (_) async => const Result.failure(
        ValidationFailure(
          CategoryValidator.typeLockedByTransactions,
          field: CategoryValidator.typeField,
        ),
      ),
    );
    await openSheet(tester, category: food);

    await tester.tap(findText(l10n.commonIncome));
    await save(tester);

    expect(findText(l10n.errorCategoryTypeLocked), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });

  testWidgets('any other failure shows inline and keeps the sheet open', (tester) async {
    when(
      () => repository.create(any()),
    ).thenAnswer((_) async => const Result.failure(StorageFailure('db')));
    await openSheet(tester);

    await tester.enterText(nameField(), 'Coffee');
    await save(tester);

    expect(findText(l10n.errorStorage), findsOneWidget);
    expect(sheet(), findsOneWidget);
  });

  group('archive', () {
    Finder archiveButton() => findWidgetWithText(TextButton, l10n.categoryFormArchive);

    Future<void> tapArchive(WidgetTester tester) async {
      await tester.ensureVisible(archiveButton());
      await tester.tap(archiveButton());
      await tester.pumpAndSettle();
    }

    Finder inDialog(String text) =>
        find.descendant(of: find.byType(AlertDialog), matching: findText(text));

    testWidgets('is not offered when adding', (tester) async {
      await openSheet(tester);
      expect(archiveButton(), findsNothing);
    });

    testWidgets('confirming archives the category and closes the sheet', (tester) async {
      when(() => repository.archive(any())).thenAnswer((_) async => Result.ok);
      await openSheet(tester, category: food);

      await tapArchive(tester);
      expect(inDialog(l10n.categoryArchiveConfirmTitle('Food')), findsOneWidget);
      await tester.tap(inDialog(l10n.categoryFormArchive));
      await tester.pumpAndSettle();

      verify(() => repository.archive('food')).called(1);
      expect(sheet(), findsNothing);
    });

    testWidgets('cancelling keeps the category and the sheet', (tester) async {
      await openSheet(tester, category: food);

      await tapArchive(tester);
      await tester.tap(inDialog(l10n.commonCancel));
      await tester.pumpAndSettle();

      verifyNever(() => repository.archive(any()));
      expect(sheet(), findsOneWidget);
    });
  });

  group('accessibility (M9.5)', () {
    testWidgetsBothThemes('meets the guidelines', (tester, brightness) async {
      await openSheet(tester, brightness: brightness);
      await expectAccessible(tester);
    });

    testWidgets('large text (2x) fits', (tester) async {
      useTextScale(tester, 2);
      await openSheet(tester);
      await scrollThrough(tester);
    });
  });
}
