import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expense_tracker/core/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  test('reports online when any link exists, dropping repeats', () async {
    final connectivity = _MockConnectivity();
    final changes = StreamController<List<ConnectivityResult>>();
    addTearDown(changes.close);
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => changes.stream);

    final online = ConnectivityService(connectivity).onlineChanges;
    final expectation = expectLater(online, emitsInOrder([false, true, false]));

    changes
      ..add([ConnectivityResult.none])
      ..add([ConnectivityResult.wifi])
      ..add([ConnectivityResult.wifi, ConnectivityResult.mobile])
      ..add([ConnectivityResult.none]);
    await expectation;
  });

  test('isOnline reads the current links', () async {
    final connectivity = _MockConnectivity();
    final service = ConnectivityService(connectivity);

    when(connectivity.checkConnectivity).thenAnswer((_) async => [ConnectivityResult.mobile]);
    expect(await service.isOnline(), isTrue);

    when(connectivity.checkConnectivity).thenAnswer((_) async => [ConnectivityResult.none]);
    expect(await service.isOnline(), isFalse);
  });
}
