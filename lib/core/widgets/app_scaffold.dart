import 'package:flutter/material.dart';

/// Standard page: app bar with [title], [actions] and an optional [bottom] (tabs), safe-area
/// body, optional FAB and pull-to-refresh. Use instead of a raw [Scaffold] on every screen.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onRefresh,
    this.bottom,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// When set, the body supports pull-to-refresh. The body must be scrollable.
  final Future<void> Function()? onRefresh;

  /// Shown under the app bar title, e.g. a `TabBar`.
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final refresh = onRefresh;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions, bottom: bottom),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: refresh == null ? body : RefreshIndicator(onRefresh: refresh, child: body),
      ),
    );
  }
}
