import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_region.dart';

/// Encodage intégral de la matrice pathways Delphi V0.1 — NON VALIDÉE.
///
/// Source de vérité : Radar_matrice_pathways_Delphi_V0.1.xlsx.
/// Toute modification de ce fichier DOIT provenir d'un tour de Delphi
/// consolidé et incrémenter [kRadarPathwayMatrixVersion].
///
/// Invariants (ne jamais casser) :
/// - Les 3 questions universelles figurent dans les 9 pathways, sans condition.
/// - Les Hard Stops V5 restent prioritaires : ce repository SÉLECTIONNE des
///   questions, il ne décide de rien.
/// - Les items psychosociaux (yellow flags) sont absents de tous les pathways :
///   module pronostic/bilan séparé.
/// - v4_structured_absence_systemic_signs_001 est absent : suppression
///   proposée au Delphi (point n°2). Ne pas réintroduire sans vote.
class RadarClinicalPathwayRepository {
  // ---------------------------------------------------------------- IDs V4
  static const _qc = 'v4_queue_cheval_001';
  static const _ep = 'v4_embolie_pulmonaire_001';
  static const _fxOpen = 'v4_fracture_ouverte_001';
  static const _cardio = 'v4_cardiorespiratory_001';
  static const _infect = 'v4_infectious_fragility_001';
  static const _neuro = 'v4_neurologic_deficit_001';
  static const _fxRisk = 'v4_fracture_risk_001';
  static const _tvp = 'v4_vascular_tvp_001';
  static const _onco = 'v4_oncologic_context_001';
  static const _cervVasc = 'v4_cervical_vascular_001';
  static const _aaa = 'v4_aaa_vascular_abdominal_001';
  static const _mechPattern = 'v4_mechanical_pattern_001';
  static const _mechOverload = 'v4_mechanical_overload_001';
  static const _mechStable = 'v4_known_stable_mechanical_episode_001';

  /// Catalogue complet V4 hors psychosocial et hors item en suppression —
  /// utilisé pour produire la liste des exclusions tracées par session.
  static const Set<String> screeningCatalogIds = {
    _qc,
    _ep,
    _fxOpen,
    _cardio,
    _infect,
    _neuro,
    _fxRisk,
    _tvp,
    _onco,
    _cervVasc,
    _aaa,
    _mechPattern,
    _mechOverload,
    _mechStable,
  };

  // ------------------------------------------------------- briques communes
  static const _socle = <RadarPathwaySlot>[
    RadarPathwaySlot(
      questionId: _onco,
      role: RadarQuestionRole.universal,
      order: 2,
      rationale:
          'U1 — contexte métastatique : toutes régions, plancher de '
          'sensibilité. ATCD cancer + douleur nocturne = combinaison la mieux '
          'documentée.',
    ),
    RadarPathwaySlot(
      questionId: _infect,
      role: RadarQuestionRole.universal,
      order: 3,
      rationale:
          'U2 — spondylodiscite/arthrite septique : toutes régions, '
          'retard diagnostique catastrophique.',
    ),
    RadarPathwaySlot(
      questionId: _neuro,
      role: RadarQuestionRole.universal,
      order: 4,
      rationale:
          'U3 — déficit progressif : escalade quelle que soit la '
          'région ; couvre myélopathie et atteinte centrale, ce qui autorise '
          'l\'exclusion de queue de cheval hors lombo-pelvien.',
    ),
  ];

  static const _fractureOpenOnTrauma = RadarPathwaySlot(
    questionId: _fxOpen,
    role: RadarQuestionRole.conditional,
    order: 0,
    activation: RadarActivationCondition([
      RadarActivationClause(gates: {RadarContextGate.trauma}),
    ]),
    rationale:
        'Pré-emption absolue si porte trauma : passe avant tout, '
        'y compris le socle.',
  );

  static const _fractureRisk = RadarPathwaySlot(
    questionId: _fxRisk,
    role: RadarQuestionRole.conditional,
    order: 6,
    activation: RadarActivationCondition([
      RadarActivationClause(gates: {RadarContextGate.trauma}),
      RadarActivationClause(gates: {RadarContextGate.ageOrBoneFragility}),
    ]),
    rationale:
        'Fracture par insuffisance chez le sujet fragile : les deux '
        'portes couvrent les deux mécanismes.',
  );

