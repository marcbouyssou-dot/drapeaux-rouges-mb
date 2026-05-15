import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/anonymous_clinical_record.dart';

class AnonymousRecordStorageService {
  static const String _recordsKey = 'anonymous_clinical_records';

  static Future<void> saveRecord(AnonymousClinicalRecord record) async {
    final prefs = await SharedPreferences.getInstance();

    final records = await getRecords();
    records.add(record);

    final encoded = records.map((record) => record.toJson()).toList();

    await prefs.setString(_recordsKey, jsonEncode(encoded));
  }

  static Future<List<AnonymousClinicalRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recordsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(raw);

    return decoded
        .map(
          (item) => AnonymousClinicalRecord.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<List<AnonymousClinicalRecord>> getRecordsForPatient(
    String anonymousPatientId,
  ) async {
    final records = await getRecords();

    return records
        .where((record) => record.anonymousPatientId == anonymousPatientId)
        .toList();
  }

  static Future<void> deleteAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }

  static Future<List<Map<String, dynamic>>> getAnonymousExportData() async {
    final records = await getRecords();

    return records.map((record) => record.toJson()).toList();
  }
}