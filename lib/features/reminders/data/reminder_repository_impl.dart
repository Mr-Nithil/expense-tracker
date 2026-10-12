import 'package:drift/drift.dart';
import 'package:expense_tracker/core/db/app_database.dart';
import 'package:expense_tracker/core/db/daos/reminders_dao.dart';
import 'package:expense_tracker/core/db/tables/sync_columns.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/id.dart';
import 'package:expense_tracker/features/reminders/data/mappers.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/domain/reminder_repository.dart';
import 'package:expense_tracker/features/reminders/domain/services/reminder_validator.dart';
import 'package:expense_tracker/features/reminders/domain/services/weekday_mask.dart';

/// [ReminderRepository] backed by the local `reminders` table.
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    required this.dao,
    required this.clock,
    required this.session,
    required this.syncTrigger,
  });

  final RemindersDao dao;
  final Clock clock;
  final Session session;
  final SyncTrigger syncTrigger;

  static const _noSession = AuthFailure('reminders: no session');
  static const _notFound = NotFoundFailure('reminder');

  @override
  Stream<List<Reminder>> watchAll() {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(const []);
    return dao.watchAll(userId).map((rows) => [for (final row in rows) row.toEntity()]);
  }

  @override
  Stream<Reminder?> watchById(String id) {
    final userId = session.currentUser?.userId;
    if (userId == null) return Stream.value(null);
    return dao.watchById(userId, id).map((row) => row?.toEntity());
  }

  @override
  Future<Result<Reminder>> create(ReminderDraft draft) async {
    final invalid = _validate(
      draft.title,
      draft.time,
      draft.repeat,
      draft.weekdays,
      draft.dayOfMonth,
    );
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('create', () async {
      final id = IdGenerator.newId();
      final now = clock.now().toUtc();
      final kept = ReminderValidator.normalize(
        repeat: draft.repeat,
        weekdays: draft.weekdays,
        dayOfMonth: draft.dayOfMonth,
      );
      await dao.insertReminder(
        RemindersCompanion.insert(
          id: id,
          userId: userId,
          createdAt: now,
          updatedAt: now,
          title: ReminderValidator.normalizeTitle(draft.title),
          timeOfDay: draft.time.toHhMm(),
          repeatRule: draft.repeat.name,
          weekdays: Value(_mask(kept.weekdays)),
          dayOfMonth: Value(kept.dayOfMonth),
          enabled: Value(draft.enabled),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, id))!.toEntity());
    });
  }

  @override
  Future<Result<Reminder>> update(Reminder reminder) async {
    final invalid = _validate(
      reminder.title,
      reminder.time,
      reminder.repeat,
      reminder.weekdays,
      reminder.dayOfMonth,
    );
    if (invalid != null) return Result.failure(invalid);
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('update', () async {
      final existing = await dao.getById(userId, reminder.id);
      if (existing == null || existing.deletedAt != null) return const Result.failure(_notFound);

      final kept = ReminderValidator.normalize(
        repeat: reminder.repeat,
        weekdays: reminder.weekdays,
        dayOfMonth: reminder.dayOfMonth,
      );
      await dao.updateReminder(
        userId,
        reminder.id,
        RemindersCompanion(
          title: Value(ReminderValidator.normalizeTitle(reminder.title)),
          timeOfDay: Value(reminder.time.toHhMm()),
          repeatRule: Value(reminder.repeat.name),
          weekdays: Value(_mask(kept.weekdays)),
          dayOfMonth: Value(kept.dayOfMonth),
          enabled: Value(reminder.enabled),
          updatedAt: Value(clock.now().toUtc()),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.success((await dao.getById(userId, reminder.id))!.toEntity());
    });
  }

  @override
  Future<Result<void>> setEnabled(String id, {required bool enabled}) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('setEnabled', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null || existing.deletedAt != null) return const Result.failure(_notFound);
      if (existing.enabled == enabled) return Result.ok;

      await dao.updateReminder(
        userId,
        id,
        RemindersCompanion(
          enabled: Value(enabled),
          updatedAt: Value(clock.now().toUtc()),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  @override
  Future<Result<void>> delete(String id) async {
    final userId = session.currentUser?.userId;
    if (userId == null) return const Result.failure(_noSession);

    return _guard('delete', () async {
      final existing = await dao.getById(userId, id);
      if (existing == null) return const Result.failure(_notFound);
      if (existing.deletedAt != null) return Result.ok;

      final now = clock.now().toUtc();
      await dao.updateReminder(
        userId,
        id,
        RemindersCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      syncTrigger.requestSync();
      return Result.ok;
    });
  }

  ValidationFailure? _validate(
    String title,
    ReminderTime time,
    ReminderRepeat repeat,
    Set<int> weekdays,
    int? dayOfMonth,
  ) => ReminderValidator.validate(
    title: title,
    time: time,
    repeat: repeat,
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
  );

  /// The stored mask, or null when no weekday applies.
  static int? _mask(Set<int> weekdays) => weekdays.isEmpty ? null : WeekdayMask.encode(weekdays);

  /// Runs [body] in one DB transaction and turns any exception into a `StorageFailure`.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await dao.transaction(body);
    } catch (error, stackTrace) {
      AppLogger.error('reminder $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('reminder $operation: $error'));
    }
  }
}
