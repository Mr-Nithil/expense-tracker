// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Non-deleted reminders by time of day. Re-subscribes for a new user.

@ProviderFor(reminders)
final remindersProvider = RemindersProvider._();

/// Non-deleted reminders by time of day. Re-subscribes for a new user.

final class RemindersProvider
    extends $FunctionalProvider<AsyncValue<List<Reminder>>, List<Reminder>, Stream<List<Reminder>>>
    with $FutureModifier<List<Reminder>>, $StreamProvider<List<Reminder>> {
  /// Non-deleted reminders by time of day. Re-subscribes for a new user.
  RemindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remindersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remindersHash();

  @$internal
  @override
  $StreamProviderElement<List<Reminder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Reminder>> create(Ref ref) {
    return reminders(ref);
  }
}

String _$remindersHash() => r'58fbea630bcf98f5b37ce5f3397dd2e349b67418';
