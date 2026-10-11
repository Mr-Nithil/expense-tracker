import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_database.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = createTestContainer();
    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u1'));
  });

  Future<void> create(String name, CategoryType type) async {
    final result = await container
        .read(categoryRepositoryProvider)
        .create(CategoryDraft(name: name, icon: 'food', color: 0xFF000000, type: type));
    expect(result.isSuccess, isTrue);
  }

  Future<List<String>> names(CategoryType type) async =>
      (await container.read(categoriesProvider(type).future)).map((c) => c.name).toList();

  test('lists active categories of one type and follows changes', () async {
    // Keep both auto-dispose providers alive, like the two tabs do.
    container
      ..listen(categoriesProvider(CategoryType.expense), (_, _) {})
      ..listen(categoriesProvider(CategoryType.income), (_, _) {});
    await create('Food', CategoryType.expense);
    await create('Salary', CategoryType.income);
    await pumpEventQueue();

    expect(await names(CategoryType.expense), ['Food']);
    expect(await names(CategoryType.income), ['Salary']);
  });

  test('re-subscribes for a different user', () async {
    container.listen(categoriesProvider(CategoryType.expense), (_, _) {});
    await create('Food', CategoryType.expense);
    await pumpEventQueue();
    expect(await names(CategoryType.expense), ['Food']);

    container.read(sessionProvider.notifier).set(const SessionUser(userId: 'u2'));
    await pumpEventQueue();

    expect(await names(CategoryType.expense), isEmpty);
  });

  test('categoryById still returns archived categories and is null for unknown ids', () async {
    final repository = container.read(categoryRepositoryProvider);
    final food = (await repository.create(
      const CategoryDraft(
        name: 'Food',
        icon: 'food',
        color: 0xFF000000,
        type: CategoryType.expense,
      ),
    )).valueOrNull!;
    await repository.archive(food.id);
    container
      ..listen(categoryByIdProvider(food.id), (_, _) {})
      ..listen(categoryByIdProvider('missing'), (_, _) {});
    await pumpEventQueue();

    final archived = await container.read(categoryByIdProvider(food.id).future);
    expect(archived?.isArchived, isTrue);
    expect(archived?.name, 'Food');
    expect(await container.read(categoryByIdProvider('missing').future), isNull);
  });
}
