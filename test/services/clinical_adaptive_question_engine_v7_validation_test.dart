import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_script_v7.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_question_engine_v5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalAdaptiveQuestionEngineV5 V7 validation scenarios', () {
    test('declares CAS_FN_01 to CAS_FN_15 and CAS_FP_01 to CAS_FP_15', () {
      expect(_v7ValidationScenarios, hasLength(30));
      expect(
        _v7ValidationScenarios.map((scenario) => scenario.id),
        containsAll([
          for (var index = 1; index <= 15; index++)
            'CAS_FN_${index.toString().padLeft(2, '0')}',
          for (var index = 1; index <= 15; index++)
            'CAS_FP_${index.toString().padLeft(2, '0')}',
        ]),
      );
    });

    for (final scenario in _v7ValidationScenarios) {
      test(scenario.label, () {
        final result = _runScenario(scenario);

        expect(result.scriptId, scenario.expectedScriptId, reason: scenario.id);
        expect(
          result.dominantHypothesisId,
          scenario.expectedDominantHypothesisId,
          reason: scenario.id,
        );
        expect(result.decision, scenario.expectedDecision, reason: scenario.id);
        expect(
          result.hardStopState,
          scenario.expectedHardStopState,
          reason: scenario.id,
        );
        expect(
          result.session.canReassure,
          scenario.expectedCanReassure,
          reason: scenario.id,
        );
      }, skip: scenario.skipReason);
    }
  });
}

