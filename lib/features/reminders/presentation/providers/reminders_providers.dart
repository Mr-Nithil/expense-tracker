import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminders_providers.g.dart';

/// Non-deleted reminders by time of day. Re-subscribes for a new user.
@riverpod
Stream<List<Reminder>> reminders(Ref ref) {
  ref.watch(sessionProvider.select((user) => user?.userId));
  return ref.watch(reminderRepositoryProvider).watchAll();
}
