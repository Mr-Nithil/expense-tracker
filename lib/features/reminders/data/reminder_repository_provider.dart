import 'package:expense_tracker/core/db/database_provider.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_impl.dart';
import 'package:expense_tracker/features/reminders/domain/reminder_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_repository_provider.g.dart';

/// The reminder repository, exposed as its interface.
@Riverpod(keepAlive: true)
ReminderRepository reminderRepository(Ref ref) => ReminderRepositoryImpl(
  dao: ref.watch(databaseProvider).remindersDao,
  clock: ref.watch(clockProvider),
  session: ref.watch(sessionProvider.notifier),
  syncTrigger: ref.watch(syncTriggerProvider),
);