final _v7ValidationScenarios = [
  _V7ValidationScenario(
    id: 'CAS_FN_01',
    title: 'Queue de cheval isolée',
    positiveQuestionIds: {'v4_queue_cheval_001'},
    expectedScriptId: ClinicalScriptIdsV7.queueDeCheval,
    expectedDominantHypothesisId: 'v5_hypothesis_queue_cheval',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'Un signe critique isolé doit imposer une urgence immédiate.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_02',
    title: 'Embolie pulmonaire suspectée isolée',
    positiveQuestionIds: {'v4_embolie_pulmonaire_001'},
    expectedScriptId: ClinicalScriptIdsV7.vasculaire,
    expectedDominantHypothesisId: 'v5_hypothesis_embolie_pulmonaire',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'Dyspnée brutale ou douleur thoracique embolique ne doit pas être rassurée.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_03',
    title: 'Fracture ouverte suspectée',
    positiveQuestionIds: {'v4_fracture_ouverte_001'},
    expectedScriptId: ClinicalScriptIdsV7.fracture,
    expectedDominantHypothesisId: 'v5_hypothesis_fracture_ouverte',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment: 'Une fracture ouverte suspectée impose une urgence.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_04',
    title: 'Douleur thoracique avec signe cardio-respiratoire',
    positiveQuestionIds: {'v4_cardiorespiratory_001'},
    expectedScriptId: ClinicalScriptIdsV7.vasculaire,
    expectedDominantHypothesisId:
        'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'L’association douleur thoracique et dyspnée/malaise reste bloquante.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_05',
    title: 'Infectieux fragile',
    positiveQuestionIds: {'v4_infectious_fragility_001'},
    expectedScriptId: ClinicalScriptIdsV7.infectieux,
    expectedDominantHypothesisId: 'v5_hypothesis_infection_systemique_fragile',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment: 'Fièvre avec fragilité doit empêcher la réassurance.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_06',
    title: 'Déficit neurologique progressif',
    positiveQuestionIds: {'v4_neurologic_deficit_001'},
    expectedScriptId: ClinicalScriptIdsV7.neurologique,
    expectedDominantHypothesisId:
        'v5_hypothesis_atteinte_neurologique_progressive',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment: 'Un déficit neurologique progressif doit être orienté.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_07',
    title: 'Risque fracturaire sur terrain fragile',
    positiveQuestionIds: {'v4_fracture_risk_001'},
    expectedScriptId: ClinicalScriptIdsV7.fracture,
    expectedDominantHypothesisId: 'v5_hypothesis_fracture_fragilite',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment:
        'Traumatisme avec fragilité osseuse doit bloquer une réassurance simple.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_08',
    title: 'Suspicion TVP',
    positiveQuestionIds: {'v4_vascular_tvp_001'},
    expectedScriptId: ClinicalScriptIdsV7.vasculaire,
    expectedDominantHypothesisId: 'v5_hypothesis_tvp',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment: 'Une suspicion TVP doit déclencher un avis rapide.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_09',
    title: 'Cluster oncologique',
    positiveQuestionIds: {'v4_oncologic_context_001'},
    expectedScriptId: ClinicalScriptIdsV7.oncologique,
    expectedDominantHypothesisId: 'v5_hypothesis_pathologie_oncologique',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment:
        'Le contexte oncologique avec signes associés doit orienter.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_10',
    title: 'Cervical vasculaire suspect',
    positiveQuestionIds: {'v4_cervical_vascular_001'},
    expectedScriptId: ClinicalScriptIdsV7.cervicalVasculaire,
    expectedDominantHypothesisId: 'v5_hypothesis_cervical_vasculaire',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment:
        'Les signes neurovasculaires cervicaux doivent empêcher la réassurance mécanique.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_11',
    title: 'AAA ou vasculaire abdominal suspect',
    positiveQuestionIds: {'v4_aaa_vascular_abdominal_001'},
    expectedScriptId: ClinicalScriptIdsV7.aaaVasculaireAbdominal,
    expectedDominantHypothesisId: 'v5_hypothesis_aaa_vasculaire_abdominal',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment:
        'Douleur profonde brutale sur terrain vasculaire doit empêcher la réassurance.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_12',
    title: 'Queue de cheval malgré contexte mécanique',
    positiveQuestionIds: {'v4_queue_cheval_001'},
    expectedScriptId: ClinicalScriptIdsV7.queueDeCheval,
    expectedDominantHypothesisId: 'v5_hypothesis_queue_cheval',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'Le moteur ne doit pas neutraliser un signe critique par contexte mécanique.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_13',
    title: 'Embolie pulmonaire après premier danger négatif',
    positiveQuestionIds: {'v4_embolie_pulmonaire_001'},
    expectedScriptId: ClinicalScriptIdsV7.vasculaire,
    expectedDominantHypothesisId: 'v5_hypothesis_embolie_pulmonaire',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'Une réponse négative préalable ne doit pas diminuer un signal critique suivant.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_14',
    title: 'Cardio-respiratoire après dangers immédiats négatifs',
    positiveQuestionIds: {'v4_cardiorespiratory_001'},
    expectedScriptId: ClinicalScriptIdsV7.vasculaire,
    expectedDominantHypothesisId:
        'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedHardStopState: ClinicalHardStopStateV5.confirmed,
    expectedCanReassure: false,
    clinicalComment:
        'Les négatifs initiaux ne doivent pas masquer un cluster cardio-respiratoire.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FN_15',
    title: 'Cervical vasculaire après TVP négative',
    positiveQuestionIds: {'v4_cervical_vascular_001'},
    expectedScriptId: ClinicalScriptIdsV7.cervicalVasculaire,
    expectedDominantHypothesisId: 'v5_hypothesis_cervical_vasculaire',
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedHardStopState: ClinicalHardStopStateV5.suspected,
    expectedCanReassure: false,
    clinicalComment:
        'Le domaine cervical vasculaire doit rester testable après un item TVP négatif.',
  ),
  _V7ValidationScenario(
    id: 'CAS_FP_01',
    title: 'Réassurance sans signal organique',
    positiveQuestionIds: const {},
    expectedScriptId: null,
    expectedDominantHypothesisId: null,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedHardStopState: ClinicalHardStopStateV5.absent,
    expectedCanReassure: true,
    clinicalComment:
        'Toutes les questions représentées sont négatives : le moteur peut rassurer.',
  ),
  _mechanicalFp(
    2,
    'Douleur strictement mécanique reproductible',
    {'v4_mechanical_pattern_001', 'v4_structured_absence_systemic_signs_001'},
    'Profil mécanique reproductible avec absence structurée de signes systémiques.',
  ),
  _mechanicalFp(
    3,
    'Amélioration nette au mouvement sans signe systémique',
    {'v4_mechanical_pattern_001', 'v4_structured_absence_systemic_signs_001'},
    'Profil mécanique représenté sans signal systémique positif.',
  ),
  _mechanicalFp(
    4,
    'Douleur connue, épisode identique, évolution favorable',
    {
      'v4_known_stable_mechanical_episode_001',
      'v4_structured_absence_systemic_signs_001',
    },
    'Épisode mécanique connu stable et absence de signes généraux.',
  ),
  _psychosocialFp(
    5,
    'Contexte psychosocial isolé sans signe organique',
    {'v4_psychosocial_disproportionate_impact_001'},
    'Facteur psychosocial isolé sans signal organique positif.',
  ),
  _psychosocialFp(
    6,
    'Anxiété élevée sans signe clinique critique',
    {'v4_psychosocial_anxiety_001'},
    'Anxiété importante isolée, sans hard stop ni signal critique.',
  ),
  _psychosocialFp(
    7,
    'Peur-évitement isolée sans red flag',
    {'v4_psychosocial_fear_movement_001'},
    'Peur du mouvement isolée sans red flag.',
  ),
  _mechanicalFp(
    8,
    'Douleur chronique stable sans changement récent',
    {'v4_known_stable_mechanical_episode_001'},
    'Stabilité d’un épisode connu sans signal organique dans le moteur.',
  ),
  _mechanicalFp(
    9,
    'Réassurance après trauma mineur sans critère fracturaire',
    {'v4_mechanical_overload_001', 'v4_structured_absence_systemic_signs_001'},
    'Surcharge mécanique cohérente sans critère fracturaire positif.',
  ),
  _mechanicalFp(
    10,
    'Cervicalgie mécanique sans signe neurovasculaire',
    {'v4_mechanical_pattern_001'},
    'Cervicalgie mécanique avec question neurovasculaire négative.',
  ),
  _mechanicalFp(
    11,
    'Lombalgie mécanique sans signe AAA',
    {'v4_mechanical_pattern_001', 'v4_structured_absence_systemic_signs_001'},
    'Lombalgie mécanique avec question AAA négative.',
  ),
  _mechanicalFp(
    12,
    'Symptôme vague sans cluster systémique',
    {'v4_structured_absence_systemic_signs_001'},
    'Absence structurée de cluster systémique représentable.',
  ),
  _mechanicalFp(
    13,
    'Douleur thoracique musculosquelettique rassurante',
    {'v4_mechanical_pattern_001', 'v4_structured_absence_systemic_signs_001'},
    'Profil musculosquelettique avec cluster cardio-respiratoire négatif.',
  ),
  _mechanicalFp(
    14,
    'Mollet douloureux sans critères TVP',
    {'v4_mechanical_pattern_001', 'v4_structured_absence_systemic_signs_001'},
    'Douleur de mollet représentée par un profil mécanique avec item TVP négatif.',
  ),
  _psychosocialFp(
    15,
    'Yellow flags isolés sans signal organique',
    {
      'v4_psychosocial_catastrophizing_001',
      'v4_psychosocial_fear_movement_001',
      'v4_psychosocial_anxiety_001',
    },
    'Yellow flags isolés représentés sans signal organique prioritaire.',
  ),
];

