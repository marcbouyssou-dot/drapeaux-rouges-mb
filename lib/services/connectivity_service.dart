import 'dart:async';

import 'package:flutter/foundation.dart';

import 'connectivity_service_stub.dart'
    if (dart.library.html) 'connectivity_service_web.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  static bool? _debugOnlineOverride;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChanged => _controller.stream;

  bool get isOnline {
    final online = _debugOnlineOverride ?? platformIsOnline();
    debugPrint('[BOOT][Connectivity] isOnline=$online');
    return online;
  }

  void emitCurrentStatus() {
    debugPrint('[BOOT][Connectivity] emitCurrentStatus()');
    _controller.add(isOnline);
  }

  void emitStatusForTests(bool isOnline) {
    debugPrint('[BOOT][Connectivity] emitStatusForTests($isOnline)');
    _debugOnlineOverride = isOnline;
    _controller.add(isOnline);
  }

  void clearTestOverride() {
    debugPrint('[BOOT][Connectivity] clearTestOverride()');
    _debugOnlineOverride = null;
  }

  void startListening() {
    debugPrint('[BOOT][Connectivity] startListening()');
    platformStartListening((online) {
      debugPrint('[BOOT][Connectivity] browser event online=$online');
      _controller.add(_debugOnlineOverride ?? online);
    });
  }
}
