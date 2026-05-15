import 'package:shared_preferences/shared_preferences.dart';

class CurrentPatientService {
  static const String _currentAnonymousPatientIdKey =
      'current_anonymous_patient_id';

  static Future<void> setCurrentAnonymousPatientId(String anonymousId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _currentAnonymousPatientIdKey,
      anonymousId,
    );
  }

  static Future<String?> getCurrentAnonymousPatientId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_currentAnonymousPatientIdKey);
  }

  static Future<void> clearCurrentPatient() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_currentAnonymousPatientIdKey);
  }
}