import '../models/evaluation_model.dart';
import 'clinical_reasoning_service.dart';
import 'local_database_service.dart';
import 'offline_sync_service.dart';

class HistoryService {
  static Future<List<Map<String, dynamic>>> loadHistory() async {
    return LocalDatabaseService.getEvaluations();
  }

  static Future<void> saveEvaluation({
    required List<Map<String, dynamic>> history,
    required Map<String, dynamic> evaluation,
  }) async {
    final enrichedEvaluation = Map<String, dynamic>.from(evaluation);
    enrichedEvaluation['clinicalReasoning'] ??= ClinicalReasoningService()
        .buildFromEvaluation(
          evaluation: EvaluationModel.fromJson(enrichedEvaluation),
        )
        .toJson();
    await OfflineSyncService().enrichForLocalSave(enrichedEvaluation);

    await LocalDatabaseService.saveEvaluation(enrichedEvaluation);
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
