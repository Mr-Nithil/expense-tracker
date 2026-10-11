// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create/edit goal form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.

@ProviderFor(GoalFormController)
final goalFormControllerProvider = GoalFormControllerProvider._();

/// Create/edit goal form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
final class GoalFormControllerProvider extends $AsyncNotifierProvider<GoalFormController, void> {
  /// Create/edit goal form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
  GoalFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalFormControllerHash();

  @$internal
  @override
  GoalFormController create() => GoalFormController();
}

String _$goalFormControllerHash() => r'85f53b5c5864a2e0cdc794bda392416d5d498c32';

/// Create/edit goal form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.

abstract class _$GoalFormController extends $AsyncNotifier<void> {
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
