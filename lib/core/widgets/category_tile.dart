import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/widgets/chunky_pressable.dart';
import 'package:flutter/material.dart';

/// A 50×50 icon tile for pickers (category and goal icons; README §Core components 13).
/// Unselected: surface, 2 px `line` border and shadow. Selected: `primary` with a `primaryDeep`
/// shadow. Read out as a selectable button with [semanticLabel]. A null [onTap] disables it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final bool selected;
  final VoidCallback? onTap;

  static const size = 50.0;
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.colors;
    final radius = BorderRadius.circular(_radius);

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: ChunkyPressable(
        shadowColor: selected ? colors.primaryDeep : colors.line,
        radius: radius,
        enabled: onTap != null,
        child: Material(
          color: selected ? scheme.primary : scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: selected
                ? BorderSide.none
                : BorderSide(color: colors.line, width: AppSizes.chunkyBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                icon,
                size: AppSizes.iconMd,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
