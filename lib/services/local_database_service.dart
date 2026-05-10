import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseService {
  static const String evaluationsKey = 'evaluations';

  static Future<List<Map<String, dynamic>>> getEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(evaluationsKey);

    if (raw == null) {
      return [];
    }

    final decoded = jsonDecode(raw);

    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> saveEvaluation(
    Map<String, dynamic> evaluation,
  ) async {
    final evaluations = await getEvaluations();

    evaluations.insert(0, evaluation);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      evaluationsKey,
      jsonEncode(evaluations),
    );
  }

  static Future<void> clearEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(evaluationsKey);
  }
}