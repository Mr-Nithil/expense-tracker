import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/theme/app_durations.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

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

  /// Shows [message] in a snackbar, replacing any snackbar that is currently visible.
  ///
  /// With [actionLabel] and [onAction], the snackbar gets one action button (e.g. "Resend").
  void showSnack(String message, {String? actionLabel, VoidCallback? onAction}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppDurations.snackBar,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}
