// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The calendar's own month (like the dashboard's) and selected day. Starts at the current month
/// with today selected, and resets when the signed-in user changes.

@ProviderFor(CalendarController)
final calendarControllerProvider = CalendarControllerProvider._();

/// The calendar's own month (like the dashboard's) and selected day. Starts at the current month
/// with today selected, and resets when the signed-in user changes.
final class CalendarControllerProvider
    extends $NotifierProvider<CalendarController, CalendarState> {
  /// The calendar's own month (like the dashboard's) and selected day. Starts at the current month
  /// with today selected, and resets when the signed-in user changes.
  CalendarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarControllerHash();

  @$internal
  @override
  CalendarController create() => CalendarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarControllerHash() => r'a25409d6ea894b7a7a00136e5e90d17633256bbb';

/// The calendar's own month (like the dashboard's) and selected day. Starts at the current month
/// with today selected, and resets when the signed-in user changes.

abstract class _$CalendarController extends $Notifier<CalendarState> {
  CalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarState, CalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarState, CalendarState>,
              CalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
