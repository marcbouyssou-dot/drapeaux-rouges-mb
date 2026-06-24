import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_question_engine_v5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalAdaptiveQuestionEngineV5 clinical validation scenarios', () {
    for (final scenario in _clinicalScenarios) {
      test('${scenario.caseId} matches expected V5 outcome', () {
        final result = _runScenario(scenario);

        expect(
          result.decision,
          scenario.expectedDecision,
          reason: scenario.caseId,
        );
        expect(
          result.dominantHypothesisId,
          scenario.expectedDominantHypothesisId,
          reason: scenario.caseId,
        );
        expect(
          result.probability,
          scenario.expectedProbability,
          reason: scenario.caseId,
        );
        expect(
          result.hardStopId,
          scenario.expectedHardStopId,
          reason: scenario.caseId,
        );
        expect(
          result.session.answeredQuestionIds.length,
          scenario.expectedQuestionCount,
          reason: scenario.caseId,
        );
        expect(
          result.session.nextQuestion?.id,
          scenario.expectedNextQuestionId,
          reason: scenario.caseId,
        );
      });
    }
  });
}

final _clinicalScenarios = [
  _ClinicalScenario(
    caseId: 'CAS_01_LOMBALGIE_SIMPLE',
    responses: _allNegativeResponses,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedDominantHypothesisId: null,
    expectedProbability: null,
    expectedHardStopId: null,
    expectedQuestionCount: 15,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_02_CANCER',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', false),
      _QuestionAnswer('v4_neurologic_deficit_001', false),
      _QuestionAnswer('v4_fracture_risk_001', false),
      _QuestionAnswer('v4_vascular_tvp_001', false),
      _QuestionAnswer('v4_oncologic_context_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId: 'v5_hypothesis_pathologie_oncologique',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_oncologique',
    expectedQuestionCount: 9,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_03_DOULEUR_THORACIQUE',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedDominantHypothesisId:
        'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
    expectedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
    expectedHardStopId: 'v5_hard_stop_cardiorespiratoire',
    expectedQuestionCount: 4,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_04_CERVICALGIE_VASCULAIRE',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', false),
      _QuestionAnswer('v4_neurologic_deficit_001', false),
      _QuestionAnswer('v4_fracture_risk_001', false),
      _QuestionAnswer('v4_vascular_tvp_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId: 'v5_hypothesis_tvp',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_vasculaire_tvp',
    expectedQuestionCount: 8,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_05_TVP',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', false),
      _QuestionAnswer('v4_neurologic_deficit_001', false),
      _QuestionAnswer('v4_fracture_risk_001', false),
      _QuestionAnswer('v4_vascular_tvp_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId: 'v5_hypothesis_tvp',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_vasculaire_tvp',
    expectedQuestionCount: 8,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_06_INFECTION',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId: 'v5_hypothesis_infection_systemique_fragile',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_infectieux_fragile',
    expectedQuestionCount: 5,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_07_FRACTURE',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', false),
      _QuestionAnswer('v4_neurologic_deficit_001', false),
      _QuestionAnswer('v4_fracture_risk_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId: 'v5_hypothesis_fracture_fragilite',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_risque_fracturaire',
    expectedQuestionCount: 7,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_08_DEFICIT_NEUROLOGIQUE',
    responses: const [
      _QuestionAnswer('v4_queue_cheval_001', false),
      _QuestionAnswer('v4_embolie_pulmonaire_001', false),
      _QuestionAnswer('v4_fracture_ouverte_001', false),
      _QuestionAnswer('v4_cardiorespiratory_001', false),
      _QuestionAnswer('v4_infectious_fragility_001', false),
      _QuestionAnswer('v4_neurologic_deficit_001', true),
    ],
    expectedDecision: ClinicalDecisionLevel.urgentReferral,
    expectedDominantHypothesisId:
        'v5_hypothesis_atteinte_neurologique_progressive',
    expectedProbability: ClinicalQualitativeProbabilityV5.high,
    expectedHardStopId: 'v5_hard_stop_neurologique',
    expectedQuestionCount: 6,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_09_YELLOW_FLAGS',
    responses: _allNegativeResponses,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedDominantHypothesisId: null,
    expectedProbability: null,
    expectedHardStopId: null,
    expectedQuestionCount: 15,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_10_REASSURANCE',
    responses: _allNegativeResponses,
    expectedDecision: ClinicalDecisionLevel.routine,
    expectedDominantHypothesisId: null,
    expectedProbability: null,
    expectedHardStopId: null,
    expectedQuestionCount: 15,
    expectedNextQuestionId: null,
  ),
  _ClinicalScenario(
    caseId: 'CAS_11_QUEUE_DE_CHEVAL',
    responses: const [_QuestionAnswer('v4_queue_cheval_001', true)],
    expectedDecision: ClinicalDecisionLevel.emergency,
    expectedDominantHypothesisId: 'v5_hypothesis_queue_cheval',
    expectedProbability: ClinicalQualitativeProbabilityV5.veryHigh,
    expectedHardStopId: 'v5_hard_stop_queue_cheval',
    expectedQuestionCount: 1,
    expectedNextQuestionId: null,
  ),
];

