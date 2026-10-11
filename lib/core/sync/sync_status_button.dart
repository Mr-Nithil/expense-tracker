import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/extensions/build_context_x.dart';
import 'package:expense_tracker/core/l10n/failure_l10n.dart';
import 'package:expense_tracker/core/sync/sync_status.dart';
import 'package:expense_tracker/core/sync/sync_trigger.dart';
import 'package:expense_tracker/core/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live sync state as an app-bar action. Tapping syncs now (and says why if it fails).
class SyncStatusButton extends ConsumerWidget {
  const SyncStatusButton({super.key});

  /// Syncs now; shows the failure in a snackbar. Shared with Settings' "Sync now".
  static Future<void> syncNow(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(syncTriggerProvider).syncNow();
    if (!context.mounted) return;
    if (result case Failure(:final failure)) context.showSnack(failure.toL10n(context));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(syncStatusProvider).value;
    if (info == null) return const SizedBox.shrink();
    return SyncStatusIndicator(
      indicator: info.indicator,
      pendingCount: info.pendingCount,
      onPressed: () => syncNow(context, ref),
    );
  }
}
