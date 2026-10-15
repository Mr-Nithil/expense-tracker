import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';

/// Standard surface for grouped content (Sprout card): surface color, 2 px `line` border,
/// radius 20 and a solid 4 px `line` shadow. Tappable cards sink when pressed. Use instead of a raw
/// Container/Card.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    final line = context.colors.line;
    final body = Padding(padding: padding ?? const EdgeInsets.all(AppSpacing.md), child: child);
    final surface = Material(
      color: context.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: line, width: AppSizes.chunkyBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );

    if (onTap != null) {
      return ChunkyPressable(shadowColor: line, radius: radius, child: surface);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.chunkyDepth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [BoxShadow(color: line, offset: const Offset(0, AppSizes.chunkyDepth))],
        ),
        child: surface,
      ),
    );
  }
}
