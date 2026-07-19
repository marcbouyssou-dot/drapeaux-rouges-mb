import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_engine_adapter.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_stop_policy.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_regional_clinical_orchestrator.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar contextual gates and triggers', () {
    test('initial context opens a branch that is closed by default', () {
      final orch = RadarRegionalClinicalOrchestrator(
        engineAdapter: _NeutralAdapter(),
        sessionIdFactory: () => 'radar-context-test',
      );

      orch.startSession(
        region: RadarClinicalRegion.lumbar,
        initialContext: const RadarClinicalInitialContext(
          triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
        ),
      );

      expect(_remainingIds(orch), contains('v4_aaa_vascular_abdominal_001'));
      expect(
        orch.lastTrace?.contextActivations,
        isNull,
        reason: 'No step trace has been produced before the first answer.',
      );
    });

    test(
      'a positive answer can activate a trigger and open a conditional slot',
      () {
        final orch = RadarRegionalClinicalOrchestrator(
          engineAdapter: _NeutralAdapter(),
          sessionIdFactory: () => 'radar-context-test',
        );
        orch.startSession(
          region: RadarClinicalRegion.hipLowerLimbProximal,
          gates: const {},
        );

        final firstQuestion = orch.nextQuestionId()!;
        final step = orch.answerQuestion(
          firstQuestion,
          isPositive: true,
          responseContext: const RadarClinicalResponseContext(
            triggers: {RadarClinicalTrigger.lumbopelvicComponent},
          ),
        );

        expect(step.outcome, isNull);
        expect(
          step.trace?.clinicalTriggers,
          contains(RadarClinicalTrigger.lumbopelvicComponent),
        );
        expect(
          step.trace?.contextActivations.single.id,
          'trigger.lumbopelvicComponent',
        );
        expect(
          step.trace?.contextActivations.single.source,
          RadarContextActivationSource.clinicalAnswer,
        );
        expect(
          step.trace?.contextActivations.single.sourceQuestionId,
          firstQuestion,
        );
        expect(
          step.trace?.contextActivations.single.accessibleQuestionIds,
          contains('v4_queue_cheval_001'),
        );
        expect(_remainingIds(orch), contains('v4_queue_cheval_001'));
      },
    );

    test('a negative answer does not activate contextual triggers', () {
      final orch = RadarRegionalClinicalOrchestrator(
        engineAdapter: _NeutralAdapter(),
        sessionIdFactory: () => 'radar-context-test',
      );
      orch.startSession(
        region: RadarClinicalRegion.hipLowerLimbProximal,
        gates: const {},
      );

      final firstQuestion = orch.nextQuestionId()!;
      final step = orch.answerQuestion(
        firstQuestion,
        isPositive: false,
        responseContext: const RadarClinicalResponseContext(
          triggers: {RadarClinicalTrigger.lumbopelvicComponent},
        ),
      );

      expect(step.trace?.clinicalTriggers, isEmpty);
      expect(step.trace?.contextActivations, isEmpty);
      expect(_remainingIds(orch), isNot(contains('v4_queue_cheval_001')));
    });

    test(
      'no trigger is activated by silent inference from a positive answer',
      () {
        final orch = RadarRegionalClinicalOrchestrator(
          engineAdapter: _NeutralAdapter(),
          sessionIdFactory: () => 'radar-context-test',
        );
        orch.startSession(region: RadarClinicalRegion.hipLowerLimbProximal);

        final step = orch.answerQuestion(
          orch.nextQuestionId()!,
          isPositive: true,
        );

        expect(step.trace?.contextGates, isEmpty);
        expect(step.trace?.clinicalTriggers, isEmpty);
        expect(step.trace?.contextActivations, isEmpty);
      },
    );

    test('V5 hard stop keeps priority over a contextual activation', () {
      final orch = RadarRegionalClinicalOrchestrator(
        sessionIdFactory: () => 'radar-context-test',
      );
      orch.startSession(region: RadarClinicalRegion.lumbar);

      final step = orch.answerCurrentQuestion(
        isPositive: true,
        responseContext: const RadarClinicalResponseContext(
          triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
        ),
      );

      expect(step.outcome, RadarSessionOutcome.hardStop);
      expect(step.engineSession.hasTriggeredHardStop, isTrue);
      expect(orch.nextQuestionId(), isNull);
    });

    test('V5 delegation keeps priority after a non hard-stop red flag', () {
      final orch = RadarRegionalClinicalOrchestrator(
        engineAdapter: _RedFlagWithoutHardStopAdapter(),
        sessionIdFactory: () => 'radar-context-test',
      );
      orch.startSession(region: RadarClinicalRegion.lumbar);

      final step = orch.answerCurrentQuestion(
        isPositive: true,
        responseContext: const RadarClinicalResponseContext(
          triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
        ),
      );

      expect(step.outcome, RadarSessionOutcome.delegateToEngine);
      expect(orch.engineHasTakenOver, isTrue);
      expect(orch.nextQuestionId(), 'v4_cardiorespiratory_001');
    });

    test('a branch requiring unavailable initial data remains closed', () {
      final orch = RadarRegionalClinicalOrchestrator(
        engineAdapter: _NeutralAdapter(),
        sessionIdFactory: () => 'radar-context-test',
      );
      orch.startSession(region: RadarClinicalRegion.diffuse);

      expect(
        _remainingIds(orch),
        isNot(contains('v4_aaa_vascular_abdominal_001')),
      );
      expect(_remainingIds(orch), isNot(contains('v4_vascular_tvp_001')));
      expect(_remainingIds(orch), isNot(contains('v4_cervical_vascular_001')));
    });

    test(
      'traumatic and cardio-respiratory families can be opened explicitly',
      () {
        final traumatic = RadarRegionalClinicalOrchestrator(
          engineAdapter: _NeutralAdapter(),
          sessionIdFactory: () => 'radar-trauma-context-test',
        );
        traumatic.startSession(
          region: RadarClinicalRegion.ankleFoot,
          initialContext: const RadarClinicalInitialContext(
            gates: {RadarContextGate.trauma},
          ),
        );

        expect(traumatic.nextQuestionId(), 'v4_fracture_ouverte_001');

        final cardio = RadarRegionalClinicalOrchestrator(
          engineAdapter: _NeutralAdapter(),
          sessionIdFactory: () => 'radar-cardio-context-test',
        );
        cardio.startSession(
          region: RadarClinicalRegion.diffuse,
          initialContext: const RadarClinicalInitialContext(
            triggers: {RadarClinicalTrigger.dyspneaOrMalaise},
          ),
        );

        final cardioIds = _remainingIds(cardio);
        expect(cardioIds, contains('v4_cardiorespiratory_001'));
        expect(cardioIds, contains('v4_embolie_pulmonaire_001'));
      },
    );
  });
}