  static const _tvpLowerLimb = RadarPathwaySlot(
    questionId: _tvp,
    role: RadarQuestionRole.conditional,
    order: 6,
    activation: RadarActivationCondition([
      RadarActivationClause(gates: {RadarContextGate.recentImmobilization}),
      RadarActivationClause(triggers: {RadarClinicalTrigger.calfPainOrEdema}),
    ]),
    rationale:
        'TVP = hypothèse de membre inférieur, activée par P3 ou signe '
        'local. Une TVP positive escalade et couvre le risque d\'EP.',
  );

  /// Clôture mécanique — trois items en V0.1 ; fusion en une question
  /// composite proposée au Delphi (point n°4).
  static const _closure = <RadarPathwaySlot>[
    RadarPathwaySlot(
      questionId: _mechPattern,
      role: RadarQuestionRole.closure,
      order: 9,
      rationale:
          'Clôture — DEC_REASSURE exige une explication mécanique '
          'positive, pas seulement l\'absence de signes.',
    ),
    RadarPathwaySlot(
      questionId: _mechOverload,
      role: RadarQuestionRole.closure,
      order: 9,
      rationale: 'Clôture — contexte de surcharge.',
    ),
    RadarPathwaySlot(
      questionId: _mechStable,
      role: RadarQuestionRole.closure,
      order: 9,
      rationale: 'Clôture — épisode mécanique connu et stable.',
    ),
  ];

