import 'clinical_screening_catalog.dart';
import 'clinical_screening_models.dart';
import 'clinical_screening_question_v4.dart';
import 'clinical_screening_tags.dart';

abstract final class ClinicalScreeningQuestionnaireV4 {
  static const lowBackPainSource = ClinicalScientificSource(
    id: 'has_low_back_pain_2023',
    title: 'Low back pain and sciatica in over 16s',
    organization: 'NICE',
    reference: 'NICE guideline NG59, updated 2020',
    url: 'https://www.nice.org.uk/guidance/ng59',
  );

  static const suspectedCancerSource = ClinicalScientificSource(
    id: 'nice_suspected_cancer_2025',
    title: 'Suspected cancer: recognition and referral',
    organization: 'NICE',
    reference: 'NICE guideline NG12, updated 2025',
    url: 'https://www.nice.org.uk/guidance/ng12',
  );

  static const pulmonaryEmbolismSource = ClinicalScientificSource(
    id: 'esc_pulmonary_embolism_2019',
    title: 'Guidelines for diagnosis and management of pulmonary embolism',
    organization: 'European Society of Cardiology',
    reference: 'European Heart Journal, 2019',
    url: 'https://academic.oup.com/eurheartj/article/41/4/543/5556136',
  );

  static const ottawaAnkleRulesSource = ClinicalScientificSource(
    id: 'ottawa_ankle_rules',
    title: 'Ottawa ankle rules',
    organization: 'Clinical decision rule literature',
    reference: 'Stiell et al., BMJ, 1992',
  );

  static const wellsDvtSource = ClinicalScientificSource(
    id: 'wells_dvt_rule',
    title: 'Clinical model for deep-vein thrombosis',
    organization: 'Clinical decision rule literature',
    reference: 'Wells et al., Lancet, 1997',
  );

  static const sources = [
    lowBackPainSource,
    suspectedCancerSource,
    pulmonaryEmbolismSource,
    ottawaAnkleRulesSource,
    wellsDvtSource,
  ];

