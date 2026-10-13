import 'package:freezed_annotation/freezed_annotation.dart';

part 'lock_settings.freezed.dart';

/// How long the app may stay in the background before it asks for the PIN again (decided by the
/// user 2026-10-12). A cold start always locks.
enum LockTimeout {
  immediately(Duration.zero),
  seconds30(Duration(seconds: 30)),
  minute1(Duration(minutes: 1)),
  minutes5(Duration(minutes: 5))
  ;

  const LockTimeout(this.duration);

  final Duration duration;

  static const fallback = LockTimeout.seconds30;
}

/// This device's app lock settings (device-only, never synced). No PIN = no lock.
@freezed
abstract class LockSettings with _$LockSettings {
  const factory LockSettings({
    @Default(false) bool pinEnabled,

    /// Number of digits of the PIN (the lock screen checks it once that many are entered).
    @Default(0) int pinLength,
    @Default(false) bool biometricsEnabled,
    @Default(LockTimeout.fallback) LockTimeout timeout,
  }) = _LockSettings;
}
