import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:expense_tracker/features/security/data/security_repository_impl.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_secure_storage.dart';

void main() {
  late FakeSecureStorage storage;
  late Session session;
  late SecurityRepositoryImpl repository;

  setUp(() {
    storage = FakeSecureStorage();
    final container = ProviderContainer();
    addTearDown(container.dispose);
    session = container.read(sessionProvider.notifier)..set(const SessionUser(userId: 'u1'));
    repository = SecurityRepositoryImpl(
      storage: storage,
      session: session,
      hasher: const PinHasher(iterations: 10),
    );
  });

  test('without anything stored there is no lock, with the default timeout', () async {
    expect((await repository.load()).valueOrNull, const LockSettings());
    expect(const LockSettings().timeout, LockTimeout.seconds30);
  });

  test('setting a PIN turns the lock on; only that PIN verifies', () async {
    final settings = (await repository.setPin('2468')).valueOrNull!;

    expect(settings.pinEnabled, isTrue);
    expect(settings.pinLength, 4);
    expect((await repository.verifyPin('2468')).valueOrNull, isTrue);
    expect((await repository.verifyPin('2469')).valueOrNull, isFalse);
    expect((await repository.load()).valueOrNull, settings);
  });

  test('the PIN is never stored in plain text', () async {
    await repository.setPin('1357');

    expect(storage.values.values.join(), isNot(contains('1357')));
  });

  test('changing the PIN replaces the old one and keeps the options', () async {
    await repository.setPin('1111');
    await repository.setBiometricsEnabled(enabled: true);
    await repository.setTimeout(LockTimeout.minutes5);

    final settings = (await repository.setPin('2222')).valueOrNull!;

    expect(settings.pinLength, 4);
    expect(settings.biometricsEnabled, isTrue);
    expect(settings.timeout, LockTimeout.minutes5);
    expect((await repository.verifyPin('1111')).valueOrNull, isFalse);
    expect((await repository.verifyPin('2222')).valueOrNull, isTrue);
  });

  test('only exactly 4 digits are accepted, without writing', () async {
    for (final pin in ['123', '12345', '123456', '12a4', '', '12 3']) {
      final failure = (await repository.setPin(pin)).failureOrNull;
      expect(failure, isA<ValidationFailure>(), reason: pin);
      expect((failure! as ValidationFailure).message, 'pinInvalid');
    }
    expect(storage.values, isEmpty);
  });

  test('removing the PIN turns the lock and biometrics off and keeps the timeout', () async {
    await repository.setPin('1234');
    await repository.setBiometricsEnabled(enabled: true);
    await repository.setTimeout(LockTimeout.minute1);

    final settings = (await repository.removePin()).valueOrNull!;

    expect(settings, const LockSettings(timeout: LockTimeout.minute1));
    expect((await repository.verifyPin('1234')).valueOrNull, isFalse);
  });

  test('biometrics need a PIN', () async {
    final failure = (await repository.setBiometricsEnabled(enabled: true)).failureOrNull;

    expect(failure, isA<ValidationFailure>());
    expect((failure! as ValidationFailure).message, 'pinRequired');
    expect(
      (await repository.setBiometricsEnabled(enabled: false)).valueOrNull?.pinEnabled,
      isFalse,
    );
  });

  test('settings left by another user are ignored and removed', () async {
    await repository.setPin('1234');
    session.set(const SessionUser(userId: 'u2'));

    expect((await repository.load()).valueOrNull, const LockSettings());
    expect((await repository.verifyPin('1234')).valueOrNull, isFalse);
    expect(storage.values, isEmpty);
  });

  test('an unreadable entry is treated as no lock', () async {
    storage.values[SecurityRepositoryImpl.storageKey] = 'not json';

    expect((await repository.load()).valueOrNull, const LockSettings());
    expect(storage.values, isEmpty);
  });

  test('fails with AuthFailure without a session', () async {
    session.set(null);

    expect((await repository.load()).failureOrNull, isA<AuthFailure>());
    expect((await repository.setPin('1234')).failureOrNull, isA<AuthFailure>());
  });

  test('a secure storage error becomes a StorageFailure', () async {
    storage.failWith = PlatformException(code: 'keystore');

    expect((await repository.load()).failureOrNull, isA<StorageFailure>());
    expect((await repository.setPin('1234')).failureOrNull, isA<StorageFailure>());
    expect((await repository.verifyPin('1234')).failureOrNull, isA<StorageFailure>());
  });
}
