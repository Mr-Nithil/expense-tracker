import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';

/// One category in a list: icon and name. Archived categories (still shown on their
/// transactions) are muted and labelled; a missing one (e.g. not synced yet) shows as unknown.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, this.onTap});

  /// `null` when the category isn't on this device.
  final Category? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = this.category;
    if (category == null) {
      return ListTile(
        leading: CategoryIcon(iconKey: '', color: context.colorScheme.outline.toARGB32()),
        title: Text(l10n.categoryUnknown),
        onTap: onTap,
      );
    }

    final muted = context.colorScheme.onSurfaceVariant;
    return ListTile(
      leading: CategoryIcon(iconKey: category.icon, color: category.color),
      title: Text(
        category.name,
        style: category.isArchived ? TextStyle(color: muted) : null,
      ),
      subtitle: category.isArchived ? Text(l10n.categoryArchivedLabel) : null,
      onTap: onTap,
    );
  }
}
