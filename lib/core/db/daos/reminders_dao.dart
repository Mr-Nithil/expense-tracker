import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/tables/reminders.dart';

part 'reminders_dao.g.dart';

/// Reminder queries. Every query is scoped to [userId]; rules live in the repository.
@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase> with _$RemindersDaoMixin {
  RemindersDao(super.attachedDatabase);

  /// Non-deleted reminders by time of day (`HH:mm` sorts as text), then title.
  Stream<List<ReminderRow>> watchAll(String userId) => _live(userId).watch();

  /// Non-deleted enabled reminders, read once (to (re)schedule notifications).
  Future<List<ReminderRow>> getEnabled(String userId) =>
      (_live(userId)..where((r) => r.enabled.equals(true))).get();

  /// One non-deleted reminder, or `null`.
  Stream<ReminderRow?> watchById(String userId, String id) =>
      (_live(userId)..where((r) => r.id.equals(id))).watchSingleOrNull();

  SimpleSelectStatement<$RemindersTable, ReminderRow> _live(String userId) => select(reminders)
    ..where((r) => r.userId.equals(userId) & r.deletedAt.isNull())
    ..orderBy([
      (r) => OrderingTerm.asc(r.timeOfDay),
      (r) => OrderingTerm.asc(r.title),
      (r) => OrderingTerm.asc(r.id),
    ]);

  /// Includes soft-deleted rows.
  Future<ReminderRow?> getById(String userId, String id) => (select(
    reminders,
  )..where((r) => r.userId.equals(userId) & r.id.equals(id))).getSingleOrNull();

  Future<void> insertReminder(RemindersCompanion row) => into(reminders).insert(row);

  /// Returns the number of updated rows (0 when it doesn't exist for [userId]).
  Future<int> updateReminder(String userId, String id, RemindersCompanion changes) =>
      (update(reminders)..where((r) => r.userId.equals(userId) & r.id.equals(id))).write(changes);
}
