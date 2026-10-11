import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/utils/currencies.dart';
import 'package:expense_tracker/core/widgets/section_header.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Profile": the signed-in user's name and email, and their currency (read-only: it is chosen
/// once at onboarding so all amounts stay in one currency). Shows nothing until the profile loads.
class SettingsProfileSection extends ConsumerWidget {
  const SettingsProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final user = ref.watch(authStateProvider).value?.user;
    final name = profile.displayName ?? user?.displayName;
    final email = user?.email;
    final currency = profile.currencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.settingsProfileLabel),
        if (name != null || email != null)
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: Text(name ?? email!),
            subtitle: name != null && email != null ? Text(email) : null,
          ),
        if (currency != null)
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.settingsCurrency),
            subtitle: Text(l10n.settingsCurrencyLocked),
            trailing: Text(
              l10n.settingsCurrencyValue(currency, Currencies.symbolOf(currency)),
              style: context.text.titleMedium,
            ),
          ),
      ],
    );
  }
}
