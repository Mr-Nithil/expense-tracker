import 'dart:convert';

import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_data_key_gateway.dart';
import '../../helpers/fake_secure_storage.dart';

void main() {
  late FakeSecureStorage storage;
  late FakeKeyServer server;
  var user = 'u1';

  DataKeyService service() =>
      DataKeyService(storage: storage, gateway: server.gatewayFor(() => user));

  setUp(() {
    storage = FakeSecureStorage();
    server = FakeKeyServer();
    user = 'u1';
  });

  test('fetches the key once, then serves it from memory and from the cache', () async {
    final first = service();
    expect((await first.keyFor('u1')).valueOrNull, server.keyOf('u1'));
    expect((await first.keyFor('u1')).valueOrNull, server.keyOf('u1'));
    expect(server.fetches, ['u1']);

    // A restart: the cache in secure storage, no request (works offline).
    server.failure = const Result.failure(NetworkFailure('offline'));
    expect((await service().keyFor('u1')).valueOrNull, server.keyOf('u1'));
    expect(server.fetches, ['u1']);
  });

  test('the cache is never used for another user', () async {
    await service().keyFor('u1');
    user = 'u2';

    expect((await service().keyFor('u2')).valueOrNull, server.keyOf('u2'));
    expect(server.fetches, ['u1', 'u2']);
    expect(jsonDecode(storage.values[DataKeyService.storageKey]!)['owner'], 'u2');
  });

  test('without a cache and offline it fails, and caches nothing', () async {
    server.failure = const Result.failure(NetworkFailure('offline'));

    expect((await service().keyFor('u1')).failureOrNull, isA<NetworkFailure>());
    expect(storage.values, isEmpty);
  });

  test('a key of the wrong length is refused', () async {
    server.failure = Result.success(List.filled(16, 1));

    expect((await service().keyFor('u1')).failureOrNull, isA<UnexpectedFailure>());
    expect(storage.values, isEmpty);
  });

  test('an unreadable cache is replaced by a fresh fetch', () async {
    storage.values[DataKeyService.storageKey] = 'garbage';

    expect((await service().keyFor('u1')).valueOrNull, server.keyOf('u1'));
    expect(server.fetches, ['u1']);
  });

  test('a secure storage error becomes a StorageFailure', () async {
    storage.failWith = PlatformException(code: 'keystore');

    expect((await service().keyFor('u1')).failureOrNull, isA<StorageFailure>());
  });
}
