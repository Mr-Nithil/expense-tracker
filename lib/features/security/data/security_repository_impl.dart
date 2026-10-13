import 'dart:convert';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/features/security/data/pin_hasher.dart';
import 'package:expense_tracker/features/security/domain/entities/lock_settings.dart';
import 'package:expense_tracker/features/security/domain/security_repository.dart';
import 'package:expense_tracker/features/security/domain/services/pin_rules.dart';

/// [SecurityRepository] over secure storage: one JSON entry (atomic writes) holding the owner's
/// user id, the PIN hash and the options.
class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl({required this.storage, required this.session, required this.hasher});

  final SecureStorageService storage;
  final Session session;
  final PinHasher hasher;

  static const storageKey = 'app_lock';
  static const pinField = 'pin';

  @override
  Future<Result<LockSettings>> load() => _run('load', () async => _settingsOf(await _read()));

  @override
  Future<Result<LockSettings>> setPin(String pin) async {
    if (!PinRules.isValid(pin)) {
      return const Result.failure(ValidationFailure('pinInvalid', field: pinField));
    }
    return _run('setPin', () async {
      final stored = await _read() ?? _Stored(owner: session.requireUserId());
      return _write(stored.copyWith(pinHash: await hasher.hash(pin), pinLength: pin.length));
    });
  }

  @override
  Future<Result<bool>> verifyPin(String pin) => _run('verifyPin', () async {
    final hash = (await _read())?.pinHash;
    return hash != null && await hasher.verify(pin, hash);
  });

  @override
  Future<Result<LockSettings>> removePin() => _run('removePin', () async {
    final stored = await _read();
    // The timeout is kept for the next time the lock is turned on.
    return _write(
      _Stored(owner: session.requireUserId(), timeout: stored?.timeout ?? LockTimeout.fallback),
    );
  });

  @override
  Future<Result<LockSettings>> setBiometricsEnabled({required bool enabled}) async {
    final result = await _run('setBiometricsEnabled', () async {
      final stored = await _read();
      if (enabled && stored?.pinHash == null) return null;
      return _write(
        (stored ?? _Stored(owner: session.requireUserId())).copyWith(biometrics: enabled),
      );
    });
    return switch (result) {
      Success(value: null) => const Result.failure(
        ValidationFailure('pinRequired', field: pinField),
      ),
      Success(:final value?) => Result.success(value),
      Failure(:final failure) => Result.failure(failure),
    };
  }

  @override
  Future<Result<LockSettings>> setTimeout(LockTimeout timeout) => _run('setTimeout', () async {
    final stored = await _read() ?? _Stored(owner: session.requireUserId());
    return _write(stored.copyWith(timeout: timeout));
  });

  /// The signed-in user's stored entry. Another user's (e.g. left in the iOS Keychain after a
  /// reinstall) or an unreadable one is deleted and treated as none.
  Future<_Stored?> _read() async {
    final userId = session.requireUserId();
    final raw = await storage.read(storageKey);
    if (raw == null) return null;
    final stored = _Stored.tryParse(raw);
    if (stored == null || stored.owner != userId) {
      AppLogger.info('app lock settings of another user or unreadable: removing them');
      await storage.delete(storageKey);
      return null;
    }
    return stored;
  }

  Future<LockSettings> _write(_Stored stored) async {
    await storage.write(storageKey, stored.encode());
    return _settingsOf(stored);
  }

  static LockSettings _settingsOf(_Stored? stored) => stored == null
      ? const LockSettings()
      : LockSettings(
          pinEnabled: stored.pinHash != null,
          pinLength: stored.pinHash == null ? 0 : stored.pinLength,
          biometricsEnabled: stored.pinHash != null && stored.biometrics,
          timeout: stored.timeout,
        );

  Future<Result<T>> _run<T>(String operation, Future<T> Function() body) async {
    try {
      return Result.success(await body());
    } on StateError catch (_) {
      return Result.failure(AuthFailure('$operation: no session'));
    } catch (error, stackTrace) {
      AppLogger.error('app lock $operation failed', error, stackTrace);
      return Result.failure(StorageFailure('$operation: $error'));
    }
  }
}

/// The stored JSON entry.
class _Stored {
  const _Stored({
    required this.owner,
    this.pinHash,
    this.pinLength = 0,
    this.biometrics = false,
    this.timeout = LockTimeout.fallback,
  });

  final String owner;
  final String? pinHash;
  final int pinLength;
  final bool biometrics;
  final LockTimeout timeout;

  _Stored copyWith({String? pinHash, int? pinLength, bool? biometrics, LockTimeout? timeout}) =>
      _Stored(
        owner: owner,
        pinHash: pinHash ?? this.pinHash,
        pinLength: pinLength ?? this.pinLength,
        biometrics: biometrics ?? this.biometrics,
        timeout: timeout ?? this.timeout,
      );

  String encode() => jsonEncode({
    'owner': owner,
    'pinHash': pinHash,
    'pinLength': pinLength,
    'biometrics': biometrics,
    'timeout': timeout.name,
  });

  static _Stored? tryParse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _Stored(
        owner: json['owner'] as String,
        pinHash: json['pinHash'] as String?,
        pinLength: json['pinLength'] as int? ?? 0,
        biometrics: json['biometrics'] as bool? ?? false,
        timeout: LockTimeout.values.asNameMap()[json['timeout']] ?? LockTimeout.fallback,
      );
    } on Object catch (_) {
      return null;
    }
  }
}
