import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// In-memory [SecureStorageService]. Set [failWith] to make every call throw.
class FakeSecureStorage implements SecureStorageService {
  final values = <String, String>{};
  Object? failWith;

  void _maybeFail() {
    if (failWith case final error?) throw error;
  }

  @override
  Future<String?> read(String key) async {
    _maybeFail();
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _maybeFail();
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _maybeFail();
    values.remove(key);
  }

  /// Like the real one: [SecureStorageService.deviceKeys] survive.
  @override
  Future<void> deleteAll() async {
    _maybeFail();
    values.removeWhere((key, _) => !SecureStorageService.deviceKeys.contains(key));
  }

  Override get providerOverride => secureStorageServiceProvider.overrideWithValue(this);
}
