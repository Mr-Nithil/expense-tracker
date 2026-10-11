import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

/// `categories.type` values (CHECK constraint). Explicit so renaming the enum can't break the DB.
extension CategoryTypeDb on CategoryType {
  String get dbValue => switch (this) {
    CategoryType.expense => 'expense',
    CategoryType.income => 'income',
  };

  static CategoryType fromDb(String value) => switch (value) {
    'expense' => CategoryType.expense,
    'income' => CategoryType.income,
    _ => throw ArgumentError.value(value, 'categories.type'),
  };
}

extension CategoryRowMapper on CategoryRow {
  Category toEntity() => Category(
    id: id,
    name: name,
    icon: icon,
    color: color,
    type: CategoryTypeDb.fromDb(type),
    isDefault: isDefault,
    sortOrder: sortOrder,
    isArchived: deletedAt != null,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
