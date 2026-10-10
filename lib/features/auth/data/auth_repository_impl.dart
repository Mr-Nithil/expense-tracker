import 'dart:async';
import 'dart:io';

import 'package:expense_tracker/core/config/deep_links.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/utils/validators.dart';
import 'package:expense_tracker/features/auth/domain/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_user.dart';
import 'package:expense_tracker/features/auth/domain/entities/sign_up_outcome.dart';
// Supabase has its own `AuthUser`; ours is the domain entity.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

/// [AuthRepository] backed by Supabase Auth.
///
/// Never logs emails or passwords: only the operation name and Supabase error codes.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth);

  final GoTrueClient _auth;

  /// User-metadata key read by the `handle_new_user` trigger (0001_init.sql).
  static const displayNameMetadataKey = 'display_name';

  @override
  Stream<AuthSnapshot> authStateChanges() {
    // Sticky per subscription: a token refresh during recovery must not let the user in.
    var recovery = false;
    return _auth.onAuthStateChange.map((state) {
      final user = state.session?.user.toAuthUser();
      recovery = switch (state.event) {
        AuthChangeEvent.passwordRecovery => true,
        AuthChangeEvent.userUpdated ||
        AuthChangeEvent.signedIn ||
        AuthChangeEvent.signedOut => false,
        _ => recovery,
      };
      if (user == null) recovery = false;
      return AuthSnapshot(user: user, isPasswordRecovery: recovery);
    }).distinct();
  }

  @override
  Stream<AuthFailure> authLinkErrors() => _auth.onAuthStateChange.transform(
    StreamTransformer<AuthState, AuthFailure>.fromHandlers(
      handleData: (_, _) {},
      handleError: (error, _, sink) {
        final failure = authLinkFailureOf(error);
        if (failure != null) sink.add(failure);
      },
    ),
  );

  @override
  AuthUser? get currentUser => _auth.currentUser?.toAuthUser();

  @override
  Future<Result<AuthUser>> signIn({required String email, required String password}) {
    final invalid =
        _invalid('email', Validators.email(email)) ??
        _invalid('password', Validators.required(password));
    if (invalid != null) return Future.value(Result.failure(invalid));

    return _guard('signIn', () async {
      final response = await _auth.signInWithPassword(email: email.trim(), password: password);
      final user = response.user ?? response.session?.user;
      if (user == null) {
        return const Result.failure(AuthFailure('signIn returned no user'));
      }
      return Result.success(user.toAuthUser());
    });
  }

  @override
  Future<Result<SignUpOutcome>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    final name = displayName?.trim();
    final invalid =
        _invalid('email', Validators.email(email)) ??
        _invalid('password', Validators.password(password)) ??
        (name != null && name.length > Validators.maxDisplayNameLength
            ? const ValidationFailure('displayName too long', field: 'displayName')
            : null);
    if (invalid != null) return Future.value(Result.failure(invalid));

    return _guard('signUp', () async {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {if (name != null && name.isNotEmpty) displayNameMetadataKey: name},
        emailRedirectTo: DeepLinks.authCallback,
      );
      return Result.success(
        response.session != null ? SignUpOutcome.signedIn : SignUpOutcome.emailConfirmationRequired,
      );
    });
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
    } catch (error, stackTrace) {
      // Supabase clears the local session before the server call, so the user is signed out
      // locally even when this fails (e.g. offline).
      AppLogger.warning('signOut: server call failed, local session cleared', error, stackTrace);
    }
    return Result.ok;
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) {
    final invalid = _invalid('email', Validators.email(email));
    if (invalid != null) return Future.value(Result.failure(invalid));

    return _guard('sendPasswordReset', () async {
      await _auth.resetPasswordForEmail(email.trim(), redirectTo: DeepLinks.authCallback);
      return Result.ok;
    });
  }

  @override
  Future<Result<void>> resendConfirmation({required String email}) {
    final invalid = _invalid('email', Validators.email(email));
    if (invalid != null) return Future.value(Result.failure(invalid));

    return _guard('resendConfirmation', () async {
      await _auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: DeepLinks.authCallback,
      );
      return Result.ok;
    });
  }

  @override
  Future<Result<void>> updatePassword({required String newPassword}) {
    final invalid = _invalid('password', Validators.password(newPassword));
    if (invalid != null) return Future.value(Result.failure(invalid));

    return _guard('updatePassword', () async {
      await _auth.updateUser(UserAttributes(password: newPassword));
      return Result.ok;
    });
  }

  static ValidationFailure? _invalid(String field, ValidationError? error) =>
      error == null ? null : ValidationFailure(error.name, field: field);

  /// Runs [body] and converts every exception into a failure. Never throws.
  Future<Result<T>> _guard<T>(String operation, Future<Result<T>> Function() body) async {
    try {
      return await body();
    } on AuthRetryableFetchException catch (error) {
      return Result.failure(NetworkFailure('$operation: ${error.statusCode ?? 'no response'}'));
    } on SocketException catch (_) {
      return Result.failure(NetworkFailure('$operation: socket error'));
    } on TimeoutException catch (_) {
      return Result.failure(NetworkFailure('$operation: timeout'));
    } on AuthException catch (error) {
      final reason = authFailureReasonOf(error);
      AppLogger.info('$operation failed: code=${error.code} status=${error.statusCode}');
      return Result.failure(
        AuthFailure('$operation: ${error.code ?? reason.name}', reason: reason),
      );
    } catch (error, stackTrace) {
      AppLogger.error('$operation: unexpected error', error, stackTrace);
      return Result.failure(UnexpectedFailure(operation, cause: error));
    }
  }
}

