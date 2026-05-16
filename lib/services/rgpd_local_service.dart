import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/patient_local.dart';

class RgpdLocalService {
  static const String _patientsBoxName = 'patients_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _currentPatientIdKey = 'current_patient_local_id';

  static Box get _patientsBox => Hive.box(_patientsBoxName);
  static Box get _settingsBox => Hive.box(_settingsBoxName);

  static String createAnonymousId() {
    const uuid = Uuid();
    return 'DR-${uuid.v4()}';
  }

  static String createLocalId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  static Future<void> savePatient(PatientLocal patient) async {
    await saveOrUpdatePatient(patient);
  }

  static Future<void> saveOrUpdatePatient(PatientLocal patient) async {
    await _patientsBox.put(patient.localId, patient.toJson());
    await setCurrentPatientId(patient.localId);
  }

  static Future<List<PatientLocal>> getPatients() async {
    final patients = _patientsBox.values.map((item) {
      return PatientLocal.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();

    patients.sort((a, b) {
      final nomCompare = a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      if (nomCompare != 0) return nomCompare;
      return a.prenom.toLowerCase().compareTo(b.prenom.toLowerCase());
    });

    return patients;
  }

  static Future<List<PatientLocal>> getPatientsSortedAlphabetically() async {
    return getPatients();
  }

  static Future<void> setCurrentPatientId(String localId) async {
    await _settingsBox.put(_currentPatientIdKey, localId);
  }

  static Future<String?> getCurrentPatientId() async {
    return _settingsBox.get(_currentPatientIdKey)?.toString();
  }

  static Future<PatientLocal?> getCurrentPatient() async {
    final currentId = await getCurrentPatientId();

    if (currentId == null || currentId.isEmpty) {
      return null;
    }

    return getPatientByLocalId(currentId);
  }

  static Future<PatientLocal?> getPatientByLocalId(String localId) async {
    final raw = _patientsBox.get(localId);

    if (raw == null) return null;

    return PatientLocal.fromJson(
      Map<String, dynamic>.from(raw as Map),
    );
  }

  static Future<void> clearCurrentPatient() async {
    await _settingsBox.delete(_currentPatientIdKey);
  }

  static Future<void> deletePatient(String localId) async {
    await _patientsBox.delete(localId);

    final currentId = await getCurrentPatientId();

    if (currentId == localId) {
      await clearCurrentPatient();
    }
  }

  static Future<void> deleteAllLocalData() async {
    await _patientsBox.clear();
    await clearCurrentPatient();
  }

  static Future<List<Map<String, dynamic>>> getAnonymousExportData() async {
    final patients = await getPatients();

    return patients.map((patient) => patient.toAnonymousExport()).toList();
  }

  static String patientDisplayName(PatientLocal? patient) {
    if (patient == null) return 'Patient non renseigné';

    final nom = patient.nom.trim().toUpperCase();
    final prenom = patient.prenom.trim();

    if (nom.isEmpty && prenom.isEmpty) {
      return 'Patient non renseigné';
    }

    return '$nom $prenom'.trim();
  }
}