import 'package:hive/hive.dart';

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
  static const int validityDays = 90;
  static const String _boxName = SecureHiveService.settingsBoxName;
  static const String _authenticatedOnceKey = 'offline_authenticated_once';
  static const String _lastLoginAtKey = 'offline_last_successful_login_at';
  static const String _validUntilKey = 'offline_valid_until';

  static Box get _box => Hive.box(_boxName);

  Future<OfflineSession> getSession() async {
    final lastLogin = DateTime.tryParse(
      _box.get(_lastLoginAtKey, defaultValue: '')?.toString() ?? '',
    );
    final validUntil = DateTime.tryParse(
      _box.get(_validUntilKey, defaultValue: '')?.toString() ?? '',
    );

    return OfflineSession(
      authenticatedOnce:
          _box.get(_authenticatedOnceKey, defaultValue: false) == true,
      lastSuccessfulLoginAt: lastLogin,
      validUntil: validUntil,
    );
  }

  Future<void> markSuccessfulLogin({DateTime? now}) async {
    final current = now ?? DateTime.now();
    await _box.put(_authenticatedOnceKey, true);
    await _box.put(_lastLoginAtKey, current.toIso8601String());
    await _box.put(
      _validUntilKey,
      current.add(const Duration(days: validityDays)).toIso8601String(),
    );
  }

  Future<void> clearSession() async {
    await _box.delete(_authenticatedOnceKey);
    await _box.delete(_lastLoginAtKey);
    await _box.delete(_validUntilKey);
  }
}
