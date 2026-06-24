import 'clinical_screening_models.dart';
import 'clinical_screening_tags.dart';

class ClinicalFlagDefinition {
  final String id;
  final String label;
  final String description;
  final ClinicalScreeningLayer layer;
  final ClinicalFlagCategory category;
  final ClinicalDecisionLevel defaultDecisionLevel;
  final int defaultWeight;
  final List<String> tags;
  final String clinicalRationale;
  final String suggestedQuestion;

  const ClinicalFlagDefinition({
    required this.id,
    required this.label,
    required this.description,
    required this.layer,
    required this.category,
    required this.defaultDecisionLevel,
    required this.defaultWeight,
    required this.tags,
    required this.clinicalRationale,
    required this.suggestedQuestion,
  });
}

class ClinicalTagDefinition {
  final String tag;
  final String label;
  final String description;
  final bool isCritical;
  final ClinicalDecisionLevel expectedDecisionLevel;

  const ClinicalTagDefinition({
    required this.tag,
    required this.label,
    required this.description,
    required this.isCritical,
    required this.expectedDecisionLevel,
  });
}

class ClinicalRuleDefinition {
  final String ruleId;
  final String title;
  final String description;
  final ClinicalScreeningLayer layer;
  final ClinicalDecisionLevel decisionLevel;
  final List<String> requiredTags;
  final List<String> optionalTags;
  final String clinicalRationale;

  const ClinicalRuleDefinition({
    required this.ruleId,
    required this.title,
    required this.description,
    required this.layer,
    required this.decisionLevel,
    required this.requiredTags,
    required this.optionalTags,
    required this.clinicalRationale,
  });
}

