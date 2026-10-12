import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/reminders/data/reminder_repository_provider.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_form_controller.g.dart';

/// Add/edit reminder form state: idle/done (`AsyncData`), working (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once done.
@riverpod
class ReminderFormController extends _$ReminderFormController {
  @override
  FutureOr<void> build() {}

  /// Creates a reminder (switched on), or updates [existing]. The repository validates.
  Future<void> save({
    Reminder? existing,
    required String title,
    required ReminderTime time,
    required ReminderRepeat repeat,
    required Set<int> weekdays,
    required int? dayOfMonth,
  }) => _run(() {
    final repository = ref.read(reminderRepositoryProvider);
    return existing == null
        ? repository.create(
            ReminderDraft(
              title: title,
              time: time,
              repeat: repeat,
              weekdays: weekdays,
              dayOfMonth: dayOfMonth,
            ),
          )
        : repository.update(
            existing.copyWith(
              title: title,
              time: time,
              repeat: repeat,
              weekdays: weekdays,
              dayOfMonth: dayOfMonth,
            ),
          );
  });

  Future<void> delete(String id) => _run(() => ref.read(reminderRepositoryProvider).delete(id));

  Future<void> _run(Future<Result<Object?>> Function() action) async {
    if (state.isLoading) return;
    state = const AsyncLoading();

    final result = await action();
    if (!ref.mounted) return;

    state = switch (result) {
      Success() => const AsyncData(null),
      Failure(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }
}
