import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Keychain (iOS) / Keystore-backed (Android) key-value storage for secrets such as the PIN hash.
/// The only place that touches `flutter_secure_storage`.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  /// Removes every secret (logout).
  Future<void> deleteAll() => _storage.deleteAll();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) =>
    const SecureStorageService(FlutterSecureStorage());
