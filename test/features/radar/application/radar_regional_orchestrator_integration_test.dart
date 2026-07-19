import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_engine_adapter.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_stop_policy.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_regional_clinical_orchestrator.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar regional orchestrator + V5 integration', () {
    test(
      'pathway lombaire simple reaches routine-compatible reassure in <= 8 questions',
      () {
        final result = _runRegionalScenario(
          region: RadarClinicalRegion.lumbar,
          positiveQuestionIds: {'v4_mechanical_pattern_001'},
        );

        expect(result.askedQuestionIds.length, lessThanOrEqualTo(8));
        expect(result.outcome, RadarSessionOutcome.reassure);
        expect(
          result.viewState.currentRiskLevel,
          ClinicalDecisionLevel.routine,
        );
        expect(result.session.triggeredHardStopIds, isEmpty);
      },
    );

    test('queue de cheval lets V5 hard stop take immediate priority', () {
      final result = _runRegionalScenario(
        region: RadarClinicalRegion.lumbar,
        positiveQuestionIds: {'v4_queue_cheval_001'},
      );

      expect(result.askedQuestionIds, ['v4_queue_cheval_001']);
      expect(result.outcome, RadarSessionOutcome.hardStop);
      expect(result.session.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(
        result.viewState.finalDecisionLevel,
        ClinicalDecisionLevel.emergency,
      );
    });

    test('thoracic cardio positive follows the real V5 hard stop', () {
      final result = _runRegionalScenario(
        region: RadarClinicalRegion.thoracic,
        positiveQuestionIds: {'v4_cardiorespiratory_001'},
      );

      expect(result.askedQuestionIds, ['v4_cardiorespiratory_001']);
      expect(result.outcome, RadarSessionOutcome.hardStop);
      expect(result.session.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(
        result.viewState.finalDecisionLevel,
        ClinicalDecisionLevel.emergency,
      );
    });

    test('knee TVP pathway reaches the real V5 vascular decision', () {
      final result = _runRegionalScenario(
        region: RadarClinicalRegion.kneeLeg,
        gates: {RadarContextGate.recentImmobilization},
        positiveQuestionIds: {'v4_vascular_tvp_001'},
      );

      expect(result.askedQuestionIds, contains('v4_vascular_tvp_001'));
      expect(result.outcome, RadarSessionOutcome.hardStop);
      expect(result.session.canReassure, isFalse);
      expect(
        result.viewState.finalDecisionLevel,
        ClinicalDecisionLevel.urgentReferral,
      );
    });

    test('AAA is asked only when the lumbar context activates it', () {
      final simple = _runRegionalScenario(
        region: RadarClinicalRegion.lumbar,
        positiveQuestionIds: const {},
      );
      expect(
        simple.askedQuestionIds,
        isNot(contains('v4_aaa_vascular_abdominal_001')),
      );

      final aaa = _runRegionalScenario(
        region: RadarClinicalRegion.lumbar,
        gates: {RadarContextGate.ageOrBoneFragility},
        positiveQuestionIds: {'v4_aaa_vascular_abdominal_001'},
      );
      expect(aaa.askedQuestionIds, contains('v4_aaa_vascular_abdominal_001'));
      expect(aaa.outcome, RadarSessionOutcome.hardStop);
      expect(
        aaa.viewState.finalDecisionLevel,
        ClinicalDecisionLevel.urgentReferral,
      );
    });

    test(
      'oncologic, infectious and fracture pathways delegate clinical level to V5',
      () {
        final cases = {
          'v4_oncologic_context_001': ClinicalDecisionLevel.urgentReferral,
          'v4_infectious_fragility_001': ClinicalDecisionLevel.urgentReferral,
          'v4_fracture_risk_001': ClinicalDecisionLevel.urgentReferral,
        };

        for (final entry in cases.entries) {
          final result = _runRegionalScenario(
            region: RadarClinicalRegion.lumbar,
            gates: entry.key == 'v4_fracture_risk_001'
                ? {RadarContextGate.ageOrBoneFragility}
                : const {},
            positiveQuestionIds: {entry.key},
          );

          expect(
            result.outcome,
            RadarSessionOutcome.hardStop,
            reason: entry.key,
          );
          expect(
            result.viewState.finalDecisionLevel,
            entry.value,
            reason: entry.key,
          );
        }
      },
    );

    test(
      'cardio-respiratory overflow is activated after a non hard-stop red flag',
      () {
        final orch = RadarRegionalClinicalOrchestrator(
          engineAdapter: _RedFlagWithoutHardStopAdapter(),
          sessionIdFactory: () => 'radar-overflow-test',
        );
        orch.startSession(region: RadarClinicalRegion.lumbar, gates: const {});

        final first = orch.nextQuestionId();
        final firstStep = orch.answerQuestion(first!, isPositive: true);
        expect(firstStep.outcome, RadarSessionOutcome.delegateToEngine);
        expect(orch.engineHasTakenOver, isTrue);
        expect(orch.nextQuestionId(), 'v4_cardiorespiratory_001');

        final secondStep = orch.answerCurrentQuestion(isPositive: false);
        expect(
          secondStep.trace?.activatedOverflowIds,
          contains('v4_cardiorespiratory_001'),
        );
      },
    );

    test(
      'thoracic and diffuse sessions cannot produce reassurance in V0.1',
      () {
        final thoracic = _runRegionalScenario(
          region: RadarClinicalRegion.thoracic,
          positiveQuestionIds: const {},
        );
        expect(thoracic.outcome, RadarSessionOutcome.monitor);

        final diffuse = _runRegionalScenario(
          region: RadarClinicalRegion.diffuse,
          positiveQuestionIds: const {},
        );
        expect(
          diffuse.outcome,
          RadarSessionOutcome.monitorWithShortFollowUpAndLetter,
        );
      },
    );

    test('diffuse + trauma starts with immediate orientation', () {
      final orch = RadarRegionalClinicalOrchestrator();

      final outcome = orch.startSession(
        region: RadarClinicalRegion.diffuse,
        gates: const {RadarContextGate.trauma},
      );

      expect(outcome, RadarSessionOutcome.immediateOrientation);
      expect(orch.nextQuestionId(), isNull);
    });

    test(
      'trace always exposes the explicit non validated experimental status',
      () {
        final result = _runRegionalScenario(
          region: RadarClinicalRegion.lumbar,
          positiveQuestionIds: {'v4_mechanical_pattern_001'},
        );

        final trace = result.trace;
        expect(trace, isNotNull);
        expect(trace!.matrixVersion, kRadarPathwayMatrixVersion);
        expect(trace.validationStatus, 'NON VALIDÉE');
        expect(trace.operatingMode, RadarClinicalOperatingMode.experimental);
        expect(trace.region, RadarClinicalRegion.lumbar);
        expect(trace.contextGates, isEmpty);
        expect(trace.askedQuestionIds, result.askedQuestionIds);
        expect(
          trace.excludedQuestionRationales,
          contains('v4_embolie_pulmonaire_001'),
        );
        expect(trace.engineVersion, kRadarClinicalEngineVersion);
        expect(trace.producedOutcome, RadarSessionOutcome.reassure);
      },
    );

    test(
      'CAS_FN representatives remain non reassured and CAS_FP remains routine',
      () {
        final fnCases = [
          _RegionalCase(RadarClinicalRegion.lumbar, {'v4_queue_cheval_001'}),
          _RegionalCase(RadarClinicalRegion.lumbar, {
            'v4_oncologic_context_001',
          }),
          _RegionalCase(RadarClinicalRegion.lumbar, {
            'v4_infectious_fragility_001',
          }),
          _RegionalCase(RadarClinicalRegion.lumbar, {
            'v4_neurologic_deficit_001',
          }),
          _RegionalCase(
            RadarClinicalRegion.lumbar,
            {'v4_fracture_risk_001'},
            gates: {RadarContextGate.ageOrBoneFragility},
          ),
        ];

        for (final fnCase in fnCases) {
          final result = _runRegionalScenario(
            region: fnCase.region,
            gates: fnCase.gates,
            positiveQuestionIds: fnCase.positiveQuestionIds,
          );
          expect(
            result.viewState.currentRiskLevel,
            isNot(ClinicalDecisionLevel.routine),
          );
          expect(result.session.canReassure, isFalse);
        }

        final fp = _runRegionalScenario(
          region: RadarClinicalRegion.lumbar,
          positiveQuestionIds: {'v4_mechanical_pattern_001'},
        );
        expect(fp.viewState.currentRiskLevel, ClinicalDecisionLevel.routine);
        expect(fp.session.canReassure, isTrue);
      },
    );
  });
}

