// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the dashboard shows, as its first day. Its own month (not shared with other tabs):
/// starts at the current month and resets when the signed-in user changes.

@ProviderFor(DashboardMonthController)
final dashboardMonthControllerProvider = DashboardMonthControllerProvider._();

/// The month the dashboard shows, as its first day. Its own month (not shared with other tabs):
/// starts at the current month and resets when the signed-in user changes.
final class DashboardMonthControllerProvider
    extends $NotifierProvider<DashboardMonthController, DateTime> {
  /// The month the dashboard shows, as its first day. Its own month (not shared with other tabs):
  /// starts at the current month and resets when the signed-in user changes.
  DashboardMonthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardMonthControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardMonthControllerHash();

  @$internal
  @override
  DashboardMonthController create() => DashboardMonthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$dashboardMonthControllerHash() => r'3721d7c96d1d7e786684eb3970810fd2c58d2382';

/// The month the dashboard shows, as its first day. Its own month (not shared with other tabs):
/// starts at the current month and resets when the signed-in user changes.

abstract class _$DashboardMonthController extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<DateTime, DateTime>, DateTime, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
