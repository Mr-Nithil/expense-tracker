import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// A Sprout filter / choice pill (README §Core components 12): 2 px line border on surface;
/// selected = ink background with bg text (from the theme's `chipTheme`). No checkmark.
/// A null [onSelected] disables it. Material keeps a 48 px tap area around the pill.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return FilterChip(
      label: Text(label),
      // Material 3 chips don't switch the label color by state: bg text on the ink selection.
      labelStyle: TextStyle(
        color: selected ? context.colorScheme.surface : context.colorScheme.onSurface,
      ),
      avatar: icon == null ? null : Icon(icon),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
    );
  }
}
