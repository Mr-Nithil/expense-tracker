import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The app theme preference, stored on the profile so it follows the user across devices.
/// (Flutter's `ThemeMode` stays out of the domain.)
enum AppThemeMode { system, light, dark }

/// The user's profile. One per user; `id` is the user id.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? displayName,
    String? currencyCode,
    @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// The app language code (e.g. `si`), or `null` to follow the device. Synced.
    String? locale,
  }) = _Profile;

  const Profile._();

  /// Onboarding is complete once a currency is chosen.
  bool get isOnboarded => currencyCode != null;
}
