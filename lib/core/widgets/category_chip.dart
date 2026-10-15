import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// A compact category pill: icon + name. Use for a transaction's category, the category picker
/// and filters.
///
/// - [selected] with [onTap]: selectable (pickers, filters).
/// - [onTap] alone: tappable. Neither: display only.
/// - [isArchived]: muted with an archive marker; still shown on old transactions.
/// - [CategoryChip.unknown]: the category isn't on this device (e.g. not synced yet).
///
/// Takes plain values because core never imports features; features map a `Category` to it.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required String this.label,
    required this.iconKey,
    required int this.color,
    this.isArchived = false,
    this.selected = false,
    this.onTap,
  });

  /// For a category that can't be found: "Unknown category" with the fallback icon.
  const CategoryChip.unknown({super.key, this.selected = false, this.onTap})
    : label = null,
      iconKey = '',
      color = null,
      isArchived = false;

  /// `null` only for [CategoryChip.unknown].
  final String? label;
  final String iconKey;

  /// ARGB value; `null` only for [CategoryChip.unknown] (uses the theme's outline color).
  final int? color;
  final bool isArchived;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = label ?? l10n.categoryUnknown;
    // Material 3 chips don't switch the label color by state: bg text on the ink selection.
    final muted = selected ? context.colorScheme.surface : context.colorScheme.onSurfaceVariant;
    final ink = selected ? context.colorScheme.surface : context.colorScheme.onSurface;
    final onTap = this.onTap;

    final chip = RawChip(
      avatar: CategoryIcon(
        iconKey: iconKey,
        color: color ?? context.colorScheme.outline.toARGB32(),
        size: AppSizes.iconMd,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: isArchived ? muted : ink),
            ),
          ),
          if (isArchived) ...[
            const Gap(AppSpacing.xs),
            Icon(Icons.archive_outlined, size: AppSizes.iconSm, color: muted),
          ],
        ],
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: onTap == null ? null : (_) => onTap(),
    );

    final semanticLabel = isArchived ? l10n.categoryChipArchived(name) : name;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      button: onTap != null,
      selected: onTap != null ? selected : null,
      onTap: onTap,
      child: isArchived ? Tooltip(message: semanticLabel, child: chip) : chip,
    );
  }
}
