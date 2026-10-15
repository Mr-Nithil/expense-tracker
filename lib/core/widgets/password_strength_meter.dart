import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/generated/app_localizations.dart';
import 'package:expense_tracker/core/theme/app_radius.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// How strong a new password looks (the Sprout prototype's rule, README §Core components 2).
///
/// Under [Validators.minPasswordLength] characters the score is 1 and [missing] says how many are
/// left. Otherwise one point each for: being long enough, mixing upper and lower case, a digit,
/// and a symbol or 12+ characters (1–4).
@immutable
class PasswordStrength {
  const PasswordStrength._(this.score, this.missing);

  factory PasswordStrength.of(String password) {
    final length = password.length;
    const min = Validators.minPasswordLength;
    if (length < min) return PasswordStrength._(1, min - length);
    var score = 1;
    if (RegExp('[a-z]').hasMatch(password) && RegExp('[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp('[^A-Za-z0-9]').hasMatch(password) || length >= 12) score++;
    return PasswordStrength._(score, 0);
  }

  static const segments = 4;

  /// 1–4 filled segments.
  final int score;

  /// Characters still missing to reach the minimum length (0 once long enough).
  final int missing;

  String label(AppLocalizations l10n) => missing > 0
      ? l10n.passwordStrengthMore(missing)
      : switch (score) {
          1 => l10n.passwordStrengthOkay,
          2 => l10n.passwordStrengthGood,
          3 => l10n.passwordStrengthGreat,
          _ => l10n.passwordStrengthStrong,
        };

  @override
  bool operator ==(Object other) =>
      other is PasswordStrength && other.score == score && other.missing == missing;

  @override
  int get hashCode => Object.hash(score, missing);
}

/// Four 6 px segments and a label under a new-password field. Nothing for an empty password.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  static const _segmentHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final colors = context.colors;
    final strength = PasswordStrength.of(password);
    // Fill (segments) and text colors: danger, then amber, then green.
    final (fill, ink) = switch (strength.score) {
      <= 1 => (context.colorScheme.error, context.colorScheme.error),
      2 => (colors.accent, colors.accentInk),
      _ => (context.colorScheme.primary, colors.link),
    };
    final label = strength.label(l10n);

    return Semantics(
      liveRegion: true,
      label: l10n.passwordStrengthLabel(label),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < PasswordStrength.segments; i++) ...[
              if (i > 0) const Gap(AppSpacing.xs),
              Expanded(
                child: Container(
                  height: _segmentHeight,
                  decoration: BoxDecoration(
                    color: i < strength.score ? fill : colors.line,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
            const Gap(AppSpacing.s10),
            Text(label, style: context.text.labelMedium?.copyWith(color: ink)),
          ],
        ),
      ),
    );
  }
}
