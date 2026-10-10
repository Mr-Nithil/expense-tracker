import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Yes/no confirmation dialog. Open it with [ConfirmDialog.show], which returns `true` only
/// when the user confirms.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
  });

  final String title;
  final String message;

  /// Defaults to `commonConfirm`.
  final String? confirmLabel;

  /// Defaults to `commonCancel`.
  final String? cancelLabel;

  /// Styles the confirm button as dangerous (delete, log out).
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confirm = confirmLabel ?? l10n.commonConfirm;
    void onConfirm() => Navigator.of(context).pop(true);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppButton.text(
          label: cancelLabel ?? l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (isDestructive)
          AppButton.danger(label: confirm, onPressed: onConfirm)
        else
          AppButton.primary(label: confirm, onPressed: onConfirm),
      ],
    );
  }
}
