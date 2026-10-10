import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a snackbar when an opened email link fails, on whatever screen is visible.
///
/// Placed in `MaterialApp.builder` (see `App`), below the app's localizations and scaffold
/// messenger. Renders [child] unchanged.
class AuthLinkErrorListener extends ConsumerWidget {
  const AuthLinkErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authLinkErrorsProvider, (_, next) {
      if (next case AsyncData(:final value)) context.showSnack(value.toL10n(context));
    });
    return child;
  }
}
