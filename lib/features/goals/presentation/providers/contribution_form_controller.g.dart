// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Add-money form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure`
/// of the last attempt (`AsyncError`). The sheet closes itself once saved.

@ProviderFor(ContributionFormController)
final contributionFormControllerProvider = ContributionFormControllerProvider._();

/// Add-money form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure`
/// of the last attempt (`AsyncError`). The sheet closes itself once saved.
final class ContributionFormControllerProvider
    extends $AsyncNotifierProvider<ContributionFormController, void> {
  /// Add-money form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure`
  /// of the last attempt (`AsyncError`). The sheet closes itself once saved.
  ContributionFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributionFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributionFormControllerHash();

  @$internal
  @override
  ContributionFormController create() => ContributionFormController();
}

String _$contributionFormControllerHash() => r'92d63974746b30657a142815baf560804b40f478';

/// Add-money form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the `AppFailure`
/// of the last attempt (`AsyncError`). The sheet closes itself once saved.

abstract class _$ContributionFormController extends $AsyncNotifier<void> {
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
