import 'clinical_probability_update_v5.dart';

abstract final class ClinicalProbabilityUpdateCatalogV5 {
  static const updates = [
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_queue_cheval_question',
      hypothesisId: 'v5_hypothesis_queue_cheval',
      triggerQuestionId: 'v4_queue_cheval_001',
      triggerFlagId: 'queue_cheval_suspected',
      impact: ClinicalProbabilityImpactV5.strongIncrease,
      priorProbability: ClinicalQualitativeProbabilityV5.low,
      updatedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
      clinicalRationale:
          'La présence de troubles sphinctériens, anesthésie en selle ou déficit compatible transforme une hypothèse rare en urgence clinique.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_embolie_pulmonaire_question',
      hypothesisId: 'v5_hypothesis_embolie_pulmonaire',
      triggerQuestionId: 'v4_embolie_pulmonaire_001',
      triggerFlagId: 'pulmonary_embolism_suspected',
      impact: ClinicalProbabilityImpactV5.strongIncrease,
      priorProbability: ClinicalQualitativeProbabilityV5.low,
      updatedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
      clinicalRationale:
          'Dyspnée brutale, douleur thoracique ou malaise orientent fortement vers une hypothèse cardio-respiratoire urgente.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_fracture_ouverte_question',
      hypothesisId: 'v5_hypothesis_fracture_ouverte',
      triggerQuestionId: 'v4_fracture_ouverte_001',
      triggerFlagId: 'open_fracture_suspected',
      impact: ClinicalProbabilityImpactV5.strongIncrease,
      priorProbability: ClinicalQualitativeProbabilityV5.low,
      updatedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
      clinicalRationale:
          'Une plaie ou déformation compatible avec fracture ouverte impose de considérer l’hypothèse comme très probable cliniquement.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_oncologic_cluster',
      hypothesisId: 'v5_hypothesis_pathologie_oncologique',
      triggerQuestionId: 'v4_oncologic_context_001',
      triggerFlagId: 'oncologic_context',
      impact: ClinicalProbabilityImpactV5.increase,
      priorProbability: ClinicalQualitativeProbabilityV5.low,
      updatedProbability: ClinicalQualitativeProbabilityV5.high,
      clinicalRationale:
          'Le contexte oncologique associé aux signes généraux ou nocturnes augmente qualitativement la probabilité d’une pathologie sérieuse.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_infectious_fragility',
      hypothesisId: 'v5_hypothesis_infection_systemique_fragile',
      triggerQuestionId: 'v4_infectious_fragility_001',
      triggerFlagId: 'fever_or_chills',
      impact: ClinicalProbabilityImpactV5.increase,
      priorProbability: ClinicalQualitativeProbabilityV5.moderate,
      updatedProbability: ClinicalQualitativeProbabilityV5.high,
      clinicalRationale:
          'Des signes infectieux sur terrain fragile renforcent l’hypothèse d’infection systémique nécessitant avis rapide.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_neurologic_deficit',
      hypothesisId: 'v5_hypothesis_atteinte_neurologique_progressive',
      triggerQuestionId: 'v4_neurologic_deficit_001',
      triggerFlagId: 'progressive_motor_deficit',
      impact: ClinicalProbabilityImpactV5.increase,
      priorProbability: ClinicalQualitativeProbabilityV5.moderate,
      updatedProbability: ClinicalQualitativeProbabilityV5.high,
      clinicalRationale:
          'Un déficit moteur progressif augmente la probabilité qualitative d’une atteinte neurologique sérieuse.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_cardiorespiratory_cluster',
      hypothesisId: 'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
      triggerQuestionId: 'v4_cardiorespiratory_001',
      triggerFlagId: 'chest_pain',
      impact: ClinicalProbabilityImpactV5.strongIncrease,
      priorProbability: ClinicalQualitativeProbabilityV5.low,
      updatedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
      clinicalRationale:
          'La douleur thoracique associée à dyspnée, malaise ou syncope rend l’hypothèse cardio-respiratoire aiguë prioritaire.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_fracture_fragility',
      hypothesisId: 'v5_hypothesis_fracture_fragilite',
      triggerQuestionId: 'v4_fracture_risk_001',
      triggerFlagId: 'trauma_or_fall',
      impact: ClinicalProbabilityImpactV5.increase,
      priorProbability: ClinicalQualitativeProbabilityV5.moderate,
      updatedProbability: ClinicalQualitativeProbabilityV5.high,
      clinicalRationale:
          'Un traumatisme sur terrain de fragilité augmente qualitativement la probabilité de fracture significative.',
    ),
    ClinicalProbabilityUpdateV5(
      id: 'v5_probability_update_tvp',
      hypothesisId: 'v5_hypothesis_tvp',
      triggerQuestionId: 'v4_vascular_tvp_001',
      triggerFlagId: 'vascular_tvp_context',
      impact: ClinicalProbabilityImpactV5.increase,
      priorProbability: ClinicalQualitativeProbabilityV5.moderate,
      updatedProbability: ClinicalQualitativeProbabilityV5.high,
      clinicalRationale:
          'Un contexte compatible TVP augmente la probabilité qualitative d’une atteinte vasculaire à orienter rapidement.',
    ),
  ];

  static Set<String> get updateIds {
    return updates.map((update) => update.id).toSet();
  }

  static Set<String> get hypothesisIds {
    return updates.map((update) => update.hypothesisId).toSet();
  }

  static Set<String> get triggerQuestionIds {
    return updates
        .map((update) => update.triggerQuestionId)
        .whereType<String>()
        .toSet();
  }

  static Set<String> get triggerFlagIds {
    return updates
        .map((update) => update.triggerFlagId)
        .whereType<String>()
        .toSet();
  }

  static List<ClinicalProbabilityUpdateV5> updatesForHypothesis(
    String hypothesisId,
  ) {
    return updates
        .where((update) => update.hypothesisId == hypothesisId)
        .toList(growable: false);
  }
}
