import 'offline_session_fallback_store.dart';

OfflineSessionFallbackStore createOfflineSessionFallbackStore() {
  return const NoopOfflineSessionFallbackStore();
}

class NoopOfflineSessionFallbackStore implements OfflineSessionFallbackStore {
  const NoopOfflineSessionFallbackStore();

  @override
  Future<void> write({
    required bool authenticatedOnce,
    required String lastSuccessfulLoginAt,
    required String validUntil,
  }) async {}

  @override
  Future<Map<String, String?>> read() async {
    return const {
      OfflineSessionFallbackKeys.authenticatedOnce: null,
      OfflineSessionFallbackKeys.lastSuccessfulLoginAt: null,
      OfflineSessionFallbackKeys.validUntil: null,
    };
  }

  @override
  Future<void> clear() async {}
}
