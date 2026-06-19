// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'offline_session_fallback_store.dart';

OfflineSessionFallbackStore createOfflineSessionFallbackStore() {
  return const WebLocalStorageOfflineSessionFallbackStore();
}

class WebLocalStorageOfflineSessionFallbackStore
    implements OfflineSessionFallbackStore {
  const WebLocalStorageOfflineSessionFallbackStore();

  @override
  Future<void> write({
    required bool authenticatedOnce,
    required String lastSuccessfulLoginAt,
    required String validUntil,
  }) async {
    html.window.localStorage[OfflineSessionFallbackKeys.authenticatedOnce] =
        authenticatedOnce.toString();
    html.window.localStorage[OfflineSessionFallbackKeys.lastSuccessfulLoginAt] =
        lastSuccessfulLoginAt;
    html.window.localStorage[OfflineSessionFallbackKeys.validUntil] =
        validUntil;
  }

  @override
  Future<Map<String, String?>> read() async {
    return {
      OfflineSessionFallbackKeys.authenticatedOnce: html
          .window
          .localStorage[OfflineSessionFallbackKeys.authenticatedOnce],
      OfflineSessionFallbackKeys.lastSuccessfulLoginAt: html
          .window
          .localStorage[OfflineSessionFallbackKeys.lastSuccessfulLoginAt],
      OfflineSessionFallbackKeys.validUntil:
          html.window.localStorage[OfflineSessionFallbackKeys.validUntil],
    };
  }

  @override
  Future<void> clear() async {
    html.window.localStorage.remove(
      OfflineSessionFallbackKeys.authenticatedOnce,
    );
    html.window.localStorage.remove(
      OfflineSessionFallbackKeys.lastSuccessfulLoginAt,
    );
    html.window.localStorage.remove(OfflineSessionFallbackKeys.validUntil);
  }
}
