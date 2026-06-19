abstract class OfflineSessionFallbackStore {
  Future<void> write({
    required bool authenticatedOnce,
    required String lastSuccessfulLoginAt,
    required String validUntil,
  });

  Future<Map<String, String?>> read();

  Future<void> clear();
}

class OfflineSessionFallbackKeys {
  const OfflineSessionFallbackKeys._();

  static const authenticatedOnce = 'offline_authenticated_once';
  static const lastSuccessfulLoginAt = 'offline_last_successful_login_at';
  static const validUntil = 'offline_valid_until';
}
