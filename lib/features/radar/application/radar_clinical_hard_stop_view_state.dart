import '../../../models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import '../../../models/clinical_screening/clinical_screening_models.dart';
import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_stop_policy.dart';

class RadarClinicalHardStopViewState {
  RadarClinicalHardStopViewState({
    required this.sessionId,
    required this.region,
    required this.hardStopState,
    required this.hardStopId,
    required this.hardStopTitle,
    required this.clinicalFamilyId,
    required this.decisionLevel,
    required List<String> criticalArguments,
    required List<String> contributingQuestionIds,
    required this.triggeringQuestionId,
    required this.stopReason,
    required this.regionalOutcome,
    required Set<RadarContextGate> contextGates,
    required Set<RadarClinicalTrigger> clinicalTriggers,
    required this.engineVersion,
    required this.matrixVersion,
    required this.validationStatus,
    required this.operatingMode,
  }) : criticalArguments = List.unmodifiable(criticalArguments),
       contributingQuestionIds = List.unmodifiable(contributingQuestionIds),
       contextGates = Set.unmodifiable(contextGates),
       clinicalTriggers = Set.unmodifiable(clinicalTriggers);

  final String sessionId;
  final RadarClinicalRegion region;
  final ClinicalHardStopStateV5 hardStopState;
  final String? hardStopId;
  final String? hardStopTitle;
  final String? clinicalFamilyId;
  final ClinicalDecisionLevel? decisionLevel;
  final List<String> criticalArguments;
  final List<String> contributingQuestionIds;
  final String? triggeringQuestionId;
  final String stopReason;
  final RadarSessionOutcome? regionalOutcome;
  final Set<RadarContextGate> contextGates;
  final Set<RadarClinicalTrigger> clinicalTriggers;
  final String engineVersion;
  final String matrixVersion;
  final String validationStatus;
  final RadarClinicalOperatingMode operatingMode;
}
