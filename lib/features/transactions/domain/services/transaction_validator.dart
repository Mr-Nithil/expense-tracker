import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/core/utils/money.dart';

/// Field rules for transactions that need no database. The repository adds the category checks.
abstract final class TransactionValidator {
  /// Matches the `transactions.note` check constraint.
  static const maxNoteLength = 500;

  /// Allowed future range: planned expenses are fine, a typo like 2206 is not.
  static const maxMonthsAhead = 12;

  static final earliestDate = DateTime(2000);

  static DateTime latestDate(DateTime today) =>
      AppDateUtils.addMonths(AppDateUtils.dateOnly(today), maxMonthsAhead);

  static const amountField = 'amount';
  static const dateField = 'occurredOn';
  static const noteField = 'note';
  static const categoryField = 'categoryId';

  /// `ValidationFailure.message` reasons, shared by the repository and the form.
  static const amountNotPositive = 'amountNotPositive';
  static const dateOutOfRange = 'dateOutOfRange';
  static const noteTooLong = 'noteTooLong';
  static const categoryNotFound = 'categoryNotFound';
  static const categoryArchived = 'categoryArchived';
  static const categoryTypeMismatch = 'categoryTypeMismatch';

  /// The first problem found, or `null` when valid. [today] comes from the injected clock.
  static ValidationFailure? validate({
    required Money amount,
    required DateTime occurredOn,
    required String? note,
    required DateTime today,
  }) {
    if (!amount.isPositive) {
      return const ValidationFailure(amountNotPositive, field: amountField);
    }
    final date = AppDateUtils.dateOnly(occurredOn);
    if (date.isBefore(earliestDate) || date.isAfter(latestDate(today))) {
      return const ValidationFailure(dateOutOfRange, field: dateField);
    }
    if ((normalizeNote(note)?.length ?? 0) > maxNoteLength) {
      return const ValidationFailure(noteTooLong, field: noteField);
    }
    return null;
  }

  /// Trimmed note, or `null` when empty.
  static String? normalizeNote(String? note) {
    final trimmed = note?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
