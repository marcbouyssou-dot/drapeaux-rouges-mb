import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('history');

    if (raw == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      jsonDecode(raw),
    );
  }

  static Future<void> saveEvaluation({
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> evaluation,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    history.insert(0, evaluation);

    await prefs.setString(
      'history',
      jsonEncode(history),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('history');
  }
}