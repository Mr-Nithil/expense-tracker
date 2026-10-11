import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;

/// Swipe left to delete, with the same action available to screen readers ("Delete").
/// Pair it with `context.showUndoSnack`.
///
/// The caller must remove the item from the tree as soon as [onDelete] runs (e.g. hide it
/// locally until the data updates); a dismissed item left in the tree is an error. When the item
/// is shown again (failed delete, undo), give it a new [itemKey] so a fresh Dismissible is built.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.itemKey,
    required this.onDelete,
    required this.child,
  });

  /// Unique per item, e.g. `ValueKey(id)`.
  final Key itemKey;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: ColoredBox(
        color: scheme.errorContainer,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
          ),
        ),
      ),
      child: Semantics(
        customSemanticsActions: {CustomSemanticsAction(label: context.l10n.commonDelete): onDelete},
        child: child,
      ),
    );
  }
}