_RegionalRunResult _runRegionalScenario({
  required RadarClinicalRegion region,
  required Set<String> positiveQuestionIds,
  Set<RadarContextGate> gates = const {},
  Set<RadarClinicalTrigger> triggers = const {},
}) {
  final orch = RadarRegionalClinicalOrchestrator(
    sessionIdFactory: () => 'radar-integration-test',
  );
  final startOutcome = orch.startSession(
    region: region,
    gates: gates,
    triggers: triggers,
  );
  if (startOutcome != null) {
    return _RegionalRunResult(
      askedQuestionIds: const [],
      outcome: startOutcome,
      session: orch.engineSession!,
      viewState: orch.engineViewState!,
      trace: orch.lastTrace,
    );
  }

  RadarClinicalOrchestratorStep? step;
  final asked = <String>[];
  var guard = 0;
  while (orch.nextQuestionId() != null) {
    final questionId = orch.nextQuestionId()!;
    asked.add(questionId);
    step = orch.answerCurrentQuestion(
      isPositive: positiveQuestionIds.contains(questionId),
    );
    guard++;
    if (guard > 30) {
      throw StateError('Radar scenario did not terminate: $asked');
    }
    if (step.outcome == RadarSessionOutcome.hardStop) {
      break;
    }
  }

  return _RegionalRunResult(
    askedQuestionIds: asked,
    outcome: step?.outcome,
    session: step?.engineSession ?? orch.engineSession!,
    viewState: step?.engineViewState ?? orch.engineViewState!,
    trace: step?.trace ?? orch.lastTrace,
  );
}

