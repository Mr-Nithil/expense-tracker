import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_providers.g.dart';

/// Active categories of [type] in display order. Re-subscribes when the signed-in user changes.
@riverpod
Stream<List<Category>> categories(Ref ref, CategoryType type) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(categoryRepositoryProvider).watchAll(type: type);
}

/// One category, **including** archived ones, so transactions can still show theirs. `null` when
/// it isn't on this device (e.g. not synced yet).
@riverpod
Stream<Category?> categoryById(Ref ref, String id) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(categoryRepositoryProvider).watchById(id);
}
