import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/sprout_loader.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Centered loading indicator (the page-size `SproutLoader`) with an optional [message].
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SproutLoader(size: AppSizes.loaderPage, semanticsLabel: context.l10n.commonLoading),
          if (message case final message?) ...[
            const Gap(AppSpacing.md),
            Text(message, style: context.text.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
