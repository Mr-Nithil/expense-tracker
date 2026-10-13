import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_biometric_service.g.dart';

/// [BiometricService] over `local_auth`; the only code touching the plugin.
class LocalBiometricService implements BiometricService {
  LocalBiometricService([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics && (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on Object catch (error, stackTrace) {
      AppLogger.error('biometrics: availability check failed', error, stackTrace);
      return false;
    }
  }

  @override
  Future<BiometricOutcome> authenticate({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricOutcome.success : BiometricOutcome.failed;
    } on LocalAuthException catch (error) {
      AppLogger.info('biometrics: ${error.code.name}');
      return outcomeOf(error.code);
    } on Object catch (error, stackTrace) {
      AppLogger.error('biometrics: authenticate failed', error, stackTrace);
      return BiometricOutcome.unavailable;
    }
  }

  static BiometricOutcome outcomeOf(LocalAuthExceptionCode code) => switch (code) {
    LocalAuthExceptionCode.userCanceled ||
    LocalAuthExceptionCode.systemCanceled ||
    LocalAuthExceptionCode.timeout ||
    LocalAuthExceptionCode.userRequestedFallback ||
    LocalAuthExceptionCode.authInProgress => BiometricOutcome.cancelled,
    LocalAuthExceptionCode.temporaryLockout ||
    LocalAuthExceptionCode.biometricLockout => BiometricOutcome.lockedOut,
    _ => BiometricOutcome.unavailable,
  };
}

@Riverpod(keepAlive: true)
BiometricService biometricService(Ref ref) => LocalBiometricService();
