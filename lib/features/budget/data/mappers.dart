import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget.dart';

extension BudgetRowMapper on BudgetRow {
  Budget toEntity() => Budget(
    id: id,
    month: month,
    categoryId: categoryId,
    limit: Money(limitMinor),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
