import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';

/// Goal and contribution rules that need no database. The repository adds the goal checks.
abstract final class GoalValidator {
  /// Match the `goals.name` and `goal_contributions.note` check constraints.
  static const maxNameLength = 100;
  static const maxNoteLength = 500;

  /// Deadlines can be far ahead (a house), but not absurdly (a typo like 2206).
  static const maxDeadlineYearsAhead = 50;

  static final earliestDate = DateTime(2000);

  static DateTime latestDeadline(DateTime today) {
    final date = AppDateUtils.dateOnly(today);
    return DateTime(date.year + maxDeadlineYearsAhead, date.month, date.day);
  }

  /// A contribution is money already put aside: never in the future.
  static DateTime latestContributionDate(DateTime today) => AppDateUtils.dateOnly(today);

  static const nameField = 'name';
  static const targetField = 'target';
  static const deadlineField = 'deadlineOn';
  static const amountField = 'amount';
  static const dateField = 'contributedOn';
  static const noteField = 'note';
  static const goalField = 'goalId';

  /// `ValidationFailure.message` reasons, shared by the repository and the forms.
  static const nameRequired = 'nameRequired';
  static const nameTooLong = 'nameTooLong';
  static const targetNotPositive = 'targetNotPositive';
  static const deadlineOutOfRange = 'deadlineOutOfRange';
  static const amountNotPositive = 'amountNotPositive';
  static const dateOutOfRange = 'dateOutOfRange';
  static const noteTooLong = 'noteTooLong';
  static const goalNotFound = 'goalNotFound';

  /// The first problem with a goal's fields, or `null`. [today] comes from the injected clock.
  static ValidationFailure? validateGoal({
    required String name,
    required Money target,
    required DateTime? deadlineOn,
    required DateTime today,
  }) {
    final trimmed = normalizeName(name);
    if (trimmed.isEmpty) return const ValidationFailure(nameRequired, field: nameField);
    if (trimmed.length > maxNameLength) {
      return const ValidationFailure(nameTooLong, field: nameField);
    }
    if (!target.isPositive) {
      return const ValidationFailure(targetNotPositive, field: targetField);
    }
    if (deadlineOn != null) {
      final date = AppDateUtils.dateOnly(deadlineOn);
      if (date.isBefore(earliestDate) || date.isAfter(latestDeadline(today))) {
        return const ValidationFailure(deadlineOutOfRange, field: deadlineField);
      }
    }
    return null;
  }

  /// The first problem with a contribution's fields, or `null`.
  static ValidationFailure? validateContribution({
    required Money amount,
    required DateTime contributedOn,
    required String? note,
    required DateTime today,
  }) {
    if (!amount.isPositive) {
      return const ValidationFailure(amountNotPositive, field: amountField);
    }
    final date = AppDateUtils.dateOnly(contributedOn);
    if (date.isBefore(earliestDate) || date.isAfter(latestContributionDate(today))) {
      return const ValidationFailure(dateOutOfRange, field: dateField);
    }
    if ((normalizeNote(note)?.length ?? 0) > maxNoteLength) {
      return const ValidationFailure(noteTooLong, field: noteField);
    }
    return null;
  }

  static String normalizeName(String name) => name.trim();

  /// Trimmed note, or `null` when empty.
  static String? normalizeNote(String? note) {
    final trimmed = note?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
