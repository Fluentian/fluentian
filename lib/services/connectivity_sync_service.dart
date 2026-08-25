import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'outbox_manager.dart';
import 'sync_manager.dart';

/// Owns reconnect/resume synchronization so queued writes are not dependent
/// on a user pressing refresh or opening a particular screen.
class ConnectivitySyncService {
  ConnectivitySyncService._();
  static final instance = ConnectivitySyncService._();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) flush();
    });
  }

  Future<void> flush() async {
    await OutboxManager.instance.flush();
    await SyncManager.instance.sync();
  }

  Future<void> dispose() async => _subscription?.cancel();
}
