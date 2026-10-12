import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/router/routes.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/sync/sync_status_button.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/theme_mode_controller.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:expense_tracker/features/auth/presentation/providers/logout_controller.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_alerts_controller.dart';
import 'package:expense_tracker/features/profile/presentation/providers/theme_mode_setter.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/settings_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Settings tab: profile (name, email, read-only currency), theme mode, data management
/// (categories), sync status and logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = ref.read(logoutControllerProvider.notifier);

    // If the count can't be read, fall back to the plain confirmation.
    final pending = (await controller.pendingChanges()).valueOrNull ?? 0;
    if (!context.mounted) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.settingsLogoutConfirmTitle,
      message: pending > 0
          ? l10n.settingsLogoutPendingMessage(pending)
          : l10n.settingsLogoutConfirmMessage,
      confirmLabel: pending > 0 ? l10n.settingsLogoutAnyway : l10n.settingsLogout,
      isDestructive: true,
    );
    if (confirmed) await controller.logout();
  }

  /// Saved on the profile (synced); the picker follows `themeModeControllerProvider`.
  Future<void> _setThemeMode(BuildContext context, WidgetRef ref, ThemeMode mode) async {
    final result = await ref.read(themeModeSetterProvider.notifier).setThemeMode(mode);
    if (!context.mounted) return;
    if (result case Failure(:final failure)) context.showSnack(failure.toL10n(context));
  }

  /// Saves the budget alerts choice; turning it on asks for notification permission.
  Future<void> _setBudgetAlerts(BuildContext context, WidgetRef ref, bool enabled) async {
    final l10n = context.l10n;
    final result = await ref
        .read(budgetAlertsControllerProvider.notifier)
        .setEnabled(enabled: enabled);
    if (!context.mounted) return;
    if (result.saved case Failure(:final failure)) {
      context.showSnack(failure.toL10n(context));
    } else if (!result.permitted) {
      context.showSnack(l10n.settingsBudgetAlertsPermissionDenied);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeControllerProvider).value ?? ThemeMode.system;

    ref.listen(logoutControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        context.showSnack(errorMessageOf(error, context));
      }
    });
    final isLoggingOut = ref.watch(logoutControllerProvider).isLoading;

    return AppScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SettingsProfileSection(),
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.settingsThemeLabel),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.settingsThemeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.settingsThemeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.settingsThemeDark),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => _setThemeMode(context, ref, selection.first),
          ),
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.settingsNotificationsLabel),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.settingsBudgetAlerts),
            subtitle: Text(l10n.settingsBudgetAlertsDescription),
            value: ref.watch(budgetAlertsEnabledProvider).value ?? false,
            onChanged: (enabled) => _setBudgetAlerts(context, ref, enabled),
          ),
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.settingsManageLabel),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l10n.categoriesTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(Routes.categories),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.remindersTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(Routes.reminders),
          ),
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.settingsSyncLabel),
          if (ref.watch(syncStatusProvider).value case final sync?)
            ListTile(
              leading: const SyncStatusButton(),
              title: Text(
                SyncStatusIndicator.label(context, sync.indicator, pendingCount: sync.pendingCount),
              ),
              trailing: AppButton.text(
                label: l10n.syncNow,
                onPressed: () => SyncStatusButton.syncNow(context, ref),
              ),
            ),
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.settingsAccountLabel),
          AppButton.danger(
            label: l10n.settingsLogout,
            icon: Icons.logout,
            isLoading: isLoggingOut,
            isExpanded: true,
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
