// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Add/edit transaction form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.

@ProviderFor(TransactionFormController)
final transactionFormControllerProvider = TransactionFormControllerProvider._();

/// Add/edit transaction form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
final class TransactionFormControllerProvider
    extends $AsyncNotifierProvider<TransactionFormController, void> {
  /// Add/edit transaction form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.
  TransactionFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionFormControllerHash();

  @$internal
  @override
  TransactionFormController create() => TransactionFormController();
}

String _$transactionFormControllerHash() => r'18705ccb00bcae3cc609c9b0cde27f3748667f86';

/// Add/edit transaction form state: idle/saved (`AsyncData`), saving (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once saved.

abstract class _$TransactionFormController extends $AsyncNotifier<void> {
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
