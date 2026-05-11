import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PatientSessionService {
  static const _keyPatients = 'patients_list';
  static const _keyCurrentPatientCode = 'current_patient_code';

  static String? currentPatientCode;

  static Future<List<Map<String, dynamic>>> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPatients);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;

    return decoded.map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  static Future<void> savePatient({
    required String code,
    required String nom,
    required String prenom,
    required String naissance,
    required bool consentement,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final patients = await getPatients();

    final patient = {
      'code': code,
      'nom': nom,
      'prenom': prenom,
      'naissance': naissance,
      'consentement': consentement,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final existingIndex = patients.indexWhere((p) => p['code'] == code);

    if (existingIndex >= 0) {
      patients[existingIndex] = patient;
    } else {
      patients.insert(0, patient);
    }

    await prefs.setString(_keyPatients, jsonEncode(patients));
    await setCurrentPatient(code);
  }

  static Future<void> setCurrentPatient(String code) async {
    final prefs = await SharedPreferences.getInstance();

    currentPatientCode = code;
    await prefs.setString(_keyCurrentPatientCode, code);
  }

  static Future<void> loadPatient() async {
    final prefs = await SharedPreferences.getInstance();
    currentPatientCode = prefs.getString(_keyCurrentPatientCode);
  }

  static Future<Map<String, dynamic>> getPatientData() async {
    final patients = await getPatients();

    if (currentPatientCode == null) {
      return _emptyPatient();
    }

    final patient = patients.firstWhere(
      (p) => p['code'] == currentPatientCode,
      orElse: () => _emptyPatient(),
    );

    return patient;
  }

  static Future<Map<String, dynamic>?> getPatientByCode(String code) async {
    final patients = await getPatients();

    try {
      return patients.firstWhere((p) => p['code'] == code);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deletePatient(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final patients = await getPatients();

    patients.removeWhere((p) => p['code'] == code);

    await prefs.setString(_keyPatients, jsonEncode(patients));

    if (currentPatientCode == code) {
      currentPatientCode = null;
      await prefs.remove(_keyCurrentPatientCode);
    }
  }

  static Future<void> clearAllPatients() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyPatients);
    await prefs.remove(_keyCurrentPatientCode);

    currentPatientCode = null;
  }

  static String get patientCode {
    return currentPatientCode ?? 'Non renseigné';
  }

  static bool get hasPatient {
    return currentPatientCode != null && currentPatientCode!.isNotEmpty;
  }

  static Map<String, dynamic> _emptyPatient() {
    return {
      'code': null,
      'nom': '',
      'prenom': '',
      'naissance': '',
      'consentement': false,
      'createdAt': null,
    };
  }
}