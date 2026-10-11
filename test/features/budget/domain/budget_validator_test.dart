import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 11);

  ValidationFailure? validate({int limit = 50000, DateTime? month}) => BudgetValidator.validate(
    limit: Money(limit),
    month: month ?? DateTime(2026, 10),
    today: today,
  );

  group('validate', () {
    test('a positive limit in range is valid', () {
      expect(validate(), isNull);
    });

    test('the limit must be positive', () {
      for (final limit in [0, -1]) {
        expect(
          validate(limit: limit),
          const ValidationFailure(
            BudgetValidator.limitNotPositive,
            field: BudgetValidator.limitField,
          ),
        );
      }
    });

    test('months from 2000 to 12 months ahead are allowed', () {
      expect(validate(month: DateTime(2000)), isNull);
      expect(validate(month: DateTime(2027, 10, 31)), isNull);
    });

    test('months outside the range are rejected', () {
      const outOfRange = ValidationFailure(
        BudgetValidator.monthOutOfRange,
        field: BudgetValidator.monthField,
      );
      expect(validate(month: DateTime(1999, 12, 31)), outOfRange);
      expect(validate(month: DateTime(2027, 11)), outOfRange);
    });
  });

  test('validateMonth checks only the month range', () {
    expect(BudgetValidator.validateMonth(DateTime(2027, 10, 31), today: today), isNull);
    expect(
      BudgetValidator.validateMonth(DateTime(2027, 11), today: today)?.message,
      BudgetValidator.monthOutOfRange,
    );
    expect(
      BudgetValidator.validateMonth(DateTime(1999, 12), today: today)?.message,
      BudgetValidator.monthOutOfRange,
    );
  });

  group('idFor', () {
    String id({String user = 'u1', DateTime? month, String? category}) => BudgetValidator.idFor(
      userId: user,
      month: month ?? DateTime(2026, 10),
      categoryId: category,
    );

    test('is the same for any day of the month', () {
      expect(id(month: DateTime(2026, 10, 31, 23, 59)), id());
    });

    test('differs by user, month and category', () {
      final ids = {
        id(),
        id(user: 'u2'),
        id(month: DateTime(2026, 11)),
        id(category: 'food'),
        id(category: 'rent'),
      };
      expect(ids, hasLength(5));
    });

    test('is a stable UUID (the key format must never change)', () {
      expect(
        id(),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
      expect(id(), BudgetValidator.idFor(userId: 'u1', month: DateTime(2026, 10, 5)));
    });
  });
}
