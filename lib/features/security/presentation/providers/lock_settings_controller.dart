import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/services/local_biometric_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/data/security_repository_provider.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/domain/security_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lock_settings_controller.g.dart';

/// The signed-in user's app lock settings on this device, kept up to date after every change.
/// The security feature's entry point for Settings (ARCHITECTURE §3). Fails with the repository's
/// `AppFailure` when they can't be read.
@Riverpod(keepAlive: true)
class LockSettingsController extends _$LockSettingsController {
  SecurityRepository get _repository => ref.read(securityRepositoryProvider);

  @override
  Future<LockSettings> build() async {
    final userId = ref.watch(sessionProvider.select((user) => user?.userId));
    if (userId == null) return const LockSettings();
    return switch (await _repository.load()) {
      Success(:final value) => value,
      Failure(:final failure) => throw failure,
    };
  }

  /// Turns the lock on, or changes the PIN.
  Future<Result<LockSettings>> setPin(String pin) => _save(_repository.setPin(pin));

  Future<Result<LockSettings>> removePin() => _save(_repository.removePin());

  Future<Result<LockSettings>> setBiometricsEnabled({required bool enabled}) =>
      _save(_repository.setBiometricsEnabled(enabled: enabled));

  Future<Result<LockSettings>> setTimeout(LockTimeout timeout) =>
      _save(_repository.setTimeout(timeout));

  Future<Result<bool>> verifyPin(String pin) => _repository.verifyPin(pin);

  Future<Result<LockSettings>> _save(Future<Result<LockSettings>> write) async {
    final result = await write;
    if (result case Success(:final value) when ref.mounted) state = AsyncData(value);
    return result;
  }
}

/// Whether this phone can unlock with an enrolled face or fingerprint.
@riverpod
Future<bool> biometricsAvailable(Ref ref) => ref.watch(biometricServiceProvider).isAvailable();
