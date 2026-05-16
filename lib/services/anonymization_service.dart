import '../models/evaluation_model.dart';
import '../models/patient_local.dart';

class AnonymizationService {
  static Map<String, dynamic> buildAnonymousStatisticsPayload({
    required EvaluationModel evaluation,
    required PatientLocal? patient,
  }) {
    return {
      'schemaVersion': 1,
      'anonymousEvaluationId': evaluation.evaluationId,
      'anonymousPatientId': evaluation.patientAnonymousId,
      'dateMonth': _monthOnly(evaluation.date),
      'motif': evaluation.motif,
      'score': evaluation.score,
      'riskLevel': evaluation.riskLevel,
      'checkedCount': evaluation.checkedCount,
      'checkedFlags': _anonymousFlags(evaluation.checkedFlags),
      'ageRange': patient == null ? null : _ageRange(patient.dateNaissance),
      'consentementValide': patient?.consentementValide ?? false,
    };
  }

  static List<Map<String, dynamic>> _anonymousFlags(
    List<Map<String, dynamic>> flags,
  ) {
    return flags.map((flag) {
      return {
        'severity': flag['severity'],
        'tags': flag['tags'] ?? [],
      };
    }).toList();
  }

  static String _monthOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  static String? _ageRange(String dateNaissance) {
    final birthDate = _parseFrenchDate(dateNaissance);
    if (birthDate == null) return null;

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    if (age < 18) return '<18';
    if (age <= 29) return '18-29';
    if (age <= 39) return '30-39';
    if (age <= 49) return '40-49';
    if (age <= 59) return '50-59';
    if (age <= 69) return '60-69';
    if (age <= 79) return '70-79';

    return '80+';
  }

  static DateTime? _parseFrenchDate(String value) {
    final parts = value.trim().split('/');

    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }
}