const _allNegativeResponses = [
  _QuestionAnswer('v4_queue_cheval_001', false),
  _QuestionAnswer('v4_embolie_pulmonaire_001', false),
  _QuestionAnswer('v4_fracture_ouverte_001', false),
  _QuestionAnswer('v4_cardiorespiratory_001', false),
  _QuestionAnswer('v4_infectious_fragility_001', false),
  _QuestionAnswer('v4_neurologic_deficit_001', false),
  _QuestionAnswer('v4_fracture_risk_001', false),
  _QuestionAnswer('v4_vascular_tvp_001', false),
  _QuestionAnswer('v4_oncologic_context_001', false),
  _QuestionAnswer('v4_cervical_vascular_001', false),
  _QuestionAnswer('v4_aaa_vascular_abdominal_001', false),
  _QuestionAnswer('v4_mechanical_pattern_001', false),
  _QuestionAnswer('v4_mechanical_overload_001', false),
  _QuestionAnswer('v4_known_stable_mechanical_episode_001', false),
  _QuestionAnswer('v4_structured_absence_systemic_signs_001', false),
];

_ScenarioResult _runScenario(_ClinicalScenario scenario) {
  final engine = ClinicalAdaptiveQuestionEngineV5();
  var session = engine.initialSession();

  for (final response in scenario.responses) {
    expect(
      session.nextQuestion?.id,
      response.questionId,
      reason: '${scenario.caseId} should follow adaptive order',
    );

    session = engine.answerQuestion(
      session: session,
      questionId: response.questionId,
      isPositive: response.isPositive,
    );
  }

  final hardStopId = session.triggeredHardStopIds.isEmpty
      ? null
      : session.triggeredHardStopIds.first;
  final dominant = _dominantStrengthenedHypothesis(session);
  final decision = _decisionFor(session, hardStopId, dominant?.hypothesisId);

  return _ScenarioResult(
    session: session,
    decision: decision,
    dominantHypothesisId: dominant?.hypothesisId,
    probability: dominant?.probability,
    hardStopId: hardStopId,
  );
}

ClinicalDecisionLevel _decisionFor(
  ClinicalAdaptiveSessionV5 session,
  String? hardStopId,
  String? dominantHypothesisId,
) {
  if (hardStopId != null) {
    return ClinicalHardStopCatalogV5.rules
        .singleWhere((rule) => rule.id == hardStopId)
        .expectedDecisionLevel;
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

class _ClinicalScenario {
  final String caseId;
  final List<_QuestionAnswer> responses;
  final ClinicalDecisionLevel expectedDecision;
  final String? expectedDominantHypothesisId;
  final ClinicalQualitativeProbabilityV5? expectedProbability;
  final String? expectedHardStopId;
  final int expectedQuestionCount;
  final String? expectedNextQuestionId;

  const _ClinicalScenario({
    required this.caseId,
    required this.responses,
    required this.expectedDecision,
    required this.expectedDominantHypothesisId,
    required this.expectedProbability,
    required this.expectedHardStopId,
    required this.expectedQuestionCount,
    required this.expectedNextQuestionId,
  });
}

class _QuestionAnswer {
  final String questionId;
  final bool isPositive;

  const _QuestionAnswer(this.questionId, this.isPositive);
}

class _ScenarioResult {
  final ClinicalAdaptiveSessionV5 session;
  final ClinicalDecisionLevel decision;
  final String? dominantHypothesisId;
  final ClinicalQualitativeProbabilityV5? probability;
  final String? hardStopId;

  const _ScenarioResult({
    required this.session,
    required this.decision,
    required this.dominantHypothesisId,
    required this.probability,
    required this.hardStopId,
  });
}

class _DominantHypothesis {
  final String hypothesisId;
  final ClinicalQualitativeProbabilityV5 probability;

  const _DominantHypothesis(this.hypothesisId, this.probability);
}
