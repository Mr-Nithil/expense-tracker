// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_alerts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether this device shows budget alerts. Off until the user turns them on.

@ProviderFor(budgetAlertsEnabled)
final budgetAlertsEnabledProvider = BudgetAlertsEnabledProvider._();

/// Whether this device shows budget alerts. Off until the user turns them on.

final class BudgetAlertsEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether this device shows budget alerts. Off until the user turns them on.
  BudgetAlertsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertsEnabledHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return budgetAlertsEnabled(ref);
  }
}

String _$budgetAlertsEnabledHash() => r'4e0dfbf88d5a4b2098eddec536b6a7d15713706f';

/// The budget alerts switch. Kept alive because it is only used from callbacks.

@ProviderFor(BudgetAlertsController)
final budgetAlertsControllerProvider = BudgetAlertsControllerProvider._();

/// The budget alerts switch. Kept alive because it is only used from callbacks.
final class BudgetAlertsControllerProvider extends $NotifierProvider<BudgetAlertsController, void> {
  /// The budget alerts switch. Kept alive because it is only used from callbacks.
  BudgetAlertsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetAlertsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetAlertsControllerHash();

  @$internal
  @override
  BudgetAlertsController create() => BudgetAlertsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$budgetAlertsControllerHash() => r'4056e77568a047c3d45f1c08f11a37bbb8a76670';

/// The budget alerts switch. Kept alive because it is only used from callbacks.

abstract class _$BudgetAlertsController extends $Notifier<void> {
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
