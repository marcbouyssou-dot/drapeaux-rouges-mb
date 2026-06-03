import 'package:hive/hive.dart';

class LocalDatabaseService {
  static const String _evaluationsBoxName = 'evaluations_box';

  static Box get _box => Hive.box(_evaluationsBoxName);

  static Future<List<Map<String, dynamic>>> getEvaluations() async {
    final values = _box.values.toList();

    final evaluations = values.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();

    evaluations.sort((a, b) {
      final dateA =
          DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime(1900);
      final dateB =
          DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime(1900);

      return dateB.compareTo(dateA);
    });

    return evaluations;
  }

  static Future<void> saveEvaluation(Map<String, dynamic> evaluation) async {
    final evaluationId = evaluation['evaluationId']?.toString();

    if (evaluationId == null || evaluationId.isEmpty) {
      throw Exception(
        'Evaluation impossible à sauvegarder : evaluationId manquant.',
      );
    }

    await _box.put(evaluationId, evaluation);
  }

  static Future<void> deleteEvaluation(String evaluationId) async {
    if (evaluationId.isEmpty) return;

    await _box.delete(evaluationId);
  }

  static Future<void> anonymizeEvaluationsForPatient(
    String patientLocalId,
  ) async {
    if (patientLocalId.isEmpty) return;

    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is! Map) continue;

      final evaluation = Map<String, dynamic>.from(raw);
      if (evaluation['patientLocalId']?.toString() != patientLocalId) {
        continue;
      }

      evaluation['patientLocalId'] = null;
      evaluation['patientDisplayName'] = 'Patient non renseigné';

      await _box.put(key, evaluation);
    }
  }

  static Future<void> clearEvaluations() async {
    await _box.clear();
  }

  static Future<List<Map<String, dynamic>>> getEvaluationsForPatient(
    String patientLocalId,
  ) async {
    final evaluations = await getEvaluations();

    return evaluations.where((item) {
      return item['patientLocalId']?.toString() == patientLocalId;
    }).toList();
  }
}
