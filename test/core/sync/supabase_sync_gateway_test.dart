import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/sync/supabase_sync_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final rows = [
    {'id': 't1', 'amount_minor': 1250, 'occurred_on': '2026-10-11'},
  ];

  /// A real Supabase client whose HTTP goes to [handler].
  SupabaseSyncGateway gatewayWith(Future<http.Response> Function(http.Request) handler) =>
      SupabaseSyncGateway(
        SupabaseClient(
          'https://example.supabase.co',
          'publishable-key',
          // Real responses carry their request; PostgREST relies on it.
          httpClient: MockClient((request) async {
            final response = await handler(request);
            return http.Response(
              response.body,
              response.statusCode,
              headers: response.headers,
              request: request,
            );
          }),
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  http.Response error(int status, String code) => http.Response(
    jsonEncode({'code': code, 'message': 'x', 'details': null, 'hint': null}),
    status,
    headers: {'content-type': 'application/json'},
  );

  test('upserts the rows in one merge request', () async {
    late http.Request sent;
    final gateway = gatewayWith((request) async {
      sent = request;
      return http.Response('', 201);
    });

    final result = await gateway.upsert('transactions', rows);

    expect(result.isSuccess, isTrue);
    expect(sent.method, 'POST');
    expect(sent.url.path, '/rest/v1/transactions');
    expect(sent.headers['Prefer'], contains('resolution=merge-duplicates'));
    expect(jsonDecode(sent.body), rows);
  });

  test('sends nothing for no rows', () async {
    var calls = 0;
    final gateway = gatewayWith((_) async {
      calls++;
      return http.Response('', 201);
    });

    expect((await gateway.upsert('transactions', const [])).isSuccess, isTrue);
    expect(calls, 0);
  });

  test('an expired session or refused access is an AuthFailure', () async {
    final expired = gatewayWith((_) async => error(401, 'PGRST301'));
    final rls = gatewayWith((_) async => error(403, '42501'));

    expect((await expired.upsert('transactions', rows)).failureOrNull, isA<AuthFailure>());
    expect((await rls.upsert('transactions', rows)).failureOrNull, isA<AuthFailure>());
  });

  test('rejected data (e.g. a missing parent row) is an UnexpectedFailure', () async {
    final gateway = gatewayWith((_) async => error(409, '23503'));

    expect((await gateway.upsert('transactions', rows)).failureOrNull, isA<UnexpectedFailure>());
  });

  test('no connection is a NetworkFailure', () async {
    final gateway = gatewayWith((_) async => throw http.ClientException('offline'));

    expect((await gateway.upsert('transactions', rows)).failureOrNull, isA<NetworkFailure>());
  });

  group('fetchChanges', () {
    final after = DateTime.utc(2026, 10, 11, 9, 0, 0, 123);
    final remoteRows = [
      {'id': 'a', 'server_updated_at': '2026-10-11T09:00:01+00:00'},
    ];

    Future<(Uri, Result<List<Map<String, Object?>>>)> fetch({
      DateTime? since,
      String? afterId,
    }) async {
      late Uri url;
      final gateway = gatewayWith((request) async {
        url = request.url;
        return http.Response(
          jsonEncode(remoteRows),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final result = await gateway.fetchChanges(
        'transactions',
        after: since,
        afterId: afterId,
        limit: 500,
      );
      return (url, result);
    }

    test('the first pull asks for everything, ordered and limited', () async {
      final (url, result) = await fetch();

      expect(url.path, '/rest/v1/transactions');
      expect(url.queryParameters.containsKey('server_updated_at'), isFalse);
      expect(url.queryParameters['order'], 'server_updated_at.asc.nullslast,id.asc.nullslast');
      expect(url.queryParameters['limit'], '500');
      expect(result.valueOrNull, remoteRows);
    });

    test('after a time, asks for newer rows', () async {
      final (url, _) = await fetch(since: after);

      expect(url.queryParameters['server_updated_at'], 'gt.2026-10-11T09:00:00.123Z');
    });

    test('after a row, asks for the next keyset page', () async {
      final (url, _) = await fetch(since: after, afterId: 'row-7');

      expect(
        url.queryParameters['or'],
        '(server_updated_at.gt.2026-10-11T09:00:00.123Z,'
        'and(server_updated_at.eq.2026-10-11T09:00:00.123Z,id.gt.row-7))',
      );
    });

    test('maps errors like upsert does', () async {
      final expired = gatewayWith((_) async => error(401, 'PGRST301'));
      final offline = gatewayWith((_) async => throw http.ClientException('offline'));

      expect(
        (await expired.fetchChanges('transactions', limit: 10)).failureOrNull,
        isA<AuthFailure>(),
      );
      expect(
        (await offline.fetchChanges('transactions', limit: 10)).failureOrNull,
        isA<NetworkFailure>(),
      );
    });
  });

  group('other errors', () {
    test('a socket error or a timeout is a NetworkFailure', () async {
      final socket = gatewayWith((_) async => throw const SocketException('down'));
      final slow = gatewayWith((_) async => throw TimeoutException('slow'));

      expect((await socket.upsert('transactions', rows)).failureOrNull, isA<NetworkFailure>());
      expect((await slow.upsert('transactions', rows)).failureOrNull, isA<NetworkFailure>());
    });

    test('anything unexpected is an UnexpectedFailure, never a crash', () async {
      final broken = gatewayWith((_) async => throw StateError('bug'));

      expect((await broken.upsert('transactions', rows)).failureOrNull, isA<UnexpectedFailure>());
    });
  });
}
