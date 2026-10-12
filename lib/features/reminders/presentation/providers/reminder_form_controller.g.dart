// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Add/edit reminder form state: idle/done (`AsyncData`), working (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once done.

@ProviderFor(ReminderFormController)
final reminderFormControllerProvider = ReminderFormControllerProvider._();

/// Add/edit reminder form state: idle/done (`AsyncData`), working (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once done.
final class ReminderFormControllerProvider
    extends $AsyncNotifierProvider<ReminderFormController, void> {
  /// Add/edit reminder form state: idle/done (`AsyncData`), working (`AsyncLoading`) or the
  /// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once done.
  ReminderFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderFormControllerHash();

  @$internal
  @override
  ReminderFormController create() => ReminderFormController();
}

String _$reminderFormControllerHash() => r'dd5480c63aae3c11c1cc214ae772f3271153bbc8';

/// Add/edit reminder form state: idle/done (`AsyncData`), working (`AsyncLoading`) or the
/// `AppFailure` of the last attempt (`AsyncError`). The sheet closes itself once done.

abstract class _$ReminderFormController extends $AsyncNotifier<void> {
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
