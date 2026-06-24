import 'clinical_screening_catalog.dart';
import 'clinical_screening_models.dart';
import 'clinical_screening_question_v4.dart';
import 'clinical_screening_tags.dart';
import 'clinical_script_v7.dart';

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
      scriptId: ClinicalScriptIdsV7.queueDeCheval,
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
      scriptId: ClinicalScriptIdsV7.vasculaire,
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
      scriptId: ClinicalScriptIdsV7.fracture,
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
      scriptId: ClinicalScriptIdsV7.oncologique,
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
      scriptId: ClinicalScriptIdsV7.infectieux,
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
      scriptId: ClinicalScriptIdsV7.neurologique,
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
      scriptId: ClinicalScriptIdsV7.vasculaire,
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
      scriptId: ClinicalScriptIdsV7.fracture,
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
      scriptId: ClinicalScriptIdsV7.vasculaire,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_cervical_vascular_001',
      text:
          'Existe-t-il une céphalée inhabituelle, des vertiges inhabituels, des troubles visuels, une dysarthrie ou un contexte vasculaire après traumatisme cervical même mineur ?',
      clinicalIntent:
          'Repérer une suspicion neurovasculaire cervicale nécessitant un avis médical rapide.',
      associatedFlagId: 'cervical_vascular_context',
      clusterId: 'cervicalVascularCluster',
      ruleId: 'cervicalVascularCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 30),
      tags: ClinicalScreeningTags.cervicalVascular,
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.cervicalVasculaire,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_aaa_vascular_abdominal_001',
      text:
          'Existe-t-il une douleur lombaire ou abdominale profonde inhabituelle, brutale ou associée à malaise chez une personne avec âge avancé, tabagisme ou HTA ?',
      clinicalIntent:
          'Repérer une suspicion vasculaire abdominale ou AAA nécessitant un avis médical rapide.',
      associatedFlagId: 'aaa_vascular_abdominal_context',
      clusterId: 'aaaVascularAbdominalCluster',
      ruleId: 'aaaVascularAbdominalCluster',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 30),
      tags: ClinicalScreeningTags.aaaVascularAbdominal,
      scientificSources: [wellsDvtSource],
      scriptId: ClinicalScriptIdsV7.aaaVasculaireAbdominal,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_mechanical_pattern_001',
      text:
          'La douleur est-elle liée au mouvement, reproductible et améliorée par le repos ou la réduction de charge ?',
      clinicalIntent:
          'Identifier un profil mécanique rassurant en l’absence de signal critique.',
      associatedFlagId: 'mechanical_pain_pattern',
      clusterId: 'mechanicalReassurance',
      ruleId: 'mechanicalReassurance',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [
        ClinicalScreeningTags.douleurLieeMouvement,
        ClinicalScreeningTags.douleurReproductible,
        ClinicalScreeningTags.ameliorationRepos,
      ],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.mecanique,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_mechanical_overload_001',
      text:
          'Le contexte est-il cohérent avec une surcharge mécanique récente sans symptôme inhabituel associé ?',
      clinicalIntent:
          'Identifier une surcharge mécanique cohérente sans élément organique critique.',
      associatedFlagId: 'mechanical_pain_pattern',
      clusterId: 'mechanicalReassurance',
      ruleId: 'mechanicalReassurance',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.surchargeMecanique],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.mecanique,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_known_stable_mechanical_episode_001',
      text:
          'Cet épisode est-il comparable à un épisode mécanique déjà connu, stable et sans aggravation inhabituelle ?',
      clinicalIntent:
          'Identifier un épisode mécanique stable sans signal clinique nouveau.',
      associatedFlagId: 'known_stable_mechanical_episode',
      clusterId: 'mechanicalReassurance',
      ruleId: 'mechanicalReassurance',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.episodeMecaniqueStable],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.mecanique,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_structured_absence_systemic_signs_001',
      text:
          'L’entretien retrouve-t-il l’absence de fièvre, perte de poids, altération générale et douleur nocturne non mécanique ?',
      clinicalIntent:
          'Documenter l’absence structurée de signes systémiques avant réassurance.',
      associatedFlagId: 'structured_absence_systemic_signs',
      clusterId: 'mechanicalReassurance',
      ruleId: 'mechanicalReassurance',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.general,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.absenceSignesSystemiques],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.mecanique,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_psychosocial_catastrophizing_001',
      text:
          'La personne exprime-t-elle des pensées catastrophiques importantes à propos de sa douleur ?',
      clinicalIntent:
          'Identifier un facteur psychosocial isolé sans en faire un signal organique critique.',
      associatedFlagId: 'psychosocial_catastrophizing',
      clusterId: 'yellowFlagsOnly',
      ruleId: 'yellowFlagsOnly',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.catastrophisme],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.psychosocial,
      psychosocialLevel: ClinicalPsychosocialLevelsV7.psychoModerate,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_psychosocial_fear_movement_001',
      text:
          'La personne évite-t-elle fortement certains mouvements par peur d’aggraver la situation ?',
      clinicalIntent:
          'Identifier une peur du mouvement isolée sans neutraliser les red flags.',
      associatedFlagId: 'psychosocial_fear_of_movement',
      clusterId: 'yellowFlagsOnly',
      ruleId: 'yellowFlagsOnly',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.peurMouvement],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.psychosocial,
      psychosocialLevel: ClinicalPsychosocialLevelsV7.psychoModerate,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_psychosocial_anxiety_001',
      text:
          'L’anxiété autour du symptôme est-elle importante pendant l’entretien ?',
      clinicalIntent:
          'Identifier une anxiété importante isolée sans modifier une décision urgente.',
      associatedFlagId: 'psychosocial_anxiety',
      clusterId: 'yellowFlagsOnly',
      ruleId: 'yellowFlagsOnly',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.anxieteImportante],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.psychosocial,
      psychosocialLevel: ClinicalPsychosocialLevelsV7.psychoHigh,
    ),
    ClinicalScreeningQuestionV4(
      id: 'v4_psychosocial_disproportionate_impact_001',
      text:
          'Le retentissement fonctionnel paraît-il disproportionné par rapport aux éléments cliniques observés ?',
      clinicalIntent:
          'Identifier un impact fonctionnel disproportionné isolé comme facteur psychosocial.',
      associatedFlagId: 'psychosocial_disproportionate_impact',
      clusterId: 'yellowFlagsOnly',
      ruleId: 'yellowFlagsOnly',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      responseType: ClinicalQuestionResponseType.yesNo,
      potentialDecisionLevel: ClinicalDecisionLevel.routine,
      evidenceLevel: ClinicalEvidenceLevel.expertConsensus,
      targetResponseTime: Duration(seconds: 20),
      tags: [ClinicalScreeningTags.impactFonctionnelDisproportionne],
      scientificSources: [lowBackPainSource],
      scriptId: ClinicalScriptIdsV7.psychosocial,
      psychosocialLevel: ClinicalPsychosocialLevelsV7.psychoLow,
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