abstract final class ClinicalScreeningCatalog {
  static const flagDefinitions = [
    ClinicalFlagDefinition(
      id: 'queue_cheval_suspected',
      label: 'Syndrome de la queue de cheval suspecté',
      description:
          'Troubles sphinctériens, anesthésie en selle ou déficit neurologique compatible avec une atteinte compressive urgente.',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.neurological,
      defaultDecisionLevel: ClinicalDecisionLevel.emergency,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.queueCheval],
      clinicalRationale:
          'Une suspicion de queue de cheval nécessite une orientation urgente car le pronostic neurologique dépend du délai.',
      suggestedQuestion:
          'Avez-vous des troubles urinaires ou fécaux nouveaux, une anesthésie en selle ou une faiblesse importante des jambes ?',
    ),
    ClinicalFlagDefinition(
      id: 'pulmonary_embolism_suspected',
      label: 'Suspicion d’embolie pulmonaire',
      description:
          'Dyspnée brutale, douleur thoracique, malaise ou tachycardie pouvant évoquer une embolie pulmonaire.',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.respiratory,
      defaultDecisionLevel: ClinicalDecisionLevel.emergency,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.emboliePulmonaire],
      clinicalRationale:
          'La suspicion d’embolie pulmonaire relève d’une évaluation urgente et ne doit pas être prise en charge en accès direct isolé.',
      suggestedQuestion:
          'Avez-vous eu un essoufflement brutal, une douleur thoracique, un malaise ou des palpitations inhabituelles ?',
    ),
    ClinicalFlagDefinition(
      id: 'open_fracture_suspected',
      label: 'Suspicion de fracture ouverte',
      description:
          'Plaie associée à une déformation, douleur osseuse importante ou suspicion de communication avec le foyer fracturaire.',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.musculoskeletal,
      defaultDecisionLevel: ClinicalDecisionLevel.emergency,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.fractureOuverte],
      clinicalRationale:
          'Une fracture ouverte expose à des complications infectieuses et vasculo-nerveuses et impose une orientation urgente.',
      suggestedQuestion:
          'Existe-t-il une plaie, une déformation évidente ou une suspicion d’os exposé après le traumatisme ?',
    ),
    ClinicalFlagDefinition(
      id: 'critical_chest_pain',
      label: 'Douleur thoracique critique',
      description:
          'Douleur thoracique oppressive, inhabituelle ou associée à un contexte cardio-respiratoire inquiétant.',
      layer: ClinicalScreeningLayer.immediateDanger,
      category: ClinicalFlagCategory.cardiovascular,
      defaultDecisionLevel: ClinicalDecisionLevel.emergency,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.douleurThoraciqueCritique],
      clinicalRationale:
          'Une douleur thoracique critique doit être considérée comme une urgence potentielle jusqu’à avis médical.',
      suggestedQuestion:
          'La douleur thoracique est-elle oppressive, brutale, inhabituelle ou associée à sueurs, malaise ou essoufflement ?',
    ),
    ClinicalFlagDefinition(
      id: 'oncologic_context',
      label: 'Contexte oncologique',
      description:
          'Cancer actif, antécédent récent ou suspicion de pathologie tumorale dans le contexte clinique.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.general,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.cancer],
      clinicalRationale:
          'Un contexte oncologique augmente la vigilance, surtout s’il est associé à des signes généraux ou nocturnes.',
      suggestedQuestion:
          'Avez-vous un cancer actif, un traitement récent ou un antécédent oncologique significatif ?',
    ),
    ClinicalFlagDefinition(
      id: 'weight_loss_or_night_pain',
      label: 'Perte de poids ou douleur nocturne',
      description:
          'Perte de poids inexpliquée, douleur nocturne non mécanique ou altération de l’état général.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.general,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [
        ClinicalScreeningTags.pertePoids,
        ClinicalScreeningTags.douleurNocturne,
      ],
      clinicalRationale:
          'Ces signes deviennent particulièrement préoccupants lorsqu’ils s’associent à un contexte oncologique.',
      suggestedQuestion:
          'Avez-vous perdu du poids sans explication, ou avez-vous des douleurs nocturnes non soulagées par le repos ?',
    ),
    ClinicalFlagDefinition(
      id: 'fever_or_chills',
      label: 'Fièvre ou frissons',
      description:
          'Fièvre, frissons ou sueurs nocturnes suggérant un contexte infectieux systémique.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.infectious,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.fievre, ClinicalScreeningTags.frissons],
      clinicalRationale:
          'Les signes infectieux systémiques nécessitent une vigilance renforcée, surtout chez les patients fragiles.',
      suggestedQuestion:
          'Avez-vous de la fièvre, des frissons ou des sueurs nocturnes inhabituelles ?',
    ),
    ClinicalFlagDefinition(
      id: 'immunosuppression',
      label: 'Immunodépression',
      description:
          'Contexte d’immunodépression, traitement immunosuppresseur ou infection récente significative.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.infectious,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.immunodepression],
      clinicalRationale:
          'L’immunodépression augmente le risque de complication infectieuse et abaisse le seuil d’avis médical.',
      suggestedQuestion:
          'Avez-vous un traitement ou une maladie diminuant vos défenses immunitaires, ou une infection récente ?',
    ),
    ClinicalFlagDefinition(
      id: 'progressive_motor_deficit',
      label: 'Déficit moteur progressif',
      description:
          'Faiblesse motrice progressive ou signes neurologiques centraux récents.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.neurological,
      defaultDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.deficitMoteurProgressif],
      clinicalRationale:
          'Un déficit moteur progressif peut révéler une atteinte neurologique sérieuse et justifie un avis rapide.',
      suggestedQuestion:
          'Avez-vous une faiblesse qui progresse, une perte de force ou des troubles neurologiques récents ?',
    ),
    ClinicalFlagDefinition(
      id: 'chest_pain',
      label: 'Douleur thoracique',
      description:
          'Douleur thoracique non critique isolée ou à contextualiser avec des signes respiratoires ou de malaise.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.cardiovascular,
      defaultDecisionLevel: ClinicalDecisionLevel.monitor,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.douleurThoracique],
      clinicalRationale:
          'La douleur thoracique devient une urgence dans le moteur lorsqu’elle s’associe à dyspnée, malaise ou syncope.',
      suggestedQuestion:
          'La douleur thoracique est-elle associée à un essoufflement, un malaise, une syncope ou une gêne inhabituelle ?',
    ),
    ClinicalFlagDefinition(
      id: 'dyspnea_or_malaise',
      label: 'Dyspnée, malaise ou syncope',
      description:
          'Essoufflement, malaise, syncope ou signe cardio-respiratoire associé.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.respiratory,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.dyspnee, ClinicalScreeningTags.malaise],
      clinicalRationale:
          'Associés à une douleur thoracique, ces signes imposent une orientation urgente.',
      suggestedQuestion:
          'Avez-vous un essoufflement, un malaise, une perte de connaissance ou une gêne respiratoire associée ?',
    ),
    ClinicalFlagDefinition(
      id: 'trauma_or_fall',
      label: 'Traumatisme ou chute',
      description:
          'Traumatisme récent ou chute pouvant exposer à une lésion fracturaire.',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      defaultDecisionLevel: ClinicalDecisionLevel.monitor,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.traumatisme, ClinicalScreeningTags.chute],
      clinicalRationale:
          'Le risque fracturaire augmente lorsque le traumatisme s’associe à un facteur de fragilité osseuse.',
      suggestedQuestion:
          'La douleur fait-elle suite à une chute ou à un traumatisme récent ?',
    ),
    ClinicalFlagDefinition(
      id: 'bone_fragility',
      label: 'Facteur de fragilité osseuse',
      description:
          'Ostéoporose, corticothérapie prolongée ou âge avancé augmentant le risque fracturaire.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.musculoskeletal,
      defaultDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
      defaultWeight: 1,
      tags: [
        ClinicalScreeningTags.osteoporose,
        ClinicalScreeningTags.corticotherapieProlongee,
        ClinicalScreeningTags.ageAvance,
      ],
      clinicalRationale:
          'Un facteur de fragilité abaisse le seuil de suspicion de fracture après traumatisme.',
      suggestedQuestion:
          'Avez-vous une ostéoporose, une corticothérapie prolongée ou un âge avancé avec risque de fragilité osseuse ?',
    ),
    ClinicalFlagDefinition(
      id: 'vascular_tvp_context',
      label: 'Suspicion TVP / vasculaire',
      description:
          'Éléments compatibles avec une suspicion de TVP ou d’atteinte vasculaire.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      defaultDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      defaultWeight: 1,
      tags: [ClinicalScreeningTags.wellsTvp, ClinicalScreeningTags.tvp],
      clinicalRationale:
          'La répétition d’éléments vasculaires nécessite un avis médical impératif rapide.',
      suggestedQuestion:
          'Existe-t-il une douleur du mollet, un œdème, une chaleur, une asymétrie ou des facteurs de risque de TVP ?',
    ),
    ClinicalFlagDefinition(
      id: 'cervical_vascular_context',
      label: 'Contexte neurovasculaire cervical',
      description:
          'Céphalée inhabituelle, vertiges inhabituels, troubles visuels, dysarthrie ou facteurs vasculaires après traumatisme cervical même mineur.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      defaultDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      defaultWeight: 1,
      tags: ClinicalScreeningTags.cervicalVascular,
      clinicalRationale:
          'Les signes neurovasculaires cervicaux ou facteurs vasculaires doivent empêcher une réassurance mécanique simple.',
      suggestedQuestion:
          'Existe-t-il une céphalée inhabituelle, des vertiges inhabituels, des troubles visuels, une dysarthrie ou un contexte vasculaire après traumatisme cervical même mineur ?',
    ),
    ClinicalFlagDefinition(
      id: 'aaa_vascular_abdominal_context',
      label: 'Contexte vasculaire abdominal ou AAA',
      description:
          'Douleur lombaire ou abdominale profonde inhabituelle, brutale ou avec malaise sur terrain vasculaire.',
      layer: ClinicalScreeningLayer.systemic,
      category: ClinicalFlagCategory.vascular,
      defaultDecisionLevel: ClinicalDecisionLevel.urgentReferral,
      defaultWeight: 1,
      tags: ClinicalScreeningTags.aaaVascularAbdominal,
      clinicalRationale:
          'Une douleur profonde inhabituelle ou brutale sur terrain vasculaire impose un avis médical rapide avant réassurance.',
      suggestedQuestion:
          'Existe-t-il une douleur lombaire ou abdominale profonde inhabituelle, brutale ou associée à malaise chez une personne avec âge avancé, tabagisme ou HTA ?',
    ),
    ClinicalFlagDefinition(
      id: 'mechanical_pain_pattern',
      label: 'Profil mécanique rassurant',
      description:
          'Douleur liée au mouvement, reproductible, améliorée au repos ou cohérente avec une surcharge mécanique.',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [
        ClinicalScreeningTags.douleurLieeMouvement,
        ClinicalScreeningTags.douleurReproductible,
        ClinicalScreeningTags.ameliorationRepos,
        ClinicalScreeningTags.surchargeMecanique,
      ],
      clinicalRationale:
          'Un profil mécanique cohérent peut soutenir une réassurance seulement en l’absence de hard stop ou signal critique.',
      suggestedQuestion:
          'La douleur est-elle liée au mouvement, reproductible et améliorée par le repos ou la réduction de charge ?',
    ),
    ClinicalFlagDefinition(
      id: 'known_stable_mechanical_episode',
      label: 'Épisode mécanique connu stable',
      description:
          'Épisode déjà connu, comparable aux épisodes précédents et sans changement clinique inquiétant.',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.musculoskeletal,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.episodeMecaniqueStable],
      clinicalRationale:
          'Un épisode stable connu est rassurant uniquement si aucun signal organique critique n’est positif.',
      suggestedQuestion:
          'Cet épisode est-il comparable à un épisode mécanique déjà connu, stable et sans aggravation inhabituelle ?',
    ),
    ClinicalFlagDefinition(
      id: 'structured_absence_systemic_signs',
      label: 'Absence structurée de signes systémiques',
      description:
          'Absence explicitement recherchée de fièvre, altération de l’état général, perte de poids ou douleur nocturne non mécanique.',
      layer: ClinicalScreeningLayer.regional,
      category: ClinicalFlagCategory.general,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.absenceSignesSystemiques],
      clinicalRationale:
          'L’absence structurée de signes systémiques soutient une réassurance prudente sans neutraliser les signaux critiques.',
      suggestedQuestion:
          'Avez-vous vérifié l’absence de fièvre, perte de poids, altération générale ou douleur nocturne non mécanique ?',
    ),
    ClinicalFlagDefinition(
      id: 'psychosocial_catastrophizing',
      label: 'Catastrophisme',
      description:
          'Pensées catastrophiques ou inquiétude disproportionnée autour de la douleur, sans signal organique critique associé.',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.catastrophisme],
      clinicalRationale:
          'Un facteur psychosocial isolé module l’accompagnement mais ne crée pas de hard stop et ne neutralise jamais un signal critique.',
      suggestedQuestion:
          'La personne exprime-t-elle des pensées catastrophiques importantes à propos de sa douleur ?',
    ),
    ClinicalFlagDefinition(
      id: 'psychosocial_fear_of_movement',
      label: 'Peur du mouvement',
      description:
          'Évitement ou peur du mouvement sans signe clinique organique prioritaire.',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.peurMouvement],
      clinicalRationale:
          'La peur du mouvement isolée ne doit pas déclencher d’orientation urgente ni masquer un red flag.',
      suggestedQuestion:
          'La personne évite-t-elle fortement certains mouvements par peur d’aggraver la situation ?',
    ),
    ClinicalFlagDefinition(
      id: 'psychosocial_anxiety',
      label: 'Anxiété importante',
      description:
          'Anxiété élevée autour du symptôme, sans signal clinique critique associé.',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.anxieteImportante],
      clinicalRationale:
          'L’anxiété isolée peut nécessiter une adaptation relationnelle sans modifier une décision urgente.',
      suggestedQuestion:
          'L’anxiété autour du symptôme est-elle importante pendant l’entretien ?',
    ),
    ClinicalFlagDefinition(
      id: 'psychosocial_disproportionate_impact',
      label: 'Impact fonctionnel disproportionné',
      description:
          'Retentissement fonctionnel disproportionné par rapport aux éléments cliniques retrouvés.',
      layer: ClinicalScreeningLayer.yellowFlag,
      category: ClinicalFlagCategory.other,
      defaultDecisionLevel: ClinicalDecisionLevel.routine,
      defaultWeight: 0,
      tags: [ClinicalScreeningTags.impactFonctionnelDisproportionne],
      clinicalRationale:
          'Un impact fonctionnel disproportionné isolé relève d’une vigilance psychosociale, sans effet sur les hard stops.',
      suggestedQuestion:
          'Le retentissement fonctionnel paraît-il disproportionné par rapport aux éléments cliniques observés ?',
    ),
  ];

  static const tagDefinitions = [
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.urgenceVitale,
      label: 'Urgence vitale',
      description: 'Identifie une situation d’urgence vitale potentielle.',
      isCritical: true,
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.emboliePulmonaire,
      label: 'Embolie pulmonaire',
      description: 'Suspicion d’embolie pulmonaire ou complication embolique.',
      isCritical: true,
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.queueCheval,
      label: 'Queue de cheval',
      description: 'Suspicion de syndrome de la queue de cheval.',
      isCritical: true,
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.fractureOuverte,
      label: 'Fracture ouverte',
      description: 'Suspicion de fracture ouverte.',
      isCritical: true,
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurThoraciqueCritique,
      label: 'Douleur thoracique critique',
      description: 'Douleur thoracique imposant une orientation urgente.',
      isCritical: true,
      expectedDecisionLevel: ClinicalDecisionLevel.emergency,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.cancer,
      label: 'Cancer',
      description: 'Contexte oncologique ou antécédent significatif.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.pertePoids,
      label: 'Perte de poids',
      description: 'Perte de poids inexpliquée.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurNocturne,
      label: 'Douleur nocturne',
      description: 'Douleur nocturne non mécanique ou progressive.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.fievre,
      label: 'Fièvre',
      description: 'Fièvre ou contexte infectieux systémique.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.immunodepression,
      label: 'Immunodépression',
      description: 'Terrain immunodéprimé ou fragile.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.deficitMoteurProgressif,
      label: 'Déficit moteur progressif',
      description: 'Déficit moteur évolutif ou neurologique central.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurThoracique,
      label: 'Douleur thoracique',
      description: 'Douleur thoracique à contextualiser.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.monitor,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.dyspnee,
      label: 'Dyspnée',
      description: 'Essoufflement ou gêne respiratoire.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.traumatisme,
      label: 'Traumatisme',
      description: 'Traumatisme ou chute récente.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.monitor,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.osteoporose,
      label: 'Ostéoporose',
      description: 'Fragilité osseuse connue ou suspectée.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.medicalAdvice,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.wellsTvp,
      label: 'Wells TVP',
      description: 'Critère ou item compatible avec une suspicion de TVP.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.vasculaire,
      label: 'Vasculaire',
      description: 'Élément clinique vasculaire.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.neurovasculaireCervical,
      label: 'Neurovasculaire cervical',
      description: 'Élément compatible avec une atteinte vasculaire cervicale.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.cephaleeInhabituelle,
      label: 'Céphalée inhabituelle',
      description: 'Céphalée inhabituelle dans un contexte cervical.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurLombaireAbdominaleProfonde,
      label: 'Douleur profonde lombaire ou abdominale',
      description:
          'Douleur lombaire ou abdominale profonde inhabituelle dans un contexte vasculaire.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurBrutale,
      label: 'Douleur brutale',
      description: 'Douleur brutale ou inhabituelle à contextualiser.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurLieeMouvement,
      label: 'Douleur liée au mouvement',
      description: 'Argument de profil mécanique, non critique isolément.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.douleurReproductible,
      label: 'Douleur reproductible',
      description: 'Douleur reproduite par un mouvement ou test mécanique.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.ameliorationRepos,
      label: 'Amélioration au repos',
      description: 'Amélioration avec repos ou diminution de charge.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.surchargeMecanique,
      label: 'Surcharge mécanique',
      description: 'Contexte de surcharge cohérent avec la plainte.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.episodeMecaniqueStable,
      label: 'Épisode mécanique stable',
      description: 'Épisode connu, stable et comparable.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.absenceSignesSystemiques,
      label: 'Absence de signes systémiques',
      description: 'Absence structurée de signes systémiques recherchés.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.catastrophisme,
      label: 'Catastrophisme',
      description: 'Facteur psychosocial isolé, non critique.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.peurMouvement,
      label: 'Peur du mouvement',
      description: 'Évitement ou peur du mouvement isolé.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.anxieteImportante,
      label: 'Anxiété importante',
      description: 'Anxiété importante sans signal clinique critique.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
    ClinicalTagDefinition(
      tag: ClinicalScreeningTags.impactFonctionnelDisproportionne,
      label: 'Impact fonctionnel disproportionné',
      description: 'Retentissement fonctionnel disproportionné isolé.',
      isCritical: false,
      expectedDecisionLevel: ClinicalDecisionLevel.routine,
    ),
  ];

  static const ruleDefinitions = [
    ClinicalRuleDefinition(
      ruleId: 'routine',
      title: 'Aucun flag présent',
      description: 'Aucun signe clinique présent n’est retenu.',
      layer: ClinicalScreeningLayer.regional,
      decisionLevel: ClinicalDecisionLevel.routine,
      requiredTags: [],
      optionalTags: [],
      clinicalRationale:
          'En l’absence de signe d’alerte présent, le moteur retient une prise en charge habituelle.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'immediateDanger',
      title: 'Danger immédiat',
      description:
          'Présence d’un tag critique ou d’un flag de danger immédiat.',
      layer: ClinicalScreeningLayer.immediateDanger,
      decisionLevel: ClinicalDecisionLevel.emergency,
      requiredTags: ClinicalScreeningTags.criticalEmergency,
      optionalTags: [],
      clinicalRationale:
          'Les tags critiques imposent une orientation d’urgence, indépendamment du score.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'oncologicCluster',
      title: 'Cluster oncologique',
      description:
          'Contexte oncologique associé à perte de poids, douleur nocturne ou altération de l’état général.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.oncologicContext,
      optionalTags: ClinicalScreeningTags.oncologicAssociated,
      clinicalRationale:
          'L’association contexte oncologique et signes généraux ou nocturnes ne permet pas d’exclure une pathologie sérieuse.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'infectiousCluster',
      title: 'Cluster infectieux',
      description:
          'Signes infectieux systémiques associés à immunodépression ou infection récente.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.infectiousSystemic,
      optionalTags: ClinicalScreeningTags.infectiousFragility,
      clinicalRationale:
          'L’association infection et fragilité augmente le risque de complication et impose un avis rapide.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'neurologicCluster',
      title: 'Cluster neurologique',
      description:
          'Déficit moteur progressif ou signes neurologiques centraux.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.neurologicCluster,
      optionalTags: [],
      clinicalRationale:
          'Un déficit neurologique significatif impose une évaluation médicale rapide.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'cardiorespiratoryCluster',
      title: 'Cluster cardio-respiratoire',
      description: 'Douleur thoracique associée à dyspnée, malaise ou syncope.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.emergency,
      requiredTags: ClinicalScreeningTags.chestPain,
      optionalTags: ClinicalScreeningTags.respiratoryOrMalaise,
      clinicalRationale:
          'L’association douleur thoracique et signe cardio-respiratoire impose une orientation urgente.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'fractureRiskCluster',
      title: 'Cluster risque fracturaire',
      description:
          'Traumatisme ou chute associé à ostéoporose, corticothérapie prolongée ou âge avancé.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.fractureTrauma,
      optionalTags: ClinicalScreeningTags.fractureFragility,
      clinicalRationale:
          'L’association traumatisme et fragilité osseuse augmente le risque de fracture significative.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'vascularCluster',
      title: 'Cluster vasculaire',
      description: 'Au moins deux éléments compatibles TVP ou vasculaire.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.vascularConcern,
      optionalTags: [],
      clinicalRationale:
          'La répétition d’éléments vasculaires justifie un avis médical impératif rapide.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'cervicalVascularCluster',
      title: 'Cluster neurovasculaire cervical',
      description:
          'Céphalée inhabituelle, vertiges, troubles visuels, dysarthrie ou facteurs vasculaires dans un contexte cervical.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.cervicalVascular,
      optionalTags: [],
      clinicalRationale:
          'Un tableau cervical avec signes neurovasculaires ne doit pas être neutralisé par des arguments mécaniques seuls.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'aaaVascularAbdominalCluster',
      title: 'Cluster vasculaire abdominal ou AAA',
      description:
          'Douleur lombaire ou abdominale profonde, brutale ou avec malaise sur terrain vasculaire.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: ClinicalScreeningTags.aaaVascularAbdominal,
      optionalTags: [],
      clinicalRationale:
          'Une douleur profonde inhabituelle sur terrain vasculaire doit empêcher une conclusion de réassurance simple.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'mechanicalReassurance',
      title: 'Réassurance mécanique prudente',
      description:
          'Arguments mécaniques cohérents retenus sans hard stop ni signal critique positif.',
      layer: ClinicalScreeningLayer.regional,
      decisionLevel: ClinicalDecisionLevel.routine,
      requiredTags: ClinicalScreeningTags.mechanicalReassurance,
      optionalTags: [],
      clinicalRationale:
          'Ces arguments soutiennent DEC_REASSURE uniquement si aucun hard stop, signal critique ou vulnérabilité organique suspecte n’est présent.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'systemicConcern',
      title: 'Signe systémique isolé',
      description: 'Signe systémique présent sans cluster complet.',
      layer: ClinicalScreeningLayer.systemic,
      decisionLevel: ClinicalDecisionLevel.medicalAdvice,
      requiredTags: ClinicalScreeningTags.isolatedSystemicConcern,
      optionalTags: [],
      clinicalRationale:
          'Un signe systémique isolé mérite un avis médical recommandé sans nécessairement justifier une urgence.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'yellowFlagsOnly',
      title: 'Drapeaux jaunes isolés',
      description: 'Facteurs psychosociaux ou contextuels seuls.',
      layer: ClinicalScreeningLayer.yellowFlag,
      decisionLevel: ClinicalDecisionLevel.monitor,
      requiredTags: [],
      optionalTags: [],
      clinicalRationale:
          'Les drapeaux jaunes seuls modulent le suivi sans déclencher une alerte médicale rouge.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'highestFlagLevel',
      title: 'Niveau intrinsèque de flag',
      description: 'Le niveau porté par un flag détermine la décision.',
      layer: ClinicalScreeningLayer.regional,
      decisionLevel: ClinicalDecisionLevel.urgentReferral,
      requiredTags: [],
      optionalTags: [],
      clinicalRationale:
          'Certains flags portent intrinsèquement un niveau de décision qui prévaut sur le score.',
    ),
    ClinicalRuleDefinition(
      ruleId: 'scoreEscalation',
      title: 'Escalade par score',
      description: 'Accumulation de flags atteignant un seuil de score.',
      layer: ClinicalScreeningLayer.regional,
      decisionLevel: ClinicalDecisionLevel.medicalAdvice,
      requiredTags: [],
      optionalTags: [],
      clinicalRationale:
          'L’accumulation de plusieurs signaux faibles peut justifier une vigilance ou un avis médical.',
    ),
  ];

  static Set<String> get ruleIds {
    return ruleDefinitions.map((rule) => rule.ruleId).toSet();
  }

  static Set<String> get tags {
    return tagDefinitions.map((tag) => tag.tag).toSet();
  }
}
