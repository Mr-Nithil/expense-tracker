import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Compact sync state for an app bar: an icon per [SyncIndicator], the pending count as a badge,
/// and the full sentence as tooltip and screen-reader label. Dumb: pass the state in (the live
/// version is `SyncStatusButton`).
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    required this.indicator,
    this.pendingCount = 0,
    this.onPressed,
  });

  final SyncIndicator indicator;
  final int pendingCount;
  final VoidCallback? onPressed;

  /// The state as a sentence, e.g. "3 changes waiting to sync".
  static String label(BuildContext context, SyncIndicator indicator, {int pendingCount = 0}) {
    final l10n = context.l10n;
    return switch (indicator) {
      SyncIndicator.synced => l10n.syncStatusSynced,
      SyncIndicator.syncing => l10n.syncStatusSyncing,
      SyncIndicator.pending => l10n.syncStatusPending(pendingCount),
      SyncIndicator.offline => l10n.syncStatusOffline,
      SyncIndicator.error => l10n.syncStatusError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final icon = switch (indicator) {
      SyncIndicator.synced => const Icon(Icons.cloud_done_outlined),
      SyncIndicator.syncing => const SizedBox.square(
        dimension: AppSizes.iconMd,
        child: Padding(
          padding: EdgeInsets.all(AppSizes.progressStroke),
          child: CircularProgressIndicator(strokeWidth: AppSizes.progressStroke),
        ),
      ),
      SyncIndicator.pending => Badge.count(
        count: pendingCount,
        child: const Icon(Icons.cloud_upload_outlined),
      ),
      SyncIndicator.offline => Icon(Icons.cloud_off_outlined, color: scheme.onSurfaceVariant),
      SyncIndicator.error => Icon(Icons.sync_problem, color: scheme.error),
    };
    return IconButton(
      tooltip: label(context, indicator, pendingCount: pendingCount),
      onPressed: onPressed,
      icon: icon,
    );
  }
}
