import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureHiveService {
  static const String patientsBoxName = 'patients_box';
  static const String evaluationsBoxName = 'evaluations_box';
  static const String settingsBoxName = 'settings_box';
  static const String accessDirectBoxName = 'access_direct_box';

  static const String _encryptionKeyName = 'hive_encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static HiveAesCipher? _cipher;

  static Future<void> initFlutter() async {
    await Hive.initFlutter();
    await openProtectedBoxes();
  }

  static Future<void> openProtectedBoxes() async {
    final cipher = await encryptionCipher();

    await _openProtectedBox(patientsBoxName, cipher);
    await _openProtectedBox(evaluationsBoxName, cipher);
    await _openProtectedBox(settingsBoxName, cipher);
    await _openProtectedBox(accessDirectBoxName, cipher);
  }

  static Future<Box> openProtectedBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return _openProtectedBox(boxName, await encryptionCipher());
  }

  static Future<HiveAesCipher> encryptionCipher() async {
    final existingCipher = _cipher;
    if (existingCipher != null) return existingCipher;

    final encodedKey = await _secureStorage.read(key: _encryptionKeyName);

    if (encodedKey != null && encodedKey.isNotEmpty) {
      final key = base64Url.decode(encodedKey);
      _cipher = HiveAesCipher(key);
      return _cipher!;
    }

    final key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64UrlEncode(key),
    );

    _cipher = HiveAesCipher(key);
    return _cipher!;
  }

  static Future<Box> _openProtectedBox(
    String boxName,
    HiveAesCipher cipher,
  ) async {
    try {
      return await Hive.openBox(boxName, encryptionCipher: cipher);
    } on HiveError {
      return _migrateLegacyBox(boxName, cipher);
    }
  }

  static Future<Box> _migrateLegacyBox(
    String boxName,
    HiveAesCipher cipher,
  ) async {
    final legacyBox = await Hive.openBox(boxName);
    final legacyValues = <dynamic, dynamic>{};

    for (final key in legacyBox.keys) {
      legacyValues[key] = legacyBox.get(key);
    }

    await legacyBox.close();
    await Hive.deleteBoxFromDisk(boxName);

    final encryptedBox = await Hive.openBox(boxName, encryptionCipher: cipher);
    await encryptedBox.putAll(legacyValues);

    return encryptedBox;
  }
}
