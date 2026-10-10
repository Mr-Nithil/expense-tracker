import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/widgets/app_scaffold.dart';
import 'package:expense_tracker/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Placeholder for the dashboard tab. Built in M4.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.dashboardTitle,
      body: EmptyState(
        icon: Icons.space_dashboard_outlined,
        title: l10n.commonComingSoonTitle,
        message: l10n.commonComingSoonMessage,
      ),
    );
  }
}
