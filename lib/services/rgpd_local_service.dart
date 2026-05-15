import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/patient_local.dart';

class RgpdLocalService {
  static const String _patientsKey = 'patients_local_rgpd';

  static String createAnonymousId() {
    const uuid = Uuid();
    return 'DR-${uuid.v4()}';
  }

  static String createLocalId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  static Future<void> savePatient(PatientLocal patient) async {
    final prefs = await SharedPreferences.getInstance();

    final patients = await getPatients();
    patients.add(patient);

    final encoded = patients.map((p) => p.toJson()).toList();

    await prefs.setString(_patientsKey, jsonEncode(encoded));
  }

  static Future<List<PatientLocal>> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_patientsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw);

    return decoded
        .map((item) => PatientLocal.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> deleteAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_patientsKey);
  }

  static Future<List<Map<String, dynamic>>> getAnonymousExportData() async {
    final patients = await getPatients();

    return patients.map((patient) => patient.toAnonymousExport()).toList();
  }
}