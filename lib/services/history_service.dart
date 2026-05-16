import 'local_database_service.dart';

class HistoryService {
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    return LocalDatabaseService.getEvaluations();
  }

  static Future<void> saveEvaluation({
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> evaluation,
  }) async {
    await LocalDatabaseService.saveEvaluation(evaluation);
  }

  static Future<void> deleteEvaluation(String evaluationId) async {
    await LocalDatabaseService.deleteEvaluation(evaluationId);
  }

  static Future<List<Map<String, dynamic>>> loadHistoryForPatient(
    String patientLocalId,
  ) async {
    return LocalDatabaseService.getEvaluationsForPatient(patientLocalId);
  }

  static Future<void> clearHistory() async {
    await LocalDatabaseService.clearEvaluations();
  }
}