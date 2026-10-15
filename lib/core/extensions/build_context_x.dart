import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Shortcuts for theme, localization and locale-aware formatting.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Semantic colors (income, expense, warning, success).
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  TextTheme get text => Theme.of(this).textTheme;

  /// The current locale as an intl tag (e.g. `en_US`), for money and date formatting.
  String get localeTag => Localizations.localeOf(this).toString();

  String formatDate(DateTime date) => AppDateUtils.formatShortDate(date, localeTag);

  /// A whole number in the current locale's digits and grouping (e.g. `1,234`). Never use
  /// `toString()` for numbers shown to the user.
  String formatNumber(int value) => NumberFormat.decimalPattern(localeTag).format(value);

  /// Shows [message] as a toast (Sprout style, 3 s), replacing any toast that is visible.
  ///
  /// With [actionLabel] and [onAction], the toast gets one action button (e.g. "Resend"). [icon] is
  /// the leading filled icon (decorative; a check by default).
  void showSnack(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData icon = Icons.check_circle_rounded,
  }) {
    final colors = Theme.of(this).snackBarTheme;
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              ExcludeSemantics(
                child: Icon(icon, color: colors.contentTextStyle?.color, size: AppSizes.iconMd),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(child: Text(message)),
            ],
          ),
          duration: AppDurations.toast,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }

  /// Shows [message] with an "Undo" action that calls [onUndo] (e.g. after a delete).
  void showUndoSnack(String message, {required VoidCallback onUndo}) =>
      showSnack(message, actionLabel: l10n.commonUndo, onAction: onUndo, icon: Icons.undo_rounded);
}
