enum ClinicalQualitativeProbabilityV5 { veryLow, low, moderate, high, veryHigh }

enum ClinicalProbabilityImpactV5 { decrease, none, increase, strongIncrease }

class ClinicalProbabilityUpdateV5 {
  final String id;
  final String hypothesisId;
  final String? triggerQuestionId;
  final String? triggerFlagId;
  final ClinicalProbabilityImpactV5 impact;
  final ClinicalQualitativeProbabilityV5 priorProbability;
  final ClinicalQualitativeProbabilityV5 updatedProbability;
  final String clinicalRationale;

  const ClinicalProbabilityUpdateV5({
    required this.id,
    required this.hypothesisId,
    this.triggerQuestionId,
    this.triggerFlagId,
    required this.impact,
    required this.priorProbability,
    required this.updatedProbability,
    required this.clinicalRationale,
  }) : assert(
         triggerQuestionId != null || triggerFlagId != null,
         'A probability update must reference a question or a flag.',
       );
}
