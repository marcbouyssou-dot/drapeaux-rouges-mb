import '../models/evaluation_model.dart';
import '../models/patient_local.dart';
import 'anonymization_service.dart';
import 'local_database_service.dart';
import 'rgpd_local_service.dart';

class StatisticsExportService {
  static Future<List<Map<String, dynamic>>> buildAnonymousStatisticsExport() async {
    final rawEvaluations = await LocalDatabaseService.getEvaluations();

    final evaluations = rawEvaluations
        .map((item) => EvaluationModel.fromJson(item))
        .toList();

    final patients = await RgpdLocalService.getPatients();

    return evaluations.map((evaluation) {
      PatientLocal? patient;

      try {
        patient = patients.firstWhere(
          (p) => p.localId == evaluation.patientLocalId,
        );
      } catch (_) {
        patient = null;
      }

      return AnonymizationService.buildAnonymousStatisticsPayload(
        evaluation: evaluation,
        patient: patient,
      );
    }).toList();
  }
}