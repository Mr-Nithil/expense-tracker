// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_password_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Checks the account password of the signed-in user without signing out (PIN recovery, M7.7).
/// The auth feature's entry point for other features (ARCHITECTURE §3).

@ProviderFor(ConfirmPasswordController)
final confirmPasswordControllerProvider = ConfirmPasswordControllerProvider._();

/// Checks the account password of the signed-in user without signing out (PIN recovery, M7.7).
/// The auth feature's entry point for other features (ARCHITECTURE §3).
final class ConfirmPasswordControllerProvider
    extends $NotifierProvider<ConfirmPasswordController, void> {
  /// Checks the account password of the signed-in user without signing out (PIN recovery, M7.7).
  /// The auth feature's entry point for other features (ARCHITECTURE §3).
  ConfirmPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'confirmPasswordControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$confirmPasswordControllerHash();

  @$internal
  @override
  ConfirmPasswordController create() => ConfirmPasswordController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$confirmPasswordControllerHash() => r'5f9def5016b98d164ac35e388533511087b58b83';

/// Checks the account password of the signed-in user without signing out (PIN recovery, M7.7).
/// The auth feature's entry point for other features (ARCHITECTURE §3).

abstract class _$ConfirmPasswordController extends $Notifier<void> {
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
