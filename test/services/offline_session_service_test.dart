import 'dart:io';

import 'package:drapeaux_rouges_mb/services/offline_session_fallback_store.dart';
import 'package:drapeaux_rouges_mb/services/offline_session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late Box settingsBox;
  late _MemoryOfflineSessionFallbackStore fallbackStore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp(
      'offline_session_service_test_',
    );
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox('settings_box');
  });

  setUp(() async {
    await settingsBox.clear();
    fallbackStore = _MemoryOfflineSessionFallbackStore();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('Hive valide retourne une session valide', () async {
    final now = DateTime.now();
    await settingsBox.put(OfflineSessionFallbackKeys.authenticatedOnce, true);
    await settingsBox.put(
      OfflineSessionFallbackKeys.lastSuccessfulLoginAt,
      now.subtract(const Duration(days: 1)).toIso8601String(),
    );
    await settingsBox.put(
      OfflineSessionFallbackKeys.validUntil,
      now.add(const Duration(days: 30)).toIso8601String(),
    );

    final session = await OfflineSessionService(
      fallbackStore: fallbackStore,
    ).getSession();

    expect(session.authenticatedOnce, isTrue);
    expect(session.isValid, isTrue);
  });

  test(
    'Hive vide et fallback Web valide retourne une session valide',
    () async {
      final now = DateTime.now();
      await fallbackStore.write(
        authenticatedOnce: true,
        lastSuccessfulLoginAt: now
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        validUntil: now.add(const Duration(days: 30)).toIso8601String(),
      );

      final session = await OfflineSessionService(
        fallbackStore: fallbackStore,
      ).getSession();

      expect(session.authenticatedOnce, isTrue);
      expect(session.isValid, isTrue);
    },
  );

  test(
    'Hive vide et fallback Web expiré retourne une session expirée',
    () async {
      final now = DateTime.now();
      await fallbackStore.write(
        authenticatedOnce: true,
        lastSuccessfulLoginAt: now
            .subtract(const Duration(days: 120))
            .toIso8601String(),
        validUntil: now.subtract(const Duration(days: 1)).toIso8601String(),
      );

      final session = await OfflineSessionService(
        fallbackStore: fallbackStore,
      ).getSession();

      expect(session.authenticatedOnce, isTrue);
      expect(session.isValid, isFalse);
      expect(session.isExpired, isTrue);
    },
  );

  test('aucune session retourne une session invalide non expirée', () async {
    final session = await OfflineSessionService(
      fallbackStore: fallbackStore,
    ).getSession();

    expect(session.authenticatedOnce, isFalse);
    expect(session.isValid, isFalse);
    expect(session.isExpired, isFalse);
  });

  test('login réussi écrit Hive et fallback puis relit valid=true', () async {
    final now = DateTime(2026, 6, 19, 12);
    final service = OfflineSessionService(fallbackStore: fallbackStore);

    await service.recordSuccessfulLogin(now: now);
    final session = await service.getSession();

    expect(settingsBox.get(OfflineSessionFallbackKeys.authenticatedOnce), true);
    expect(
      fallbackStore.values[OfflineSessionFallbackKeys.authenticatedOnce],
      'true',
    );
    expect(session.isValid, isTrue);
    expect(session.lastSuccessfulLoginAt, now);
    expect(
      session.validUntil,
      now.add(const Duration(days: OfflineSessionService.validityDays)),
    );
  });
}

class _MemoryOfflineSessionFallbackStore
    implements OfflineSessionFallbackStore {
  final Map<String, String?> values = {
    OfflineSessionFallbackKeys.authenticatedOnce: null,
    OfflineSessionFallbackKeys.lastSuccessfulLoginAt: null,
    OfflineSessionFallbackKeys.validUntil: null,
  };

  @override
  Future<void> write({
    required bool authenticatedOnce,
    required String lastSuccessfulLoginAt,
    required String validUntil,
  }) async {
    values[OfflineSessionFallbackKeys.authenticatedOnce] = authenticatedOnce
        .toString();
    values[OfflineSessionFallbackKeys.lastSuccessfulLoginAt] =
        lastSuccessfulLoginAt;
    values[OfflineSessionFallbackKeys.validUntil] = validUntil;
  }

  @override
  Future<Map<String, String?>> read() async {
    return Map<String, String?>.from(values);
  }

  @override
  Future<void> clear() async {
    values.updateAll((key, value) => null);
  }
}
