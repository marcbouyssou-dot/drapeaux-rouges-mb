import 'clinical_probability_update_v5.dart';
import 'clinical_screening_models.dart';

class ClinicalAdaptiveViewStateV5 {
  final String sessionId;
  final String? questionId;
  final String? patientQuestionText;
  final bool canAnswer;
  final int answeredCount;
  final int totalQuestionCount;
  final double progressRatio;
  final String progressLabel;
  final ClinicalDecisionLevel currentRiskLevel;
  final String currentRiskLabel;
  final String? hardStopId;
  final String? hardStopTitle;
  final ClinicalDecisionLevel? finalDecisionLevel;
  final String? finalDecisionLabel;
  final String? primaryHypothesisId;
  final String? primaryHypothesisTitle;
  final ClinicalQualitativeProbabilityV5? probabilityLevel;
  final String shortExplanation;
  final String technicalSummary;
  final bool isFinal;

  const ClinicalAdaptiveViewStateV5({
    required this.sessionId,
    required this.questionId,
    required this.patientQuestionText,
    required this.canAnswer,
    required this.answeredCount,
    required this.totalQuestionCount,
    required this.progressRatio,
    required this.progressLabel,
    required this.currentRiskLevel,
    required this.currentRiskLabel,
    required this.hardStopId,
    required this.hardStopTitle,
    required this.finalDecisionLevel,
    required this.finalDecisionLabel,
    required this.primaryHypothesisId,
    required this.primaryHypothesisTitle,
    required this.probabilityLevel,
    required this.shortExplanation,
    required this.technicalSummary,
    required this.isFinal,
  });
}
