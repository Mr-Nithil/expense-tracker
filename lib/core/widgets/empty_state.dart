import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/message_layout.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shown when a list or screen has no content yet. Optionally offers one action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return MessageLayout(
      children: [
        Icon(icon, size: AppSizes.iconXl, color: context.colorScheme.onSurfaceVariant),
        const Gap(AppSpacing.md),
        if (title case final title?) ...[
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          const Gap(AppSpacing.sm),
        ],
        Text(
          message,
          style: context.text.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (label != null && onAction != null) ...[
          const Gap(AppSpacing.lg),
          AppButton.primary(label: label, onPressed: onAction),
        ],
      ],
    );
  }
}