/// Maps an auth stream error to a link failure, or `null` when it is not about an email link.
/// Visible for testing.
///
/// URL errors (`#error=access_denied&error_code=otp_expired`) arrive with `code` = `error` and
/// `statusCode` = `error_code`, so both fields are checked.
AuthFailure? authLinkFailureOf(Object error) {
  if (error is! AuthException || error is AuthRetryableFetchException) return null;

  const expiredCodes = {'otp_expired', 'flow_state_expired'};
  const invalidCodes = {'flow_state_not_found', 'bad_code_verifier', 'access_denied'};
  final codes = {error.code, error.statusCode};

  final reason = switch (error) {
    _ when codes.any(expiredCodes.contains) => AuthFailureReason.linkExpired,
    // No code: thrown when the PKCE verifier is missing (link opened on another device).
    AuthPKCEGrantCodeExchangeError() => AuthFailureReason.linkInvalid,
    _ when codes.any(invalidCodes.contains) || error.message.contains('Code verifier') =>
      AuthFailureReason.linkInvalid,
    _ => null,
  };
  if (reason == null) return null;

  AppLogger.info('auth link failed: code=${error.code} status=${error.statusCode}');
  return AuthFailure('link: ${error.code ?? error.statusCode}', reason: reason);
}

/// Maps a Supabase auth error to a domain reason. Visible for testing.
AuthFailureReason authFailureReasonOf(AuthException error) {
  if (error is AuthWeakPasswordException) return AuthFailureReason.weakPassword;
  return switch (error.code) {
    'invalid_credentials' => AuthFailureReason.invalidCredentials,
    'email_exists' || 'user_already_exists' => AuthFailureReason.emailAlreadyRegistered,
    'weak_password' => AuthFailureReason.weakPassword,
    'email_not_confirmed' => AuthFailureReason.emailNotConfirmed,
    'same_password' => AuthFailureReason.samePassword,
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' ||
    'over_sms_send_rate_limit' => AuthFailureReason.rateLimited,
    _ when error.statusCode == '429' => AuthFailureReason.rateLimited,
    _ => AuthFailureReason.unknown,
  };
}

extension on User {
  AuthUser toAuthUser() => AuthUser(
    id: id,
    email: email ?? '',
    displayName: userMetadata?[AuthRepositoryImpl.displayNameMetadataKey] as String?,
  );
}
