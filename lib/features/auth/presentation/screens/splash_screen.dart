import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/message_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shown while the session is restored (`AuthStatus.unknown`).
///
/// Display only: the router redirect leaves this screen once the session state is known.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          SizedBox.square(
            dimension: AppSizes.progressSm,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.progressStroke,
              semanticsLabel: l10n.commonLoading,
            ),
          ),
        ],
      ),
    );
  }
}
