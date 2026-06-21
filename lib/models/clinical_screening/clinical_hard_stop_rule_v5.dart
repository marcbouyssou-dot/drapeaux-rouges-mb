import 'clinical_screening_models.dart';
import 'clinical_screening_question_v4.dart';

class ClinicalHardStopRuleV5 {
  final String id;
  final String title;
  final String clinicalDescription;
  final List<String> triggeringQuestionIds;
  final List<String> triggeringFlagIds;
  final String clusterId;
  final ClinicalDecisionLevel expectedDecisionLevel;
  final String clinicalRationale;
  final List<ClinicalScientificSource> scientificSources;
  final String validationCaseId;

  const ClinicalHardStopRuleV5({
    required this.id,
    required this.title,
    required this.clinicalDescription,
    required this.triggeringQuestionIds,
    required this.triggeringFlagIds,
    required this.clusterId,
    required this.expectedDecisionLevel,
    required this.clinicalRationale,
    required this.scientificSources,
    required this.validationCaseId,
  });
}