_V7ValidationScenario _mechanicalFp(
  int index,
  String title,
  Set<String> positiveQuestionIds,
  String clinicalComment,
) {
  return _V7ValidationScenario(
    id: 'CAS_FP_${index.toString().padLeft(2, '0')}',
    title: title,
    positiveQuestionIds: positiveQuestionIds,
    expectedScriptId: ClinicalScriptIdsV7.mecanique,
    expectedDominantHypothesisId: null,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedHardStopState: ClinicalHardStopStateV5.absent,
    expectedCanReassure: true,
    clinicalComment: clinicalComment,
  );
}

_V7ValidationScenario _psychosocialFp(
  int index,
  String title,
  Set<String> positiveQuestionIds,
  String clinicalComment,
) {
  return _V7ValidationScenario(
    id: 'CAS_FP_${index.toString().padLeft(2, '0')}',
    title: title,
    positiveQuestionIds: positiveQuestionIds,
    expectedScriptId: ClinicalScriptIdsV7.psychosocial,
    expectedDominantHypothesisId: null,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedHardStopState: ClinicalHardStopStateV5.absent,
    expectedCanReassure: true,
    clinicalComment: clinicalComment,
  );
}

_V7ScenarioResult _runScenario(_V7ValidationScenario scenario) {
  final engine = ClinicalAdaptiveQuestionEngineV5();
  var session = engine.initialSession();

  while (session.nextQuestion != null) {
    final questionId = session.nextQuestion!.id;
    final isPositive = scenario.positiveQuestionIds.contains(questionId);

    session = engine.answerQuestion(
      session: session,
      questionId: questionId,
      isPositive: isPositive,
    );
  }

  final dominant = _dominantStrengthenedHypothesis(session);
  final hardStop = session.triggeredHardStopIds.isEmpty
      ? null
      : ClinicalHardStopCatalogV5.ruleById(session.triggeredHardStopIds.first);

  return _V7ScenarioResult(
    session: session,
    scriptId: _dominantScriptId(session),
    dominantHypothesisId: dominant?.hypothesisId,
    decision: _decisionFor(hardStop, dominant?.hypothesisId),
    hardStopState: session.hardStopState,
  );
}

