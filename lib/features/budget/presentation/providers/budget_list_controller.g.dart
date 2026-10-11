// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Budget tab actions. Returns the [Result] so the screen can say what happened. Kept alive
/// because it is only used from callbacks.

@ProviderFor(BudgetListController)
final budgetListControllerProvider = BudgetListControllerProvider._();

/// Budget tab actions. Returns the [Result] so the screen can say what happened. Kept alive
/// because it is only used from callbacks.
final class BudgetListControllerProvider extends $NotifierProvider<BudgetListController, void> {
  /// Budget tab actions. Returns the [Result] so the screen can say what happened. Kept alive
  /// because it is only used from callbacks.
  BudgetListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetListControllerHash();

  @$internal
  @override
  BudgetListController create() => BudgetListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$budgetListControllerHash() => r'5040ca7bcce4071c3faca54a8a5559685a22e427';

/// Budget tab actions. Returns the [Result] so the screen can say what happened. Kept alive
/// because it is only used from callbacks.

abstract class _$BudgetListController extends $Notifier<void> {
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
