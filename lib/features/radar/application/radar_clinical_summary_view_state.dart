import '../../../models/clinical_screening/clinical_screening_models.dart';
import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_status.dart';
import 'radar_clinical_stop_policy.dart';
import 'radar_decision_view_data.dart';

class RadarClinicalSummaryViewState {
  RadarClinicalSummaryViewState({
    required this.sessionId,
    required this.region,
    required this.status,
    required this.decision,
    required this.regionalOutcome,
    required this.endReason,
    required List<RadarClinicalQuestionSummary> questions,
    required Set<RadarContextGate> contextGates,
    required Set<RadarClinicalTrigger> clinicalTriggers,
    required List<RadarContextActivationTrace> contextActivations,
    required List<String> positiveFlagIds,
    required List<String> reassuringFlagIds,
    required this.hardStopId,
    required this.hardStopTitle,
    required this.primaryHypothesisId,
    required this.primaryHypothesisTitle,
    required this.shortExplanation,
    required this.matrixVersion,
    required this.validationStatus,
    required this.operatingMode,
    required this.engineVersion,
  }) : questions = List.unmodifiable(questions),
       contextGates = Set.unmodifiable(contextGates),
       clinicalTriggers = Set.unmodifiable(clinicalTriggers),
       contextActivations = List.unmodifiable(contextActivations),
       positiveFlagIds = List.unmodifiable(positiveFlagIds),
       reassuringFlagIds = List.unmodifiable(reassuringFlagIds);

  final String sessionId;
  final RadarClinicalRegion region;
  final RadarClinicalStatus status;
  final RadarDecisionViewData? decision;
  final RadarSessionOutcome? regionalOutcome;
  final String endReason;
  final List<RadarClinicalQuestionSummary> questions;
  final Set<RadarContextGate> contextGates;
  final Set<RadarClinicalTrigger> clinicalTriggers;
  final List<RadarContextActivationTrace> contextActivations;
  final List<String> positiveFlagIds;
  final List<String> reassuringFlagIds;
  final String? hardStopId;
  final String? hardStopTitle;
  final String? primaryHypothesisId;
  final String? primaryHypothesisTitle;
  final String shortExplanation;
  final String matrixVersion;
  final String validationStatus;
  final RadarClinicalOperatingMode operatingMode;
  final String engineVersion;

  ClinicalDecisionLevel? get decisionLevel => decision?.decisionLevel;

  List<RadarClinicalQuestionSummary> get positiveAnswers =>
      questions.where((question) => question.isPositive).toList();

  List<RadarClinicalQuestionSummary> get negativeAnswers =>
      questions.where((question) => !question.isPositive).toList();
}

class RadarClinicalQuestionSummary {
  const RadarClinicalQuestionSummary({
    required this.questionId,
    required this.text,
    required this.isPositive,
  });

  final String questionId;
  final String text;
  final bool isPositive;
}
