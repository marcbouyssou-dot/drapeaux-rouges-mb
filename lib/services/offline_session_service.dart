import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'offline_session_fallback_store.dart';
import 'offline_session_fallback_store_factory.dart';
import 'secure_hive_service.dart';

class OfflineSession {
  const OfflineSession({
    required this.authenticatedOnce,
    required this.lastSuccessfulLoginAt,
    required this.validUntil,
  });

  final bool authenticatedOnce;
  final DateTime? lastSuccessfulLoginAt;
  final DateTime? validUntil;

  bool get isValid {
    if (!authenticatedOnce || validUntil == null) return false;
    return DateTime.now().isBefore(validUntil!);
  }

  bool get isExpired => authenticatedOnce && !isValid;
}

class OfflineSessionService {
  OfflineSessionService({OfflineSessionFallbackStore? fallbackStore})
    : _fallbackStore = fallbackStore ?? createOfflineSessionFallbackStore();

  static const int validityDays = 90;
  static const String _boxName = SecureHiveService.settingsBoxName;
  static const String _authenticatedOnceKey =
      OfflineSessionFallbackKeys.authenticatedOnce;
  static const String _lastLoginAtKey =
      OfflineSessionFallbackKeys.lastSuccessfulLoginAt;
  static const String _validUntilKey = OfflineSessionFallbackKeys.validUntil;

  final OfflineSessionFallbackStore _fallbackStore;

  static Box get _box => Hive.box(_boxName);

  Future<OfflineSession> getSession() async {
    debugPrint('[BOOT][OfflineSession] getSession() START');
    final hiveSession = _readHiveSession();
    final fallbackSession = await _readFallbackSession();
    final session = _selectSession(hiveSession, fallbackSession);

    debugPrint(
      '[BOOT][OfflineSession] getSession() OK '
      'authenticatedOnce=${session.authenticatedOnce} '
      'isValid=${session.isValid} isExpired=${session.isExpired}',
    );
    debugPrint(
      'OFFLINE SESSION READ\n'
      'authenticatedOnce=${session.authenticatedOnce}\n'
      'lastSuccessfulLoginAt=${session.lastSuccessfulLoginAt?.toIso8601String()}\n'
      'expiresAt=${session.validUntil?.toIso8601String()}\n'
      'valid=${session.isValid}',
    );
    return session;
  }

  Future<void> markSuccessfulLogin({DateTime? now}) async {
    debugPrint('[BOOT][OfflineSession] markSuccessfulLogin() START');
    final current = now ?? DateTime.now();
    final validUntil = current.add(const Duration(days: validityDays));
    await _box.put(_authenticatedOnceKey, true);
    await _box.put(_lastLoginAtKey, current.toIso8601String());
    await _box.put(_validUntilKey, validUntil.toIso8601String());
    await _fallbackStore.write(
      authenticatedOnce: true,
      lastSuccessfulLoginAt: current.toIso8601String(),
      validUntil: validUntil.toIso8601String(),
    );
    final session = await getSession();
    debugPrint(
      'LOGIN SAVED OFFLINE SESSION\n'
      'authenticatedOnce=${session.authenticatedOnce}\n'
      'lastSuccessfulLoginAt=${session.lastSuccessfulLoginAt?.toIso8601String()}\n'
      'expiresAt=${session.validUntil?.toIso8601String()}',
    );
    debugPrint('[BOOT][OfflineSession] markSuccessfulLogin() OK');
  }

  Future<void> recordSuccessfulLogin({DateTime? now}) {
    return markSuccessfulLogin(now: now);
  }

  Future<void> clearSession() async {
    debugPrint('[BOOT][OfflineSession] clearSession() START');
    await _box.delete(_authenticatedOnceKey);
    await _box.delete(_lastLoginAtKey);
    await _box.delete(_validUntilKey);
    await _fallbackStore.clear();
    debugPrint('[BOOT][OfflineSession] clearSession() OK');
  }

  OfflineSession _readHiveSession() {
    try {
      final session = OfflineSession(
        authenticatedOnce:
            _box.get(_authenticatedOnceKey, defaultValue: false) == true,
        lastSuccessfulLoginAt: DateTime.tryParse(
          _box.get(_lastLoginAtKey, defaultValue: '')?.toString() ?? '',
        ),
        validUntil: DateTime.tryParse(
          _box.get(_validUntilKey, defaultValue: '')?.toString() ?? '',
        ),
      );
      debugPrint(
        '[BOOT][OfflineSession] Hive read '
        'authenticatedOnce=${session.authenticatedOnce} '
        'valid=${session.isValid} expired=${session.isExpired}',
      );
      return session;
    } catch (error) {
      debugPrint('[BOOT][OfflineSession] Hive read failed: $error');
      return const OfflineSession(
        authenticatedOnce: false,
        lastSuccessfulLoginAt: null,
        validUntil: null,
      );
    }
  }

  Future<OfflineSession> _readFallbackSession() async {
    try {
      final values = await _fallbackStore.read();
      final session = OfflineSession(
        authenticatedOnce:
            values[OfflineSessionFallbackKeys.authenticatedOnce] == 'true',
        lastSuccessfulLoginAt: DateTime.tryParse(
          values[OfflineSessionFallbackKeys.lastSuccessfulLoginAt] ?? '',
        ),
        validUntil: DateTime.tryParse(
          values[OfflineSessionFallbackKeys.validUntil] ?? '',
        ),
      );
      debugPrint(
        '[BOOT][OfflineSession] Web fallback read '
        'authenticatedOnce=${session.authenticatedOnce} '
        'valid=${session.isValid} expired=${session.isExpired}',
      );
      return session;
    } catch (error) {
      debugPrint('[BOOT][OfflineSession] Web fallback read failed: $error');
      return const OfflineSession(
        authenticatedOnce: false,
        lastSuccessfulLoginAt: null,
        validUntil: null,
      );
    }
  }

  OfflineSession _selectSession(
    OfflineSession hiveSession,
    OfflineSession fallbackSession,
  ) {
    if (hiveSession.isValid) return hiveSession;
    if (fallbackSession.isValid) return fallbackSession;
    if (hiveSession.isExpired) return hiveSession;
    if (fallbackSession.isExpired) return fallbackSession;
    return const OfflineSession(
      authenticatedOnce: false,
      lastSuccessfulLoginAt: null,
      validUntil: null,
    );
  }
}
