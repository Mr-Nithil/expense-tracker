import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

/// The category type a transaction of [type] must use.
CategoryType categoryTypeOf(TransactionType type) => switch (type) {
  TransactionType.expense => CategoryType.expense,
  TransactionType.income => CategoryType.income,
};
