import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/sync/initial_sync.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/message_layout.dart';
import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Shown while the session is restored, and on a first sign-in on this device while the initial
/// pull runs (then it says so).
///
/// Display only: the router redirect leaves this screen once the session state is known.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final syncing = ref.watch(initialSyncProvider) == InitialSyncStatus.running;
    return Scaffold(
      body: MessageLayout(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: AppSizes.iconXl,
            color: context.colorScheme.primary,
          ),
          const Gap(AppSpacing.md),
          Text(l10n.appTitle, style: context.text.headlineSmall, textAlign: TextAlign.center),
          const Gap(AppSpacing.xl),
          SproutLoader(size: AppSizes.loaderSplash, semanticsLabel: l10n.commonLoading),
          if (syncing) ...[
            const Gap(AppSpacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.authSplashSyncing,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
