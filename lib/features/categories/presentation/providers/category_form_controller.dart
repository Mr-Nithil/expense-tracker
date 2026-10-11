import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/data/category_repository_provider.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_form_controller.g.dart';

/// Add/edit category form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or
/// archived.
@riverpod
class CategoryFormController extends _$CategoryFormController {
  @override
  FutureOr<void> build() {}

  /// Creates a category, or updates [existing] when given. The repository validates.
  Future<void> save({
    Category? existing,
    required String name,
    required String icon,
    required int color,
    required CategoryType type,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final repository = ref.read(categoryRepositoryProvider);
    final result = existing == null
        ? await repository.create(CategoryDraft(name: name, icon: icon, color: color, type: type))
        : await repository.update(
            existing.copyWith(name: name, icon: icon, color: color, type: type),
          );
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Archives (soft-deletes) [category]. Its transactions keep it.
  Future<void> archive(Category category) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await ref.read(categoryRepositoryProvider).archive(category.id);
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
