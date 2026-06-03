import 'package:hive_flutter/hive_flutter.dart';

import '../models/access_direct_model.dart';
import 'secure_hive_service.dart';

class AccessDirectLocalService {
  static const String _boxName = 'access_direct_box';
  static const String _key = 'current_access_direct_settings';

  static Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return SecureHiveService.openProtectedBox(_boxName);
  }

  static Future<AccessDirectModel> loadSettings() async {
    final box = await _openBox();
    final data = box.get(_key);

    if (data is Map) {
      return AccessDirectModel.fromJson(Map<String, dynamic>.from(data));
    }

    return AccessDirectModel.empty;
  }

  static Future<void> saveSettings(AccessDirectModel model) async {
    final box = await _openBox();
    await box.put(_key, model.toJson());
  }

  static Future<void> resetSettings() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}
