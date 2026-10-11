import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/money.dart';
import 'package:expense_tracker/features/goals/domain/services/goal_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 11, 15);

  group('validateGoal', () {
    String? reason({String name = 'Laptop', int target = 100000, DateTime? deadline}) =>
        GoalValidator.validateGoal(
          name: name,
          target: Money(target),
          deadlineOn: deadline,
          today: today,
        )?.message;

    test('a named, positive goal with or without a deadline is valid', () {
      expect(reason(), isNull);
      expect(reason(deadline: DateTime(2027, 6, 1)), isNull);
    });

    test('the name is required (after trimming) and limited to 100 characters', () {
      expect(reason(name: '   '), GoalValidator.nameRequired);
      expect(reason(name: ' ${'a' * 100} '), isNull);
      expect(reason(name: 'a' * 101), GoalValidator.nameTooLong);
    });

    test('the target must be positive', () {
      for (final target in [0, -5]) {
        expect(
          GoalValidator.validateGoal(
            name: 'x',
            target: Money(target),
            deadlineOn: null,
            today: today,
          ),
          const ValidationFailure(
            GoalValidator.targetNotPositive,
            field: GoalValidator.targetField,
          ),
        );
      }
    });

    test('deadlines from 2000 to 50 years ahead; past deadlines are allowed', () {
      expect(reason(deadline: DateTime(2000)), isNull);
      expect(reason(deadline: DateTime(2024, 1, 1)), isNull);
      expect(reason(deadline: DateTime(2076, 10, 11)), isNull);
      expect(reason(deadline: DateTime(1999, 12, 31)), GoalValidator.deadlineOutOfRange);
      expect(reason(deadline: DateTime(2076, 10, 12)), GoalValidator.deadlineOutOfRange);
    });
  });

  group('validateContribution', () {
    String? reason({int amount = 5000, DateTime? on, String? note}) =>
        GoalValidator.validateContribution(
          amount: Money(amount),
          contributedOn: on ?? DateTime(2026, 10, 1),
          note: note,
          today: today,
        )?.message;

    test('a positive amount up to today is valid', () {
      expect(reason(), isNull);
      expect(reason(on: DateTime(2026, 10, 11, 23)), isNull);
    });

    test('the amount must be positive', () {
      expect(reason(amount: 0), GoalValidator.amountNotPositive);
    });

    test('no future contributions, none before 2000', () {
      expect(reason(on: DateTime(2026, 10, 12)), GoalValidator.dateOutOfRange);
      expect(reason(on: DateTime(1999, 12, 31)), GoalValidator.dateOutOfRange);
    });

    test('the note is limited to 500 characters after trimming', () {
      expect(reason(note: ' ${'n' * 500} '), isNull);
      expect(reason(note: 'n' * 501), GoalValidator.noteTooLong);
    });
  });

  test('normalizers trim; an empty note becomes null', () {
    expect(GoalValidator.normalizeName('  Car  '), 'Car');
    expect(GoalValidator.normalizeNote('   '), isNull);
    expect(GoalValidator.normalizeNote(' bonus '), 'bonus');
  });
}