  // ------------------------------------------------------------- pathways
  static final Map<RadarClinicalRegion, RadarClinicalPathwayDefinition> _all = {
    RadarClinicalRegion.lumbar: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.lumbar,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        const RadarPathwaySlot(
          questionId: _qc,
          role: RadarQuestionRole.regionalCritical,
          order: 1,
          rationale:
              'Hard-stop régional majeur : la queue de cheval doit '
              'sortir en une question, pas en huit.',
        ),
        ..._socle,
        const RadarPathwaySlot(
          questionId: _aaa,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(gates: {RadarContextGate.ageOrBoneFragility}),
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
            ),
          ]),
          rationale:
              'AAA conditionnel (point Delphi n°1) : probabilité '
              'pré-test quasi nulle chez le lombalgique jeune sans FDR.',
        ),
        _fractureRisk,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.cervical: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.cervical,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        const RadarPathwaySlot(
          questionId: _cervVasc,
          role: RadarQuestionRole.regionalCritical,
          order: 1,
          rationale:
              'Hard-stop régional : dissection cervico-artérielle, '
              'drapeaux vasculaires avant toute technique.',
        ),
        ..._socle,
        const RadarPathwaySlot(
          questionId: _cardio,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.anteriorOrExertionalNeckPain},
            ),
          ]),
          rationale:
              'Angor projeté en cervical antérieur : une sous-question '
              'de porte couvre ce cas rare mais médico-légalement lourd.',
        ),
        _fractureRisk,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.thoracic: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.thoracic,
      // Point Delphi n°9 : pas de clôture mécanique validée en thoracique.
      reassureReachable: false,
      slots: [
        _fractureOpenOnTrauma,
        const RadarPathwaySlot(
          questionId: _cardio,
          role: RadarQuestionRole.regionalCritical,
          order: 1,
          rationale:
              'Hard-stop régional du thorax : douleur thoracique, '
              'dyspnée, malaise.',
        ),
        const RadarPathwaySlot(
          questionId: _ep,
          role: RadarQuestionRole.regionalCritical,
          order: 1,
          rationale:
              'Hard-stop régional du thorax : EP, l\'urgence à ne '
              'jamais manquer en accès direct.',
        ),
        ..._socle,
        _fractureRisk,
        // Pas de clôture : DEC_REASSURE inaccessible en thoracique en V1.
      ],
    ),
    RadarClinicalRegion
        .shoulderUpperLimbProximal: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.shoulderUpperLimbProximal,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        ..._socle,
        const RadarPathwaySlot(
          questionId: _cardio,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.leftShoulderExertionalOrSystemic},
            ),
          ]),
          rationale:
              'IDM projeté : « douleur d\'épaule gauche » liée à '
              'l\'effort ou avec dyspnée/malaise. Le cas qui finit en dossier.',
        ),
        _fractureRisk,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.upperLimbDistal: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.upperLimbDistal,
      reassureReachable: true,
      slots: [_fractureOpenOnTrauma, ..._socle, _fractureRisk, ..._closure],
    ),
    RadarClinicalRegion.hipLowerLimbProximal: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.hipLowerLimbProximal,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        ..._socle,
        const RadarPathwaySlot(
          questionId: _qc,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.lumbopelvicComponent},
            ),
          ]),
          rationale:
              'La douleur de hanche peut être une irradiation '
              'lombaire : la composante lombo-pelvienne rouvre le risque '
              'queue de cheval.',
        ),
        _fractureRisk,
        _tvpLowerLimb,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.kneeLeg: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.kneeLeg,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        ..._socle,
        _fractureRisk,
        _tvpLowerLimb,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.ankleFoot: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.ankleFoot,
      reassureReachable: true,
      slots: [
        _fractureOpenOnTrauma,
        ..._socle,
        _fractureRisk,
        _tvpLowerLimb,
        ..._closure,
      ],
    ),
    RadarClinicalRegion.diffuse: RadarClinicalPathwayDefinition(
      region: RadarClinicalRegion.diffuse,
      // Point Delphi n°6 : « diffus inexpliqué = jamais rassuré seul ».
      reassureReachable: false,
      // Diffus + trauma = polytraumatisme : orientation d'emblée.
      traumaTriggersImmediateOrientation: true,
      slots: [
        // Socle à seuil de décision abaissé (géré par la StopPolicy).
        ..._socle,
        const RadarPathwaySlot(
          questionId: _qc,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.lumbopelvicComponent},
            ),
          ]),
          rationale: 'Porte large diffus : composante lombo-pelvienne.',
        ),
        const RadarPathwaySlot(
          questionId: _cervVasc,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.headacheOrNeckPain},
            ),
          ]),
          rationale: 'Porte large diffus : céphalée/cervicalgie associée.',
        ),
        const RadarPathwaySlot(
          questionId: _cardio,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.dyspneaOrMalaise},
            ),
          ]),
          rationale: 'Porte large diffus : dyspnée/malaise.',
        ),
        const RadarPathwaySlot(
          questionId: _ep,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.dyspneaOrMalaise},
            ),
          ]),
          rationale: 'Porte large diffus : dyspnée/malaise.',
        ),
        const RadarPathwaySlot(
          questionId: _tvp,
          role: RadarQuestionRole.conditional,
          order: 6,
          activation: RadarActivationCondition([
            RadarActivationClause(
              triggers: {RadarClinicalTrigger.unilateralLowerLimbSigns},
            ),
          ]),
          rationale: 'Porte large diffus : signes unilatéraux de MI.',
        ),
        const RadarPathwaySlot(
          questionId: _aaa,
          role: RadarQuestionRole.conditional,
          order: 5,
          activation: RadarActivationCondition([
            RadarActivationClause(
              gates: {RadarContextGate.ageOrBoneFragility},
              triggers: {RadarClinicalTrigger.lumboabdominalPain},
            ),
            RadarActivationClause(
              triggers: {
                RadarClinicalTrigger.lumboabdominalPain,
                RadarClinicalTrigger.cardiovascularRiskFactors,
              },
            ),
          ]),
          rationale:
              'Porte large diffus : douleur lombo-abdominale '
              '+ (âge/fragilité OU FDR cardiovasculaires).',
        ),
        // Pas de clôture mécanique : une douleur diffuse n'a par définition
        // pas d'explication mécanique locale cohérente.
        // TODO(delphi-7): intégrer un item inflammatoire universel en diffus
        // après création au catalogue et vote.
      ],
    ),
  };

  RadarClinicalPathwayDefinition pathwayFor(RadarClinicalRegion region) =>
      _all[region]!;

  Iterable<RadarClinicalPathwayDefinition> get all => _all.values;
}
