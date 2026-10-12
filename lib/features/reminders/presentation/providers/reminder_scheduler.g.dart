// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps this device's reminder notifications in line with its reminders (watched by `App`).
///
/// Whenever the reminders change (edited here, pulled by sync, signed in or out) it cancels the
/// pending reminder notifications and schedules [ReminderNotificationPlan] again. Notifications
/// never sync: every device derives its own. Other notifications (budget alerts) are left alone.

@ProviderFor(ReminderScheduler)
final reminderSchedulerProvider = ReminderSchedulerProvider._();

/// Keeps this device's reminder notifications in line with its reminders (watched by `App`).
///
/// Whenever the reminders change (edited here, pulled by sync, signed in or out) it cancels the
/// pending reminder notifications and schedules [ReminderNotificationPlan] again. Notifications
/// never sync: every device derives its own. Other notifications (budget alerts) are left alone.
final class ReminderSchedulerProvider extends $NotifierProvider<ReminderScheduler, void> {
  /// Keeps this device's reminder notifications in line with its reminders (watched by `App`).
  ///
  /// Whenever the reminders change (edited here, pulled by sync, signed in or out) it cancels the
  /// pending reminder notifications and schedules [ReminderNotificationPlan] again. Notifications
  /// never sync: every device derives its own. Other notifications (budget alerts) are left alone.
  ReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSchedulerHash();

  @$internal
  @override
  ReminderScheduler create() => ReminderScheduler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reminderSchedulerHash() => r'5fec92676ea5853bf0071be5459549f217dfcd47';

/// Keeps this device's reminder notifications in line with its reminders (watched by `App`).
///
/// Whenever the reminders change (edited here, pulled by sync, signed in or out) it cancels the
/// pending reminder notifications and schedules [ReminderNotificationPlan] again. Notifications
/// never sync: every device derives its own. Other notifications (budget alerts) are left alone.

abstract class _$ReminderScheduler extends $Notifier<void> {
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