  static const questions = [
    ClinicalScreeningQuestionV4(
      id: 'v4_queue_cheval_001',
      text:
          'Avez-vous des troubles urinaires ou fécaux nouveaux, une anesthésie en selle ou une faiblesse importante des jambes ?',
      clinicalIntent:
          'Repérer une suspicion de syndrome de la queue de cheval.',
      associatedFlagId: 'queue_cheval_suspected',
      clusterId: 'immediateDanger',
      ruleId: 'immediateDanger',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.neurological,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.emergency,
      evidenceLevel: ClinicalEvidenceLevel.clinicalGuideline,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.queueCheval],
      scientificSources: [lowBackPainSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_embolie_pulmonaire_001',
      text:
          'Avez-vous eu un essoufflement brutal, une douleur thoracique, un malaise ou des palpitations inhabituelles ?',
      clinicalIntent:
          'Repérer une suspicion cardio-respiratoire compatible avec une embolie pulmonaire.',
      associatedFlagId: 'pulmonary_embolism_suspected',
      clusterId: 'immediateDanger',
      ruleId: 'immediateDanger',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.respiratory,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.emergency,
      evidenceLevel: ClinicalEvidenceLevel.clinicalGuideline,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.emboliePulmonaire],
      scientificSources: [pulmonaryEmbolismSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_fracture_ouverte_001',
      text:
          'Existe-t-il une plaie, une déformation évidente ou une suspicion d’os exposé après le traumatisme ?',
      clinicalIntent: 'Repérer une suspicion de fracture ouverte.',
      associatedFlagId: 'open_fracture_suspected',
      clusterId: 'immediateDanger',
      ruleId: 'immediateDanger',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.musculoskeletal,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.emergency,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 15),
      tags: [ClinicalScreeningTags.fractureOuverte],
      scientificSources: [ottawaAnkleRulesSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_oncologic_context_001',
      text:
          'Avez-vous un cancer actif, un traitement récent, une perte de poids inexpliquée ou des douleurs nocturnes non mécaniques ?',
      clinicalIntent:
          'Repérer l’association contexte oncologique et signes généraux.',
      associatedFlagId: 'oncologic_context',
      clusterId: 'oncologicCluster',
      ruleId: 'oncologicCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.general,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.clinicalGuideline,
      targetResponseTime: Duration(seconds: 30),
      tags: [
        ClinicalScreeningTags.cancer,
        ClinicalScreeningTags.pertePoids,
        ClinicalScreeningTags.douleurNocturne,
      ],
      scientificSources: [suspectedCancerSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_infectious_fragility_001',
      text:
          'Avez-vous de la fièvre, des frissons ou des sueurs nocturnes avec immunodépression ou infection récente ?',
      clinicalIntent: 'Repérer un cluster infectieux sur terrain fragile.',
      associatedFlagId: 'fever_or_chills',
      clusterId: 'infectiousCluster',
      ruleId: 'infectiousCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.infectious,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 25),
      tags: [
        ClinicalScreeningTags.fievre,
        ClinicalScreeningTags.immunodepression,
      ],
      scientificSources: [lowBackPainSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_neurologic_deficit_001',
      text:
          'Avez-vous une faiblesse qui progresse, une perte de force ou des troubles neurologiques récents ?',
      clinicalIntent: 'Repérer un déficit moteur progressif.',
      associatedFlagId: 'progressive_motor_deficit',
      clusterId: 'neurologicCluster',
      ruleId: 'neurologicCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.neurological,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.clinicalGuideline,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.deficitMoteurProgressif],
      scientificSources: [lowBackPainSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_cardiorespiratory_001',
      text:
          'La douleur thoracique est-elle associée à un essoufflement, un malaise ou une syncope ?',
      clinicalIntent: 'Repérer une association cardio-respiratoire urgente.',
      associatedFlagId: 'chest_pain',
      clusterId: 'cardiorespiratoryCluster',
      ruleId: 'cardiorespiratoryCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.cardiovascular,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.emergency,
      evidenceLevel: ClinicalEvidenceLevel.clinicalGuideline,
      targetResponseTime: Duration(seconds: 20),
      tags: [
        ClinicalScreeningTags.douleurThoracique,
        ClinicalScreeningTags.dyspnee,
        ClinicalScreeningTags.malaise,
        ClinicalScreeningTags.syncope,
      ],
      scientificSources: [pulmonaryEmbolismSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_fracture_risk_001',
      text:
          'La douleur fait-elle suite à une chute ou un traumatisme avec ostéoporose, corticothérapie prolongée ou âge avancé ?',
      clinicalIntent: 'Repérer un risque fracturaire sur terrain fragile.',
      associatedFlagId: 'trauma_or_fall',
      clusterId: 'fractureRiskCluster',
      ruleId: 'fractureRiskCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.musculoskeletal,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.validatedClinicalRule,
      targetResponseTime: Duration(seconds: 25),
      tags: [
        ClinicalScreeningTags.traumatisme,
        ClinicalScreeningTags.osteoporose,
        ClinicalScreeningTags.corticotherapieProlongee,
        ClinicalScreeningTags.ageAvance,
      ],
      scientificSources: [ottawaAnkleRulesSource],
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_vascular_tvp_001',
      text:
          'Existe-t-il une douleur du mollet, un œdème, une asymétrie ou des facteurs de risque de TVP ?',
      clinicalIntent: 'Repérer un cluster TVP ou vasculaire.',
      associatedFlagId: 'vascular_tvp_context',
      clusterId: 'vascularCluster',
      ruleId: 'vascularCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.validatedClinicalRule,
      targetResponseTime: Duration(seconds: 30),
      tags: [ClinicalScreeningTags.wellsTvp, ClinicalScreeningTags.tvp],
      scientificSources: [wellsDvtSource],
    ),
  ];

  static List<ClinicalScreeningQuestionV4> questionsForRule(String ruleId) {
    return questions
        .where((question) => question.ruleId == ruleId)
        .toList(growable: false);
  }

  static Set<String> get questionIds {
    return questions.map((question) => question.id).toSet();
  }

  static Set<String> get referencedFlagIds {
    return questions.map((question) => question.associatedFlagId).toSet();
  }

  static Set<String> get referencedRuleIds {
    return questions.map((question) => question.ruleId).toSet();
  }

  static Set<String> get catalogFlagIds {
    return ClinicalScreeningCatalog.flagDefinitions
        .map((definition) => definition.id)
        .toSet();
  }

  static Set<String> get catalogRuleIds {
    return ClinicalScreeningCatalog.ruleIds;
  }
}
