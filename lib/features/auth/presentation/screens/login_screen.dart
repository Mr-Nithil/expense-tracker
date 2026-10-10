import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Placeholder login screen. Built in M1.4.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.authLoginTitle,
      body: EmptyState(
        icon: Icons.lock_outline,
        title: l10n.commonComingSoonTitle,
        message: l10n.commonComingSoonMessage,
      ),
    );
  }
}
