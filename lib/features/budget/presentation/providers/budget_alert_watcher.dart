import 'dart:async';

import 'package:expense_tracker/core/l10n/l10n_lookup.dart';
import 'package:expense_tracker/core/l10n/locale_controller.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/local_notification_service.dart';
import 'package:expense_tracker/core/services/notification_payload.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/utils/clock.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_overview.dart';
import 'package:expense_tracker/features/budget/domain/entities/budget_status.dart';
import 'package:expense_tracker/features/budget/domain/services/budget_alert_check.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_alerts_controller.dart';
import 'package:expense_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_providers.dart';
import 'package:expense_tracker/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_alert_watcher.g.dart';

/// Shows a budget alert when a budget of the current month crosses 80% or 100% (watched by
/// `App`). The first values after start are only a baseline, so opening the app never replays
/// old alerts; changes from any source (this device or sync) count. Silent while the user has
/// alerts off. The month is the one the app was opened in.
@Riverpod(keepAlive: true)
class BudgetAlertWatcher extends _$BudgetAlertWatcher {
  Map<String, BudgetStatus>? _previous;

  @override
  void build() {
    final month = AppDateUtils.monthStart(ref.read(clockProvider).now());
    ref.listen(budgetOverviewProvider(month), (_, next) {
      if (next case AsyncData(:final value)) unawaited(_check(month, value));
    }, fireImmediately: true);
  }

  Future<void> _check(DateTime month, BudgetOverview overview) async {
    final alerts = BudgetAlertCheck.crossings(_previous, overview);
    _previous = BudgetAlertCheck.statuses(overview);
    if (alerts.isEmpty) return;
    try {
      if (!await _once(budgetAlertsEnabledProvider)) return;
      final currency = await _once(currencyCodeProvider);
      final l10n = appLocalizationsFor(
        ref.read(localeControllerProvider).value,
        device: PlatformDispatcher.instance.locale,
      );
      final locale = l10n.localeName;
      for (final alert in alerts) {
        final budget = alert.progress.budget;
        final categoryId = budget.categoryId;
        final name = categoryId == null
            ? l10n.budgetOverallTitle
            : (await _once(categoryByIdProvider(categoryId)))?.name ?? l10n.categoryUnknown;
        await ref
            .read(notificationServiceProvider)
            .show(
              id: BudgetAlertIds.of(budget.id),
              title: alert.status == BudgetStatus.exceeded
                  ? l10n.budgetAlertExceededTitle(name)
                  : l10n.budgetAlertWarningTitle(name, alert.progress.percentUsed),
              body: l10n.budgetAlertBody(
                alert.progress.spent.format(locale: locale, currencyCode: currency),
                budget.limit.format(locale: locale, currencyCode: currency),
              ),
              channel: NotificationChannel.budgetAlerts,
              payload: BudgetPayload(month).encode(),
            );
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error('budget alerts: showing failed', error, stackTrace);
    }
  }

  /// The first value of an async provider, through a short-lived listener: a plain `read` of an
  /// auto-dispose provider can pause or drop it before it delivers (Riverpod 3).
  Future<T> _once<T>(ProviderListenable<AsyncValue<T>> provider) async {
    final completer = Completer<T>();
    final subscription = ref.listen(provider, (_, next) {
      if (completer.isCompleted) return;
      switch (next) {
        case AsyncData(:final value):
          completer.complete(value);
        case AsyncError(:final error, :final stackTrace):
          completer.completeError(error, stackTrace);
        default:
          break;
      }
    }, fireImmediately: true);
    try {
      return await completer.future;
    } finally {
      subscription.close();
    }
  }
}
