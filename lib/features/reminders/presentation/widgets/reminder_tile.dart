import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_switch.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder.dart';
import 'package:expense_tracker/features/reminders/presentation/reminder_description.dart';
import 'package:flutter/material.dart';

/// One reminder in a list: its title, schedule and an on/off switch.
class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    this.onTap,
  });

  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.notifications_outlined),
      title: Text(reminder.title),
      subtitle: Text(ReminderDescription.of(context, reminder)),
      trailing: AppSwitch(
        value: reminder.enabled,
        onChanged: onToggle,
        semanticsLabel: context.l10n.reminderSwitchLabel(reminder.title),
      ),
    );
  }
}
