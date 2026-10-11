// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Set/edit budget form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or removed.

@ProviderFor(BudgetFormController)
final budgetFormControllerProvider = BudgetFormControllerProvider._();

/// Set/edit budget form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or removed.
final class BudgetFormControllerProvider
    extends $AsyncNotifierProvider<BudgetFormController, void> {
  /// Set/edit budget form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or removed.
  BudgetFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetFormControllerHash();

  @$internal
  @override
  BudgetFormController create() => BudgetFormController();
}

String _$budgetFormControllerHash() => r'e1944b4e74f2523bb1918190a0c76716cdaec3e5';

/// Set/edit budget form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or removed.

abstract class _$BudgetFormController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
