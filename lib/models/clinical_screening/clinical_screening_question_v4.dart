import 'clinical_screening_models.dart';

enum ClinicalEvidenceLevel {
  expertConsensus,
  clinicalGuideline,
  systematicReview,
  validatedClinicalRule,
}

enum ClinicalQuestionResponseType { yesNo, singleChoice, multipleChoice }

class ClinicalScientificSource {
  final String id;
  final String title;
  final String organization;
  final String reference;
  final String? url;

  const ClinicalScientificSource({
    required this.id,
    required this.title,
    required this.organization,
    required this.reference,
    this.url,
  });
}

class ClinicalScreeningQuestionV4 {
  final String id;
  final String text;
  final String clinicalIntent;
  final String associatedFlagId;
  final String clusterId;
  final String ruleId;
  final ClinicalScreeningLayer layer;
  final ClinicalFlagCategory category;
  final ClinicalQuestionResponseType responseType;
  final ClinicalDecisionLevel potentialDecisionLevel;
  final ClinicalEvidenceLevel evidenceLevel;
  final Duration targetResponseTime;
  final List<String> tags;
  final List<ClinicalScientificSource> scientificSources;
  final String? scriptId;

  const ClinicalScreeningQuestionV4({
    required this.id,
    required this.text,
    required this.clinicalIntent,
    required this.associatedFlagId,
    required this.clusterId,
    required this.ruleId,
    required this.layer,
    required this.category,
    required this.responseType,
    required this.potentialDecisionLevel,
    required this.evidenceLevel,
    required this.targetResponseTime,
    required this.tags,
    required this.scientificSources,
    this.scriptId,
  });
}
