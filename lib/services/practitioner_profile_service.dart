import 'package:hive_flutter/hive_flutter.dart';

import '../models/practitioner_profile.dart';

class PractitionerProfileService {
  static const String _boxName = 'settings_box';
  static const String _profileKey = 'practitioner_profile';

  static Future<PractitionerProfile> getProfile() async {
    final box = Hive.box(_boxName);
    final raw = box.get(_profileKey);

    if (raw is Map) {
      return PractitionerProfile.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }

    return PractitionerProfile.empty();
  }

  static Future<void> saveProfile(PractitionerProfile profile) async {
    final box = Hive.box(_boxName);
    await box.put(_profileKey, profile.toJson());
  }
}