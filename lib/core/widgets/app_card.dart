import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Standard surface for grouped content. Use instead of a raw Container/Card.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    return Material(
      color: context.colorScheme.surfaceContainer,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding ?? const EdgeInsets.all(AppSpacing.md), child: child),
      ),
    );
  }
}
