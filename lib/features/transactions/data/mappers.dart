import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

/// `transactions.type` values (CHECK constraint). Explicit so renaming the enum can't break the DB.
extension TransactionTypeDb on TransactionType {
  String get dbValue => switch (this) {
    TransactionType.expense => 'expense',
    TransactionType.income => 'income',
  };

  static TransactionType fromDb(String value) => switch (value) {
    'expense' => TransactionType.expense,
    'income' => TransactionType.income,
    _ => throw ArgumentError.value(value, 'transactions.type'),
  };
}

extension TransactionRowMapper on TransactionRow {
  Transaction toEntity() => Transaction(
    id: id,
    type: TransactionTypeDb.fromDb(type),
    amount: Money(amountMinor),
    categoryId: categoryId,
    occurredOn: occurredOn,
    note: note,
    isDeleted: deletedAt != null,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
