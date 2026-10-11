import 'package:flutter/material.dart';

/// Makes non-scrolling content (e.g. an `EmptyState`) pullable for pull-to-refresh: the child
/// gets exactly the visible height (so it stays centered) inside an always-scrollable view.
class AlwaysScrollable extends StatelessWidget {
  const AlwaysScrollable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}
