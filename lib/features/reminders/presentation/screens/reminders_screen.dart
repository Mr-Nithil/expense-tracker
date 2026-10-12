import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/async_value_view.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminder_list_controller.dart';
import 'package:expense_tracker/features/reminders/presentation/providers/reminders_providers.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_form_sheet.dart';
import 'package:expense_tracker/features/reminders/presentation/widgets/reminder_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings → Reminders: the user's reminders with on/off switches. The + button adds one;
/// tapping one edits it. Notification permission is asked when a reminder is switched on.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.remindersTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.remindersAdd,
        onPressed: () => _open(context, ref),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: ref.watch(remindersProvider),
        onRetry: () => ref.invalidate(remindersProvider),
        data: (reminders) => reminders.isEmpty
            ? EmptyState(
                icon: Icons.notifications_none,
                title: l10n.remindersEmptyTitle,
                message: l10n.remindersEmptyMessage,
                actionLabel: l10n.remindersAdd,
                onAction: () => _open(context, ref),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: AppSizes.fabClearance),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ReminderTile(
                    key: ValueKey(reminder.id),
                    reminder: reminder,
                    onTap: () => _open(context, ref, reminder: reminder),
                    onToggle: (enabled) => _toggle(context, ref, reminder, enabled),
                  );
                },
              ),
      ),
    );
  }

  /// Adds (or edits) a reminder; a saved reminder that is on needs notification permission.
  Future<void> _open(BuildContext context, WidgetRef ref, {Reminder? reminder}) async {
    final controller = ref.read(reminderListControllerProvider.notifier);
    final saved = await ReminderFormSheet.show(context, reminder: reminder);
    if (saved != true || !(reminder?.enabled ?? true) || !context.mounted) return;
    await _ensurePermission(context, controller);
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, Reminder reminder, bool enabled) async {
    final controller = ref.read(reminderListControllerProvider.notifier);
    final result = await controller.setEnabled(reminder.id, enabled: enabled);
    if (!context.mounted) return;
    switch (result) {
      case Failure(:final failure):
        context.showSnack(failure.toL10n(context));
      case Success() when enabled:
        await _ensurePermission(context, controller);
      case Success():
        break;
    }
  }

  Future<void> _ensurePermission(BuildContext context, ReminderListController controller) async {
    final granted = await controller.ensurePermission();
    if (!granted && context.mounted) context.showSnack(context.l10n.remindersPermissionDenied);
  }
}
