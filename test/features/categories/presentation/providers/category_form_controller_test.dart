import 'dart:async';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/category_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
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
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const CategoryDraft(name: 'x', icon: 'x', color: 0, type: CategoryType.expense),
    );
    registerFallbackValue(food);
  });

  setUp(() {
    repository = _MockCategoryRepository();
    container = ProviderContainer(
      overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(categoryFormControllerProvider, (_, _) {});
  });

  CategoryFormController controller() => container.read(categoryFormControllerProvider.notifier);
  AsyncValue<void> state() => container.read(categoryFormControllerProvider);

  Future<void> saveNew() => controller().save(
    name: 'Coffee',
    icon: 'coffee',
    color: 0xFF6D4C41,
    type: CategoryType.expense,
  );

  test('creates a new category from the form values', () async {
    when(() => repository.create(any())).thenAnswer((_) async => Result.success(food));

    await saveNew();

    final draft = verify(() => repository.create(captureAny())).captured.single as CategoryDraft;
    expect(
      draft,
      const CategoryDraft(
        name: 'Coffee',
        icon: 'coffee',
        color: 0xFF6D4C41,
        type: CategoryType.expense,
      ),
    );
    expect(state(), isA<AsyncData<void>>());
  });

  test('updates an existing category with the new values', () async {
    when(() => repository.update(any())).thenAnswer((_) async => Result.success(food));

    await controller().save(
      existing: food,
      name: 'Groceries',
      icon: 'groceries',
      color: 0xFF43A047,
      type: CategoryType.expense,
    );

    final saved = verify(() => repository.update(captureAny())).captured.single as Category;
    expect(saved.id, food.id);
    expect(saved.name, 'Groceries');
    expect(saved.icon, 'groceries');
    expect(saved.color, 0xFF43A047);
    verifyNever(() => repository.create(any()));
  });

  test('is loading while saving and exposes a failure as an error', () async {
    final completer = Completer<Result<Category>>();
    when(() => repository.create(any())).thenAnswer((_) => completer.future);

    final pending = saveNew();
    expect(state().isLoading, isTrue);

    const failure = ValidationFailure('duplicateName', field: 'name');
    completer.complete(const Result.failure(failure));
    await pending;

    expect(state().error, failure);
  });

  test('ignores a second save while one is in flight', () async {
    final completer = Completer<Result<Category>>();
    when(() => repository.create(any())).thenAnswer((_) => completer.future);

    final first = saveNew();
    await saveNew();
    completer.complete(Result.success(food));
    await first;

    verify(() => repository.create(any())).called(1);
  });

  group('archive', () {
    test('archives the category by id', () async {
      when(() => repository.archive(any())).thenAnswer((_) async => Result.ok);

      await controller().archive(food);

      verify(() => repository.archive('food')).called(1);
      expect(state(), isA<AsyncData<void>>());
    });

    test('exposes a failure as an error', () async {
      const failure = NotFoundFailure('category');
      when(() => repository.archive(any())).thenAnswer((_) async => const Result.failure(failure));

      await controller().archive(food);

      expect(state().error, failure);
    });
  });
}
