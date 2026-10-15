import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/sync/supabase_data_key_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockClient extends Mock implements SupabaseClient {}

class _MockFunctions extends Mock implements FunctionsClient {}

void main() {
  late _MockFunctions functions;
  late SupabaseDataKeyGateway gateway;
  final key = List<int>.generate(32, (i) => i);

  setUp(() {
    functions = _MockFunctions();
    final client = _MockClient();
    when(() => client.functions).thenReturn(functions);
    gateway = SupabaseDataKeyGateway(client);
  });

  void answer(Future<FunctionResponse> Function() response) => when(
    () => functions.invoke(SupabaseDataKeyGateway.functionName),
  ).thenAnswer((_) => response());

  test('decodes the key returned by user-key', () async {
    answer(
      () async => FunctionResponse(
        status: 200,
        data: {'version': 'v1', 'key': base64Url.encode(key).replaceAll('=', '')},
      ),
    );

    expect((await gateway.fetch()).valueOrNull, key);
  });

  test('an unexpected response is an UnexpectedFailure', () async {
    answer(() async => const FunctionResponse(status: 200, data: {'version': 'v9', 'key': 'x'}));
    expect((await gateway.fetch()).failureOrNull, isA<UnexpectedFailure>());

    answer(() async => const FunctionResponse(status: 200, data: 'not json'));
    expect((await gateway.fetch()).failureOrNull, isA<UnexpectedFailure>());
  });

  test('a refused session is an AuthFailure; other errors are UnexpectedFailure', () async {
    answer(() => Future.error(const FunctionException(status: 401)));
    expect((await gateway.fetch()).failureOrNull, isA<AuthFailure>());

    answer(() => Future.error(const FunctionException(status: 404)));
    expect((await gateway.fetch()).failureOrNull, isA<UnexpectedFailure>());
  });

  test('no connection is a NetworkFailure', () async {
    answer(() => Future.error(const SocketException('offline')));
    expect((await gateway.fetch()).failureOrNull, isA<NetworkFailure>());
  });
}
