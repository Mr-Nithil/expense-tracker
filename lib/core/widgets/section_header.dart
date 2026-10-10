import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Section title with an optional trailing action (e.g. "See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: context.text.titleMedium)),
          if (label != null && onAction != null) AppButton.text(label: label, onPressed: onAction),
        ],
      ),
    );
  }
}
