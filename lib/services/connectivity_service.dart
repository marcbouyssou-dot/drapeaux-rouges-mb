import 'dart:async';

import 'connectivity_service_stub.dart'
    if (dart.library.html) 'connectivity_service_web.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  static bool? _debugOnlineOverride;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChanged => _controller.stream;

  bool get isOnline => _debugOnlineOverride ?? platformIsOnline();

  void emitCurrentStatus() {
    _controller.add(isOnline);
  }

  void emitStatusForTests(bool isOnline) {
    _debugOnlineOverride = isOnline;
    _controller.add(isOnline);
  }

  void clearTestOverride() {
    _debugOnlineOverride = null;
  }

  void startListening() {
    platformStartListening((online) {
      _controller.add(_debugOnlineOverride ?? online);
    });
  }
}
