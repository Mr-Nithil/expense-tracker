// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Add/edit category form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or
/// archived.

@ProviderFor(CategoryFormController)
final categoryFormControllerProvider = CategoryFormControllerProvider._();

/// Add/edit category form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or
/// archived.
final class CategoryFormControllerProvider
    extends $AsyncNotifierProvider<CategoryFormController, void> {
  /// Add/edit category form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or
  /// archived.
  CategoryFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryFormControllerHash();

  @$internal
  @override
  CategoryFormController create() => CategoryFormController();
}

String _$categoryFormControllerHash() => r'51171a3740dc2e0914db3c36aa36ce6f6131254f';

/// Add/edit category form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved or
/// archived.

abstract class _$CategoryFormController extends $AsyncNotifier<void> {
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