class _RegionalRunResult {
  final List<String> askedQuestionIds;
  final RadarSessionOutcome? outcome;
  final ClinicalAdaptiveSessionV5 session;
  final ClinicalAdaptiveViewStateV5 viewState;
  final RadarClinicalSessionTrace? trace;

  const _RegionalRunResult({
    required this.askedQuestionIds,
    required this.outcome,
    required this.session,
    required this.viewState,
    required this.trace,
  });
}

class _RegionalCase {
  final RadarClinicalRegion region;
  final Set<String> positiveQuestionIds;
  final Set<RadarContextGate> gates;

  const _RegionalCase(
    this.region,
    this.positiveQuestionIds, {
    this.gates = const {},
  });
}

class _RedFlagWithoutHardStopAdapter extends RadarClinicalEngineAdapter {
  @override
  ClinicalAdaptiveSessionV5 initialSession() {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: const {},
      positiveFlagIds: const [],
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: questionById('v4_queue_cheval_001'),
      reasoningSummary: 'Fake V5 state for Radar delegation test.',
    );
  }

  @override
  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    final answered = {...session.answeredQuestionIds, questionId: isPositive};
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: answered,
      positiveFlagIds: isPositive
          ? const ['fake_red_flag']
          : session.positiveFlagIds,
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: questionId == 'v4_cardiorespiratory_001'
          ? null
          : questionById('v4_cardiorespiratory_001'),
      reasoningSummary: 'Fake V5 red flag without hard stop.',
    );
  }

  @override
  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    final isFinal = session.nextQuestion == null;
    return ClinicalAdaptiveViewStateV5(
      sessionId: sessionId,
      questionId: session.nextQuestion?.id,
      patientQuestionText: session.nextQuestion?.text,
      canAnswer: !isFinal,
      answeredCount: session.answeredQuestionIds.length,
      totalQuestionCount: 2,
      progressRatio: session.answeredQuestionIds.length / 2,
      progressLabel: 'Fake V5',
      currentRiskLevel: session.positiveFlagIds.isEmpty
          ? ClinicalDecisionLevel.routine
          : ClinicalDecisionLevel.medicalAdvice,
      currentRiskLabel: 'Fake V5',
      hardStopId: null,
      hardStopTitle: null,
      finalDecisionLevel: isFinal ? ClinicalDecisionLevel.medicalAdvice : null,
      finalDecisionLabel: isFinal ? 'Avis médical recommandé' : null,
      primaryHypothesisId: session.positiveFlagIds.isEmpty ? null : 'fake',
      primaryHypothesisTitle: session.positiveFlagIds.isEmpty ? null : 'Fake',
      probabilityLevel: session.positiveFlagIds.isEmpty
          ? null
          : ClinicalQualitativeProbabilityV5.high,
      shortExplanation: 'Fake V5 state.',
      technicalSummary: session.reasoningSummary,
      isFinal: isFinal,
    );
  }
}
