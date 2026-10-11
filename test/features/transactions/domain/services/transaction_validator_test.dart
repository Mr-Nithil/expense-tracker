import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/transactions/domain/services/transaction_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 11, 15, 30);

  String? reasonOf({int amount = 1200, DateTime? on, String? note}) =>
      TransactionValidator.validate(
        amount: Money(amount),
        occurredOn: on ?? DateTime(2026, 10, 11),
        note: note,
        today: today,
      )?.message;

  test('accepts a normal transaction', () {
    expect(reasonOf(), isNull);
  });

  test('the amount must be positive', () {
    expect(reasonOf(amount: 0), TransactionValidator.amountNotPositive);
    expect(reasonOf(amount: -5), TransactionValidator.amountNotPositive);
    expect(reasonOf(amount: 1), isNull);
  });

  test('dates from 2000-01-01 up to 12 months ahead are valid', () {
    expect(reasonOf(on: DateTime(2000)), isNull);
    expect(reasonOf(on: DateTime(1999, 12, 31)), TransactionValidator.dateOutOfRange);
    expect(reasonOf(on: DateTime(2027, 10, 11)), isNull);
    expect(reasonOf(on: DateTime(2027, 10, 12)), TransactionValidator.dateOutOfRange);
  });

  test('a time of day on the date is ignored', () {
    expect(reasonOf(on: DateTime(2027, 10, 11, 23, 59)), isNull);
  });

  test('the trimmed note is limited', () {
    const max = TransactionValidator.maxNoteLength;
    expect(reasonOf(note: 'x' * max), isNull);
    expect(reasonOf(note: '  ${'x' * max}  '), isNull);
    expect(reasonOf(note: 'x' * (max + 1)), TransactionValidator.noteTooLong);
  });

  test('normalizeNote trims and drops empty notes', () {
    expect(TransactionValidator.normalizeNote('  lunch  '), 'lunch');
    expect(TransactionValidator.normalizeNote('   '), isNull);
    expect(TransactionValidator.normalizeNote(null), isNull);
  });

  test('the failure names its field', () {
    final failure = TransactionValidator.validate(
      amount: Money.zero,
      occurredOn: today,
      note: null,
      today: today,
    );
    expect(failure?.field, TransactionValidator.amountField);
  });
}
