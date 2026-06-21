import 'clinical_hypothesis_v5.dart';
import 'clinical_screening_models.dart';
import 'clinical_screening_questionnaire_v4.dart';

abstract final class ClinicalHypothesisCatalogV5 {
  static const hypotheses = [
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_queue_cheval',
      title: 'Syndrome de la queue de cheval',
      clinicalDescription:
          'Compression neurologique lombo-sacrée avec troubles sphinctériens, anesthésie en selle ou déficit neurologique sévère.',
      severity: ClinicalHypothesisSeverityV5.potentiallyLifeThreatening,
      targetDecisionLevel: ClinicalDecisionLevel.emergency,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.low,
      associatedClusterIds: ['immediateDanger'],
      associatedFlagIds: ['queue_cheval_suspected'],
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseIds: ['HS_CAUDA_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_embolie_pulmonaire',
      title: 'Embolie pulmonaire',
      clinicalDescription:
          'Événement thromboembolique suspecté devant dyspnée brutale, douleur thoracique, malaise ou signes cardio-respiratoires.',
      severity: ClinicalHypothesisSeverityV5.potentiallyLifeThreatening,
      targetDecisionLevel: ClinicalDecisionLevel.emergency,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.low,
      associatedClusterIds: ['immediateDanger'],
      associatedFlagIds: ['pulmonary_embolism_suspected'],
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.pulmonaryEmbolismSource,
      ],
      validationCaseIds: ['HS_PE_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_fracture_ouverte',
      title: 'Fracture ouverte',
      clinicalDescription:
          'Solution de continuité cutanée ou suspicion d’exposition osseuse après traumatisme.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.emergency,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.low,
      associatedClusterIds: ['immediateDanger'],
      associatedFlagIds: ['open_fracture_suspected'],
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.ottawaAnkleRulesSource,
      ],
      validationCaseIds: ['HS_OPEN_FRACTURE_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_pathologie_oncologique',
      title: 'Pathologie oncologique sous-jacente',
      clinicalDescription:
          'Pathologie tumorale ou récidive possible en présence d’un contexte oncologique associé à des signes généraux ou nocturnes.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.low,
      associatedClusterIds: ['oncologicCluster'],
      associatedFlagIds: ['oncologic_context', 'weight_loss_or_night_pain'],
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.suspectedCancerSource,
      ],
      validationCaseIds: ['HS_ONCO_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_infection_systemique_fragile',
      title: 'Infection systémique sur terrain fragile',
      clinicalDescription:
          'Infection potentiellement sérieuse lorsque les signes infectieux s’associent à une immunodépression ou une infection récente.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.moderate,
      associatedClusterIds: ['infectiousCluster'],
      associatedFlagIds: ['fever_or_chills', 'immunosuppression'],
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseIds: ['HS_INFECTIOUS_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_atteinte_neurologique_progressive',
      title: 'Atteinte neurologique progressive',
      clinicalDescription:
          'Atteinte neurologique sérieuse possible devant un déficit moteur progressif ou des signes neurologiques centraux.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.moderate,
      associatedClusterIds: ['neurologicCluster'],
      associatedFlagIds: ['progressive_motor_deficit'],
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseIds: ['HS_NEURO_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
      title: 'Syndrome cardio-respiratoire aigu',
      clinicalDescription:
          'Atteinte cardio-respiratoire urgente possible lorsque la douleur thoracique s’associe à dyspnée, malaise ou syncope.',
      severity: ClinicalHypothesisSeverityV5.potentiallyLifeThreatening,
      targetDecisionLevel: ClinicalDecisionLevel.emergency,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.low,
      associatedClusterIds: ['cardiorespiratoryCluster'],
      associatedFlagIds: ['chest_pain', 'dyspnea_or_malaise'],
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.pulmonaryEmbolismSource,
      ],
      validationCaseIds: ['HS_CARDIO_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_fracture_fragilite',
      title: 'Fracture sur terrain de fragilité',
      clinicalDescription:
          'Fracture significative possible après traumatisme ou chute chez un patient présentant une fragilité osseuse.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.moderate,
      associatedClusterIds: ['fractureRiskCluster'],
      associatedFlagIds: ['trauma_or_fall', 'bone_fragility'],
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.ottawaAnkleRulesSource,
      ],
      validationCaseIds: ['HS_FRACTURE_RISK_001'],
    ),
    ClinicalHypothesisV5(
      id: 'v5_hypothesis_tvp',
      title: 'Thrombose veineuse profonde',
      clinicalDescription:
          'Suspicion de TVP ou d’atteinte vasculaire devant douleur du mollet, œdème, asymétrie ou facteurs de risque compatibles.',
      severity: ClinicalHypothesisSeverityV5.serious,
      targetDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      initialProbability: ClinicalHypothesisInitialProbabilityV5.moderate,
      associatedClusterIds: ['vascularCluster'],
      associatedFlagIds: ['vascular_tvp_context'],
      scientificSources: [ClinicalScreeningQuestionnaireV4.wellsDvtSource],
      validationCaseIds: ['HS_TVP_001'],
    ),
  ];

  static Set<String> get hypothesisIds {
    return hypotheses.map((hypothesis) => hypothesis.id).toSet();
  }

  static Set<String> get associatedClusterIds {
    return hypotheses
        .expand((hypothesis) => hypothesis.associatedClusterIds)
        .toSet();
  }

  static Set<String> get associatedFlagIds {
    return hypotheses
        .expand((hypothesis) => hypothesis.associatedFlagIds)
        .toSet();
  }

  static Set<String> get validationCaseIds {
    return hypotheses
        .expand((hypothesis) => hypothesis.validationCaseIds)
        .toSet();
  }

  static List<ClinicalHypothesisV5> hypothesesForCluster(String clusterId) {
    return hypotheses
        .where(
          (hypothesis) => hypothesis.associatedClusterIds.contains(clusterId),
        )
        .toList(growable: false);
  }
}
