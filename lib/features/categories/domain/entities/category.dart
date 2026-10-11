import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

enum CategoryType { expense, income }

/// A transaction category. Archived categories are soft-deleted: hidden from pickers, but still
/// shown on the transactions that use them.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,

    /// Icon key resolved by the UI (M2.6), not a code point.
    required String icon,

    /// ARGB color value.
    required int color,
    required CategoryType type,
    required bool isDefault,
    required int sortOrder,
    required bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;
}

/// The user-editable part of a new category. The repository sets id, order and timestamps.
@freezed
abstract class CategoryDraft with _$CategoryDraft {
  const factory CategoryDraft({
    required String name,
    required String icon,
    required int color,
    required CategoryType type,
  }) = _CategoryDraft;
}
