import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expense_tracker/core/services/connectivity_service.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// Connectivity driven by the test: [emit] online/offline changes.
class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService() : super(Connectivity()) {
    addTearDown(_changes.close);
  }

  final _changes = StreamController<bool>.broadcast();

  /// What [isOnline] answers; [emit] updates it too.
  bool online = true;

  void emit({required bool online}) {
    this.online = online;
    _changes.add(online);
  }

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onlineChanges => _changes.stream;

  Override get providerOverride => connectivityServiceProvider.overrideWithValue(this);
}