List<String> _remainingIds(RadarRegionalClinicalOrchestrator orch) {
  final ids = <String>[];
  String? id;
  var guard = 0;
  while ((id = orch.nextQuestionId()) != null) {
    final questionId = id!;
    ids.add(questionId);
    orch.onQuestionAnswered(questionId);
    guard++;
    if (guard > 30) {
      throw StateError('Radar context test did not terminate: $ids');
    }
  }
  return ids;
}

class _NeutralAdapter extends RadarClinicalEngineAdapter {
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
      reasoningSummary: 'Neutral fake V5 state for Radar context tests.',
    );
  }

  @override
  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: {
        ...session.answeredQuestionIds,
        questionId: isPositive,
      },
      positiveFlagIds: const [],
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: null,
      reasoningSummary: 'Neutral fake V5 state for Radar context tests.',
    );
  }

  @override
  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    return ClinicalAdaptiveViewStateV5(
      sessionId: sessionId,
      questionId: null,
      patientQuestionText: null,
      canAnswer: false,
      answeredCount: session.answeredQuestionIds.length,
      totalQuestionCount: 10,
      progressRatio: session.answeredQuestionIds.length / 10,
      progressLabel: 'Fake V5',
      currentRiskLevel: ClinicalDecisionLevel.routine,
      currentRiskLabel: 'Routine',
      hardStopId: null,
      hardStopTitle: null,
      finalDecisionLevel: null,
      finalDecisionLabel: null,
      primaryHypothesisId: null,
      primaryHypothesisTitle: null,
      probabilityLevel: null,
      shortExplanation: 'Neutral fake V5 state.',
      technicalSummary: session.reasoningSummary,
      isFinal: false,
    );
  }
}

class _RedFlagWithoutHardStopAdapter extends _NeutralAdapter {
  @override
  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: {
        ...session.answeredQuestionIds,
        questionId: isPositive,
      },
      positiveFlagIds: isPositive ? const ['fake_red_flag'] : const [],
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: questionById('v4_cardiorespiratory_001'),
      reasoningSummary: 'Fake V5 red flag without hard stop.',
    );
  }

  @override
  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    final hasRedFlag = session.positiveFlagIds.isNotEmpty;
    return ClinicalAdaptiveViewStateV5(
      sessionId: sessionId,
      questionId: session.nextQuestion?.id,
      patientQuestionText: session.nextQuestion?.text,
      canAnswer: session.nextQuestion != null,
      answeredCount: session.answeredQuestionIds.length,
      totalQuestionCount: 2,
      progressRatio: session.answeredQuestionIds.length / 2,
      progressLabel: 'Fake V5',
      currentRiskLevel: hasRedFlag
          ? ClinicalDecisionLevel.medicalAdvice
          : ClinicalDecisionLevel.routine,
      currentRiskLabel: 'Fake V5',
      hardStopId: null,
      hardStopTitle: null,
      finalDecisionLevel: null,
      finalDecisionLabel: null,
      primaryHypothesisId: hasRedFlag ? 'fake' : null,
      primaryHypothesisTitle: hasRedFlag ? 'Fake' : null,
      probabilityLevel: hasRedFlag
          ? ClinicalQualitativeProbabilityV5.high
          : null,
      shortExplanation: 'Fake V5 state.',
      technicalSummary: session.reasoningSummary,
      isFinal: false,
    );
  }
}
