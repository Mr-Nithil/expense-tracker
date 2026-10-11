import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/categories/domain/services/category_palette.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/selectable_circle.dart';
import 'package:flutter/material.dart';

/// Grid of the category palette colors.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CategoryPalette.colors;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (index, color) in colors.indexed)
          SelectableCircle(
            selected: color == selected,
            semanticLabel: context.l10n.categoryFormColorOption(index + 1, colors.length),
            onTap: onChanged == null ? null : () => onChanged!(color),
            child: Container(
              width: AppSizes.avatarMd,
              height: AppSizes.avatarMd,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(color)),
            ),
          ),
      ],
    );
  }
}
