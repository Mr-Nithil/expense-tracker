import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/services/default_categories.dart';

/// The signed-in user's categories, in the local DB (synced later).
///
/// Writes validate input and fail with a `ValidationFailure` (see `CategoryValidator`, plus a
/// duplicate name or a type change on a category in use), `NotFoundFailure`, `AuthFailure`
/// (no session) or `StorageFailure`. They never throw.
abstract interface class CategoryRepository {
  /// Active categories (optionally of one [type]) in display order.
  Stream<List<Category>> watchAll({CategoryType? type});

  /// One category, **including** archived ones, so transactions can still show theirs.
  Stream<Category?> watchById(String id);

  /// Adds a category at the end of its type's list.
  Future<Result<Category>> create(CategoryDraft draft);

  /// Saves name, icon, color and type. The type can't change once transactions use it.
  Future<Result<Category>> update(Category category);

  /// Soft-deletes (archives) a category. Its transactions keep it.
  Future<Result<void>> archive(String id);

  /// Inserts the defaults that are missing (by deterministic id) and returns how many were added.
  /// Existing defaults, including archived or edited ones, are left alone, and a default whose
  /// name is already used by an active category of its type is skipped. Safe to call repeatedly.
  Future<Result<int>> seedDefaults(List<DefaultCategorySeed> seeds);
}
