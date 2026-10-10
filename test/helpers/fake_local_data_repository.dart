import 'dart:async';

import 'package:expense_tracker/core/error/result.dart';
import 'package:expense_tracker/features/auth/data/local_data_repository_provider.dart';
import 'package:expense_tracker/features/auth/domain/local_data_repository.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Records claims. Set [pending] to hold the next claims open until it completes.
class FakeLocalDataRepository implements LocalDataRepository {
  final claims = <String>[];
  var clearCount = 0;
  Completer<void>? pending;

  @override
  Future<Result<bool>> claimFor(String userId) async {
    claims.add(userId);
    await pending?.future;
    return const Result.success(false);
  }

  @override
  Future<Result<void>> clear() async {
    clearCount++;
    return Result.ok;
  }

  Override get providerOverride => localDataRepositoryProvider.overrideWithValue(this);
}
