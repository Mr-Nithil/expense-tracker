import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';

/// The signed-in user's reminders, in the local DB (synced later). Each device schedules its own
/// notifications from them (M8.4).
///
/// Writes validate input (`ReminderValidator`) and fail with `ValidationFailure`,
/// `NotFoundFailure`, `AuthFailure` (no session) or `StorageFailure`. They never throw.
abstract interface class ReminderRepository {
  /// Non-deleted reminders by time of day, then title.
  Stream<List<Reminder>> watchAll();

  /// One non-deleted reminder, or `null`.
  Stream<Reminder?> watchById(String id);

  Future<Result<Reminder>> create(ReminderDraft draft);

  /// Updates title, time, repeat, weekdays, day of month and enabled.
  Future<Result<Reminder>> update(Reminder reminder);

  /// Turns a reminder on or off without touching the rest.
  Future<Result<void>> setEnabled(String id, {required bool enabled});

  /// Soft delete.
  Future<Result<void>> delete(String id);
}
