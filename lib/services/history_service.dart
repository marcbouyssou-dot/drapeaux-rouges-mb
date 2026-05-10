import 'local_database_service.dart';

class HistoryService {
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    return LocalDatabaseService.getEvaluations();
  }

  static Future<void> saveEvaluation({
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> evaluation,
  }) async {
    history.insert(0, evaluation);

    await LocalDatabaseService.saveEvaluation(evaluation);
  }

  static Future<void> clearHistory() async {
    await LocalDatabaseService.clearEvaluations();
  }
}