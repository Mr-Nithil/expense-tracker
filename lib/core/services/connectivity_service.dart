import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Whether the device has a network link (Wi-Fi, mobile, ethernet…). The only place that touches
/// `connectivity_plus`. A link does not guarantee the server is reachable; sync just tries.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  /// Whether a link exists right now (the starting value for [onlineChanges]).
  Future<bool> isOnline() async => _isOnline(await _connectivity.checkConnectivity());

  /// `true` when a link appears, `false` when the last one goes away. Repeats are dropped.
  Stream<bool> get onlineChanges => _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) => ConnectivityService(Connectivity());
