// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// List actions: delete (soft) and its undo. Returns the [Result] so the list can show either
/// an Undo snackbar or the error. Kept alive because it is only used from callbacks.

@ProviderFor(TransactionListController)
final transactionListControllerProvider = TransactionListControllerProvider._();

/// List actions: delete (soft) and its undo. Returns the [Result] so the list can show either
/// an Undo snackbar or the error. Kept alive because it is only used from callbacks.
final class TransactionListControllerProvider
    extends $NotifierProvider<TransactionListController, void> {
  /// List actions: delete (soft) and its undo. Returns the [Result] so the list can show either
  /// an Undo snackbar or the error. Kept alive because it is only used from callbacks.
  TransactionListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListControllerHash();

  @$internal
  @override
  TransactionListController create() => TransactionListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$transactionListControllerHash() => r'7ff86bf9819446540418795d5c7f47841457f818';

/// List actions: delete (soft) and its undo. Returns the [Result] so the list can show either
/// an Undo snackbar or the error. Kept alive because it is only used from callbacks.

abstract class _$TransactionListController extends $Notifier<void> {
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
