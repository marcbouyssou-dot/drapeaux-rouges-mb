import 'clinical_hard_stop_rule_v5.dart';
import 'clinical_screening_models.dart';
import 'clinical_screening_questionnaire_v4.dart';

abstract final class ClinicalHardStopCatalogV5 {
  static const rules = [
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_queue_cheval',
      title: 'Suspicion de syndrome de la queue de cheval',
      clinicalDescription:
          'Troubles sphinctériens, anesthésie en selle ou déficit neurologique compatible avec une atteinte compressive urgente.',
      triggeringQuestionIds: ['v4_queue_cheval_001'],
      triggeringFlagIds: ['queue_cheval_suspected'],
      clusterId: 'immediateDanger',
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
      state: ClinicalHardStopStateV5.confirmed,
      clinicalRationale:
          'Une suspicion de queue de cheval est un hard stop car le délai d’orientation conditionne le pronostic neurologique.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseId: 'validation_v5_queue_cheval_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_embolie_pulmonaire',
      title: 'Suspicion d’embolie pulmonaire',
      clinicalDescription:
          'Dyspnée brutale, douleur thoracique, malaise ou tachycardie évoquant une complication embolique.',
      triggeringQuestionIds: ['v4_embolie_pulmonaire_001'],
      triggeringFlagIds: ['pulmonary_embolism_suspected'],
      clusterId: 'immediateDanger',
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
      state: ClinicalHardStopStateV5.confirmed,
      clinicalRationale:
          'La suspicion embolique ne doit pas être poursuivie en accès direct et impose une orientation urgente.',
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.pulmonaryEmbolismSource,
      ],
      validationCaseId: 'validation_v5_embolie_pulmonaire_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_fracture_ouverte',
      title: 'Suspicion de fracture ouverte',
      clinicalDescription:
          'Plaie, déformation ou suspicion d’exposition osseuse après traumatisme.',
      triggeringQuestionIds: ['v4_fracture_ouverte_001'],
      triggeringFlagIds: ['open_fracture_suspected'],
      clusterId: 'immediateDanger',
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
      state: ClinicalHardStopStateV5.confirmed,
      clinicalRationale:
          'Une fracture ouverte expose à des complications infectieuses et neurovasculaires et impose une prise en charge urgente.',
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.ottawaAnkleRulesSource,
      ],
      validationCaseId: 'validation_v5_fracture_ouverte_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_oncologique',
      title: 'Cluster oncologique préoccupant',
      clinicalDescription:
          'Contexte oncologique associé à perte de poids, douleur nocturne ou altération de l’état général.',
      triggeringQuestionIds: ['v4_oncologic_context_001'],
      triggeringFlagIds: ['oncologic_context', 'weight_loss_or_night_pain'],
      clusterId: 'oncologicCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      clinicalRationale:
          'L’association d’un contexte oncologique et de signes généraux ou nocturnes ne permet pas d’exclure une pathologie sérieuse.',
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.suspectedCancerSource,
      ],
      validationCaseId: 'validation_v5_oncologic_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_infectieux_fragile',
      title: 'Cluster infectieux sur terrain fragile',
      clinicalDescription:
          'Fièvre, frissons ou sueurs nocturnes associés à immunodépression ou infection récente.',
      triggeringQuestionIds: ['v4_infectious_fragility_001'],
      triggeringFlagIds: ['fever_or_chills', 'immunosuppression'],
      clusterId: 'infectiousCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      clinicalRationale:
          'L’association de signes infectieux et d’un terrain fragile abaisse le seuil d’orientation médicale impérative.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseId: 'validation_v5_infectious_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_neurologique',
      title: 'Déficit moteur progressif',
      clinicalDescription:
          'Faiblesse progressive, perte de force ou signes neurologiques récents.',
      triggeringQuestionIds: ['v4_neurologic_deficit_001'],
      triggeringFlagIds: ['progressive_motor_deficit'],
      clusterId: 'neurologicCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      clinicalRationale:
          'Un déficit moteur progressif peut traduire une atteinte neurologique sérieuse et doit interrompre une prise en charge exclusive.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseId: 'validation_v5_neurologic_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_cardiorespiratoire',
      title: 'Douleur thoracique avec signe cardio-respiratoire',
      clinicalDescription:
          'Douleur thoracique associée à dyspnée, malaise ou syncope.',
      triggeringQuestionIds: ['v4_cardiorespiratory_001'],
      triggeringFlagIds: ['chest_pain', 'dyspnea_or_malaise'],
      clusterId: 'cardiorespiratoryCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
      state: ClinicalHardStopStateV5.confirmed,
      clinicalRationale:
          'L’association douleur thoracique et signe cardio-respiratoire constitue un hard stop d’urgence.',
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.pulmonaryEmbolismSource,
      ],
      validationCaseId: 'validation_v5_cardiorespiratory_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_risque_fracturaire',
      title: 'Traumatisme sur terrain de fragilité osseuse',
      clinicalDescription:
          'Chute ou traumatisme associé à ostéoporose, corticothérapie prolongée ou âge avancé.',
      triggeringQuestionIds: ['v4_fracture_risk_001'],
      triggeringFlagIds: ['trauma_or_fall', 'bone_fragility'],
      clusterId: 'fractureRiskCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      clinicalRationale:
          'Le risque fracturaire augmente lorsque le traumatisme survient sur terrain de fragilité osseuse.',
      scientificSources: [
        ClinicalScreeningQuestionnaireV4.ottawaAnkleRulesSource,
      ],
      validationCaseId: 'validation_v5_fracture_risk_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_vasculaire_tvp',
      title: 'Suspicion TVP ou atteinte vasculaire',
      clinicalDescription:
          'Douleur du mollet, œdème, asymétrie ou facteurs de risque compatibles avec une suspicion de TVP.',
      triggeringQuestionIds: ['v4_vascular_tvp_001'],
      triggeringFlagIds: ['vascular_tvp_context'],
      clusterId: 'vascularCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      clinicalRationale:
          'Une suspicion vasculaire répétée doit interrompre l’accès direct exclusif et déclencher un avis médical impératif.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.wellsDvtSource],
      validationCaseId: 'validation_v5_vascular_cluster_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_cervical_vasculaire',
      title: 'Suspicion neurovasculaire cervicale',
      clinicalDescription:
          'Céphalée inhabituelle, vertiges inhabituels, troubles visuels, dysarthrie ou contexte vasculaire après traumatisme cervical même mineur.',
      triggeringQuestionIds: ['v4_cervical_vascular_001'],
      triggeringFlagIds: ['cervical_vascular_context'],
      clusterId: 'cervicalVascularCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      state: ClinicalHardStopStateV5.suspected,
      clinicalRationale:
          'Un tableau cervical avec signes neurovasculaires ou facteurs vasculaires ne doit pas être rassuré par une présentation mécanique seule.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.lowBackPainSource],
      validationCaseId: 'validation_v7_cervical_vascular_001',
    ),
    ClinicalHardStopRuleV5(
      id: 'v5_hard_stop_aaa_vasculaire_abdominal',
      title: 'Suspicion vasculaire abdominale ou AAA',
      clinicalDescription:
          'Douleur lombaire ou abdominale profonde inhabituelle, brutale ou avec malaise sur terrain vasculaire.',
      triggeringQuestionIds: ['v4_aaa_vascular_abdominal_001'],
      triggeringFlagIds: ['aaa_vascular_abdominal_context'],
      clusterId: 'aaaVascularAbdominalCluster',
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      state: ClinicalHardStopStateV5.suspected,
      clinicalRationale:
          'Une douleur profonde inhabituelle ou brutale sur terrain vasculaire doit empêcher une conclusion de réassurance simple.',
      scientificSources: [ClinicalScreeningQuestionnaireV4.wellsDvtSource],
      validationCaseId: 'validation_v7_aaa_vascular_abdominal_001',
    ),
  ];

  static Set<String> get hardStopIds {
    return rules.map((rule) => rule.id).toSet();
  }

  static Set<String> get triggeringQuestionIds {
    return rules.expand((rule) => rule.triggeringQuestionIds).toSet();
  }

  static Set<String> get triggeringFlagIds {
    return rules.expand((rule) => rule.triggeringFlagIds).toSet();
  }

  static Set<String> get clusterIds {
    return rules.map((rule) => rule.clusterId).toSet();
  }

  static List<ClinicalHardStopRuleV5> rulesForCluster(String clusterId) {
    return rules
        .where((rule) => rule.clusterId == clusterId)
        .toList(growable: false);
  }

  static ClinicalHardStopRuleV5? ruleById(String hardStopId) {
    for (final rule in rules) {
      if (rule.id == hardStopId) {
        return rule;
      }
    }

    return null;
  }
}
