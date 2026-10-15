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

  /// The local database key (M11.8): belongs to this phone, not to a user.
  static const databaseKeyName = 'db_key';

  /// Entries that survive [deleteAll]. The database file is emptied on logout but stays, so its
  /// key must stay too, or the next start could not open it.
  static const deviceKeys = {databaseKeyName};

  /// Removes every user secret (logout, user switch); [deviceKeys] are kept.
  Future<void> deleteAll() async {
    final kept = {for (final key in deviceKeys) key: await _storage.read(key: key)};
    await _storage.deleteAll();
    for (final MapEntry(:key, :value) in kept.entries) {
      if (value != null) await _storage.write(key: key, value: value);
    }
  }
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(Ref ref) =>
    const SecureStorageService(FlutterSecureStorage());