String? _dominantScriptId(ClinicalAdaptiveSessionV5 session) {
  final positiveQuestionIds = session.answeredQuestionIds.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toSet();
  if (positiveQuestionIds.isEmpty) {
    return null;
  }

  for (final question in ClinicalScreeningQuestionnaireV4.questions) {
    if (positiveQuestionIds.contains(question.id)) {
      return question.scriptId;
    }
  }

  return null;
}

ClinicalDecisionLevel _decisionFor(
  ClinicalHardStopRuleV5? hardStop,
  String? dominantHypothesisId,
) {
  if (hardStop != null) {
    return hardStop.expectedDecisionLevel;
  }

  if (dominantHypothesisId != null) {
    return ClinicalHypothesisCatalogV5.hypotheses
        .singleWhere((hypothesis) => hypothesis.id == dominantHypothesisId)
        .targetDecisionLevel;
  }

  return ClinicalDecisionLevel.routine;
}

_DominantHypothesis? _dominantStrengthenedHypothesis(
  ClinicalAdaptiveSessionV5 session,
) {
  _DominantHypothesis? dominant;

  for (final entry in session.hypothesisProbabilities.entries) {
    final isStrengthened =
        entry.value == ClinicalQualitativeProbabilityV5.high ||
        entry.value == ClinicalQualitativeProbabilityV5.veryHigh;
    if (!isStrengthened) {
      continue;
    }

    if (dominant == null || _rank(entry.value) > _rank(dominant.probability)) {
      dominant = _DominantHypothesis(entry.key, entry.value);
    }
  }

  return dominant;
}

int _rank(ClinicalQualitativeProbabilityV5 probability) {
  return ClinicalQualitativeProbabilityV5.values.indexOf(probability);
}

class _V7ValidationScenario {
  final String id;
  final String title;
  final Set<String> positiveQuestionIds;
  final Set<String> negativeQuestionIds;
  final String? expectedScriptId;
  final String? expectedDominantHypothesisId;
  final ClinicalDecisionLevel expectedDecision;
  final ClinicalHardStopStateV5 expectedHardStopState;
  final bool expectedCanReassure;
  final String clinicalComment;
  final String? skipReason;

  const _V7ValidationScenario({
    required this.id,
    required this.title,
    required this.positiveQuestionIds,
    this.negativeQuestionIds = const {},
    required this.expectedScriptId,
    required this.expectedDominantHypothesisId,
    required this.expectedDecision,
    required this.expectedHardStopState,
    required this.expectedCanReassure,
    required this.clinicalComment,
    this.skipReason,
  });

  String get label => '$id $title';
}

class _V7ScenarioResult {
  final ClinicalAdaptiveSessionV5 session;
  final String? scriptId;
  final String? dominantHypothesisId;
  final ClinicalDecisionLevel decision;
  final ClinicalHardStopStateV5 hardStopState;

  const _V7ScenarioResult({
    required this.session,
    required this.scriptId,
    required this.dominantHypothesisId,
    required this.decision,
    required this.hardStopState,
  });
}

class _DominantHypothesis {
  final String hypothesisId;
  final ClinicalQualitativeProbabilityV5 probability;

  const _DominantHypothesis(this.hypothesisId, this.probability);
}
