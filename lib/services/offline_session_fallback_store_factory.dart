import 'offline_session_fallback_store.dart';
import 'offline_session_fallback_store_stub.dart'
    if (dart.library.html) 'offline_session_fallback_store_web.dart'
    as implementation;

OfflineSessionFallbackStore createOfflineSessionFallbackStore() {
  return implementation.createOfflineSessionFallbackStore();
}
