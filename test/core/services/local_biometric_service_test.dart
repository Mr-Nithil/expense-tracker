import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/services/local_biometric_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuth extends Mock implements LocalAuthentication {}

void main() {
  late _MockAuth auth;
  late LocalBiometricService service;

  setUp(() {
    auth = _MockAuth();
    service = LocalBiometricService(auth);
  });

  void stubAuthenticate(Future<bool> Function() answer) => when(
    () => auth.authenticate(
      localizedReason: any(named: 'localizedReason'),
      biometricOnly: any(named: 'biometricOnly'),
      persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
    ),
  ).thenAnswer((_) => answer());

  group('isAvailable', () {
    test('needs hardware and an enrolled biometric', () async {
      when(() => auth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => auth.getAvailableBiometrics()).thenAnswer((_) async => [BiometricType.face]);
      expect(await service.isAvailable(), isTrue);

      when(() => auth.getAvailableBiometrics()).thenAnswer((_) async => []);
      expect(await service.isAvailable(), isFalse);

      when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);
      expect(await service.isAvailable(), isFalse);
    });

    test('a platform error means unavailable', () async {
      when(() => auth.canCheckBiometrics).thenThrow(PlatformException(code: 'x'));
      expect(await service.isAvailable(), isFalse);
    });
  });

  group('authenticate', () {
    test('asks for biometrics only, with the reason', () async {
      stubAuthenticate(() async => true);

      expect(await service.authenticate(reason: 'Unlock'), BiometricOutcome.success);
      verify(
        () => auth.authenticate(
          localizedReason: 'Unlock',
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        ),
      ).called(1);
    });

    test('a rejected attempt is failed', () async {
      stubAuthenticate(() async => false);
      expect(await service.authenticate(reason: 'Unlock'), BiometricOutcome.failed);
    });

    test('maps every plugin error without throwing', () async {
      for (final (code, outcome) in [
        (LocalAuthExceptionCode.userCanceled, BiometricOutcome.cancelled),
        (LocalAuthExceptionCode.systemCanceled, BiometricOutcome.cancelled),
        (LocalAuthExceptionCode.timeout, BiometricOutcome.cancelled),
        (LocalAuthExceptionCode.temporaryLockout, BiometricOutcome.lockedOut),
        (LocalAuthExceptionCode.biometricLockout, BiometricOutcome.lockedOut),
        (LocalAuthExceptionCode.noBiometricsEnrolled, BiometricOutcome.unavailable),
        (LocalAuthExceptionCode.noBiometricHardware, BiometricOutcome.unavailable),
      ]) {
        stubAuthenticate(() => Future.error(LocalAuthException(code: code)));
        expect(await service.authenticate(reason: 'Unlock'), outcome, reason: code.name);
      }
      stubAuthenticate(() => Future.error(StateError('boom')));
      expect(await service.authenticate(reason: 'Unlock'), BiometricOutcome.unavailable);
    });
  });
}
