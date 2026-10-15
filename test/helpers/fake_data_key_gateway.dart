import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/session/session.dart';
import 'package:expense_tracker/core/sync/supabase_data_key_gateway.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// The `user-key` function without a server: one stable key per user (several "phones" sharing a
/// [FakeKeyServer] get the same key, like the real one). Set [failure] to make fetches fail.
class FakeKeyServer {
  final _keys = <String, List<int>>{};
  final fetches = <String>[];
  Result<List<int>>? failure;

  List<int> keyOf(String userId) =>
      _keys.putIfAbsent(userId, () => List.generate(32, (i) => (i * 7 + userId.hashCode) & 0xFF));

  /// A gateway for the phone signed in as [userId].
  DataKeyGateway gatewayFor(String Function() userId) => _Gateway(this, userId);
}

class _Gateway implements DataKeyGateway {
  _Gateway(this.server, this.userId);

  final FakeKeyServer server;
  final String Function() userId;

  @override
  Future<Result<List<int>>> fetch() async {
    final user = userId();
    server.fetches.add(user);
    return server.failure ?? Result.success(server.keyOf(user));
  }
}

/// Overrides `dataKeyGatewayProvider` with [server], keyed by the session's user.
Override fakeDataKeyGatewayOverride(FakeKeyServer server) => dataKeyGatewayProvider.overrideWith(
  (ref) => server.gatewayFor(() => ref.read(sessionProvider)?.userId ?? 'signed-out'),
);
