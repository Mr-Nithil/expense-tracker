import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/router/auth_status.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/auth/data/auth_repository_provider.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/entities/auth_snapshot.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

/// The auth state: the signed-in user (or `null`) and whether a password reset is in progress.
///
/// Starts with the session restored from local storage (no network needed, ARCHITECTURE §10),
/// then follows sign-in, sign-out and token refresh events.
///
/// Never retried: the Supabase stream keeps running after an error (e.g. a refresh failing
/// offline), so rebuilding would only re-subscribe for nothing.
@Riverpod(keepAlive: true, retry: _noRetry)
Stream<AuthSnapshot> authState(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield AuthSnapshot(user: repository.currentUser);
  yield* repository.authStateChanges();
}

/// Problems with opened email links (expired, used, other device), for the app-wide
/// `AuthLinkErrorListener`. Supabase replays earlier errors to new subscribers, so a link that
/// failed during startup is still reported.
@Riverpod(keepAlive: true)
Stream<AuthFailure> authLinkErrors(Ref ref) => ref.watch(authRepositoryProvider).authLinkErrors();

/// Drives core's [Session] and the router's [AuthStatusController] from [authStateProvider].
///
/// Must be kept alive by the app (see `App`). Stream errors keep the last known status, so a
/// failed token refresh while offline does not sign the user out.
///
/// On every sign-in the local data is claimed for that user first (`LocalDataRepository`); the
/// status stays `unknown` (splash) until then, so no screen shows another user's data.
@Riverpod(keepAlive: true)
void authStatusBinding(Ref ref) {
  // The user whose ownership of the local data was already checked in this sign-in.
  String? verifiedOwner;

  void apply(AuthSnapshot snapshot) {
    final user = snapshot.user;
    final status = ref.read(authStatusControllerProvider.notifier);
    // Session first, so whatever the route change opens can already read the user id.
    ref
        .read(sessionProvider.notifier)
        .set(user == null ? null : SessionUser(userId: user.id, displayName: user.displayName));

    if (user == null) {
      verifiedOwner = null;
      status.set(AuthStatus.signedOut);
      return;
    }

    if (verifiedOwner != user.id) {
      status.set(AuthStatus.unknown);
      final userId = user.id;
      ref.read(localDataRepositoryProvider).claimFor(userId).then((result) {
        if (result case Failure(:final failure)) {
          // Better to let the user in than to hang on splash; DAOs still filter by user id.
          AppLogger.warning('claiming local data failed: ${failure.message}');
        }
        if (!ref.mounted) return;
        verifiedOwner = userId;
        // Apply the latest state: the user may have signed out while claiming.
        final latest = ref.read(authStateProvider).value;
        if (latest != null) apply(latest);
      });
      return;
    }

    status.set(snapshot.isPasswordRecovery ? AuthStatus.passwordRecovery : AuthStatus.signedIn);
  }

  ref.listen(authStateProvider, (_, next) {
    if (next.hasError) {
      AppLogger.warning('authState stream error, keeping status', next.error, next.stackTrace);
    }
    if (next.hasValue) apply(next.requireValue);
  }, fireImmediately: true);
}

Duration? _noRetry(int retryCount, Object error) => null;
