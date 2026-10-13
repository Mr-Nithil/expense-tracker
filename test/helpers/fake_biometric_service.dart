import 'package:expense_tracker/core/services/biometric_service.dart';
import 'package:expense_tracker/core/services/local_biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:expense_tracker/features/security/data/security_repository_impl.dart';
import 'package:expense_tracker/features/security/data/security_repository_provider.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fake_secure_storage.dart';

/// Scriptable [BiometricService]: set [available] and the [outcome] of the next prompts.
class FakeBiometricService implements BiometricService {
  var available = true;
  var outcome = BiometricOutcome.success;
  final reasons = <String>[];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<BiometricOutcome> authenticate({required String reason}) async {
    reasons.add(reason);
    return outcome;
  }

  Override get providerOverride => biometricServiceProvider.overrideWithValue(this);
}

/// The real security repository over [storage], with cheap PIN hashing so tests stay fast.
Override fastSecurityRepositoryOverride(FakeSecureStorage storage) =>
    securityRepositoryProvider.overrideWith(
      (ref) => SecurityRepositoryImpl(
        storage: storage,
        session: ref.watch(sessionProvider.notifier),
        hasher: const PinHasher(iterations: 10, inBackground: false),
      ),
    );
