import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The user's profile. One per user; `id` is the user id.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({required String id, String? displayName, String? currencyCode}) = _Profile;

  const Profile._();

  /// Onboarding is complete once a currency is chosen.
  bool get isOnboarded => currencyCode != null;
}
