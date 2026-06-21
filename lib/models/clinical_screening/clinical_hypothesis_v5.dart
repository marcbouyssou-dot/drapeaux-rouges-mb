import 'clinical_screening_models.dart';
import 'clinical_screening_question_v4.dart';

enum ClinicalHypothesisSeverityV5 {
  moderate,
  serious,
  potentiallyLifeThreatening,
}

enum ClinicalHypothesisInitialProbabilityV5 { low, moderate, high }

class ClinicalHypothesisV5 {
  final String id;
  final String title;
  final String clinicalDescription;
  final ClinicalHypothesisSeverityV5 severity;
  final ClinicalDecisionLevel targetDecisionLevel;
  final ClinicalHypothesisInitialProbabilityV5 initialProbability;
  final List<String> associatedClusterIds;
  final List<String> associatedFlagIds;
  final List<ClinicalScientificSource> scientificSources;
  final List<String> validationCaseIds;

  const ClinicalHypothesisV5({
    required this.id,
    required this.title,
    required this.clinicalDescription,
    required this.severity,
    required this.targetDecisionLevel,
    required this.initialProbability,
    required this.associatedClusterIds,
    required this.associatedFlagIds,
    required this.scientificSources,
    required this.validationCaseIds,
  });
}
