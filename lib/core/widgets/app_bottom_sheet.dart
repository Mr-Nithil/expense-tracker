import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Standard modal bottom sheet: drag handle (from the theme), optional [title], and padding
/// that keeps content above the keyboard. Open it with [AppBottomSheet.show].
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  /// Shows [child] in a sheet. Results go through repositories, not the returned value
  /// (ARCHITECTURE §9). The future completes when the sheet closes.
  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title}) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => AppBottomSheet(title: title, child: child),
      );

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title case final title?) ...[
              Text(title, style: context.text.titleLarge),
              const Gap(AppSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
