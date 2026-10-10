import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/message_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shows a localized error [message] with an optional retry button.
///
/// Get the message from a failure with `failure.toL10n(context)`. Never show raw exceptions.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return MessageLayout(
      children: [
        Icon(Icons.error_outline, size: AppSizes.iconXl, color: context.colorScheme.error),
        const Gap(AppSpacing.md),
        Text(message, style: context.text.bodyLarge, textAlign: TextAlign.center),
        if (retry != null) ...[
          const Gap(AppSpacing.lg),
          AppButton.secondary(
            label: context.l10n.commonRetry,
            icon: Icons.refresh,
            onPressed: retry,
          ),
        ],
      ],
    );
  }
}
