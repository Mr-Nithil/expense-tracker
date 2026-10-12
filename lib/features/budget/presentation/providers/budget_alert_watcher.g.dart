// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_alert_watcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shows a budget alert when a budget of the current month crosses 80% or 100% (watched by
/// `App`). The first values after start are only a baseline, so opening the app never replays
/// old alerts; changes from any source (this device or sync) count. Silent while the user has
/// alerts off. The month is the one the app was opened in.

@ProviderFor(BudgetAlertWatcher)
final budgetAlertWatcherProvider = BudgetAlertWatcherProvider._();

/// Shows a budget alert when a budget of the current month crosses 80% or 100% (watched by
/// `App`). The first values after start are only a baseline, so opening the app never replays
/// old alerts; changes from any source (this device or sync) count. Silent while the user has
/// alerts off. The month is the one the app was opened in.
final class BudgetAlertWatcherProvider extends $NotifierProvider<BudgetAlertWatcher, void> {
  /// Shows a budget alert when a budget of the current month crosses 80% or 100% (watched by
  /// `App`). The first values after start are only a baseline, so opening the app never replays
  /// old alerts; changes from any source (this device or sync) count. Silent while the user has
  /// alerts off. The month is the one the app was opened in.
  BudgetAlertWatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertWatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertWatcherHash();

  @$internal
  @override
  BudgetAlertWatcher create() => BudgetAlertWatcher();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$budgetAlertWatcherHash() => r'a06079ef99293dacd5541762c691dfc0db43bfa2';

/// Shows a budget alert when a budget of the current month crosses 80% or 100% (watched by
/// `App`). The first values after start are only a baseline, so opening the app never replays
/// old alerts; changes from any source (this device or sync) count. Silent while the user has
/// alerts off. The month is the one the app was opened in.

abstract class _$BudgetAlertWatcher extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
