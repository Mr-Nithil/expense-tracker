import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// The signed-in user. Supabase's `User` never leaves the data layer.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({required String id, required String email, String? displayName}) =
      _AuthUser;
}
