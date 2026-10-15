import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:expense_tracker/core/config/supabase_providers.dart';
import 'package:expense_tracker/core/crypto/data_key_service.dart';
import 'package:expense_tracker/core/error/app_failure.dart';
import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/core/logging/app_logger.dart';
import 'package:expense_tracker/core/services/secure_storage_service.dart';
import 'package:http/http.dart' show ClientException;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_data_key_gateway.g.dart';

/// [DataKeyGateway] over the `user-key` Edge Function (M11.4/M11.5). Supabase adds the signed-in
/// user's token. Logs status codes only, never key material.
class SupabaseDataKeyGateway implements DataKeyGateway {
  SupabaseDataKeyGateway(this._client);

  static const functionName = 'user-key';

  final SupabaseClient _client;

  @override
  Future<Result<List<int>>> fetch() async {
    try {
      final response = await _client.functions.invoke(functionName);
      final data = response.data;
      if (data is! Map || data['version'] != 'v1' || data['key'] is! String) {
        AppLogger.warning('data key: unexpected response');
        return const Result.failure(UnexpectedFailure('data key: unexpected response'));
      }
      return Result.success(base64Url.decode(base64Url.normalize(data['key'] as String)));
    } on FunctionException catch (error) {
      if (error.status == 401 || error.status == 403) {
        AppLogger.info('data key refused: status=${error.status}');
        return Result.failure(AuthFailure('data key: ${error.status}'));
      }
      AppLogger.warning('data key failed: status=${error.status}');
      return Result.failure(UnexpectedFailure('data key: ${error.status}', cause: error));
    } on SocketException catch (_) {
      return const Result.failure(NetworkFailure('data key: socket'));
    } on TimeoutException catch (_) {
      return const Result.failure(NetworkFailure('data key: timeout'));
    } on ClientException catch (_) {
      return const Result.failure(NetworkFailure('data key: client'));
    } on FormatException catch (_) {
      return const Result.failure(UnexpectedFailure('data key: not base64'));
    } catch (error, stackTrace) {
      AppLogger.error('data key fetch failed', error, stackTrace);
      return Result.failure(UnexpectedFailure('data key', cause: error));
    }
  }
}

@Riverpod(keepAlive: true)
DataKeyGateway dataKeyGateway(Ref ref) => SupabaseDataKeyGateway(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
DataKeyService dataKeyService(Ref ref) => DataKeyService(
  storage: ref.watch(secureStorageServiceProvider),
  gateway: ref.watch(dataKeyGatewayProvider),
);
