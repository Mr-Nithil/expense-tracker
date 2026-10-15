import 'dart:convert';

import 'package:expense_tracker/core/crypto/row_cipher.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';

/// Where the user's data key comes from: the `user-key` Edge Function (ARCHITECTURE §13).
/// Never throws: `NetworkFailure` offline, `AuthFailure` when the session is refused,
/// `UnexpectedFailure` otherwise (e.g. the function is not deployed).
abstract interface class DataKeyGateway {
  Future<Result<List<int>>> fetch();
}

/// The signed-in user's 32-byte data key (M11.5): from memory, then the secure-storage cache
/// (only if it belongs to that user), then the server, which is cached for offline use.
/// Logout wipes secure storage, so the cache goes with it. Never logs key material.
class DataKeyService {
  DataKeyService({required this.storage, required this.gateway});

  static const storageKey = 'data_key';

  final SecureStorageService storage;
  final DataKeyGateway gateway;

  String? _owner;
  List<int>? _key;

  Future<Result<List<int>>> keyFor(String userId) async {
    if (_owner == userId && _key != null) return Result.success(_key!);

    try {
      if (await storage.read(storageKey) case final raw?) {
        final cached = jsonDecode(raw) as Map<String, Object?>;
        if (cached['owner'] == userId) {
          final key = base64Url.decode(base64Url.normalize(cached['key']! as String));
          if (key.length == RowCipher.keyLength) return Result.success(_remember(userId, key));
        }
      }
    } on FormatException catch (_) {
      AppLogger.warning('data key cache unreadable, fetching again');
    } catch (error, stackTrace) {
      AppLogger.error('data key cache read failed', error, stackTrace);
      return Result.failure(StorageFailure('data key: $error'));
    }

    final fetched = await gateway.fetch();
    final List<int> key;
    switch (fetched) {
      case Failure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        key = value;
    }
    if (key.length != RowCipher.keyLength) {
      return const Result.failure(UnexpectedFailure('data key: wrong length'));
    }
    try {
      await storage.write(
        storageKey,
        jsonEncode({'owner': userId, 'key': base64Url.encode(key)}),
      );
    } catch (error, stackTrace) {
      AppLogger.error('data key cache write failed', error, stackTrace);
      return Result.failure(StorageFailure('data key: $error'));
    }
    return Result.success(_remember(userId, key));
  }

  List<int> _remember(String userId, List<int> key) {
    _owner = userId;
    _key = List.unmodifiable(key);
    return _key!;
  }
}
