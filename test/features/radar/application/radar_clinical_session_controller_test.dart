import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_answer.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_engine_adapter.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_session_controller.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_status.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_question_view_data.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_regional_clinical_orchestrator.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_question_engine_v5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadarClinicalSessionController', () {
    test('starts lumbar session with the first real runtime question', () {
      final controller = _controller();

      final state = controller.startSession(region: RadarClinicalRegion.lumbar);

      expect(state.sessionId, 'radar-test-session');
      expect(state.region, RadarClinicalRegion.lumbar);
      expect(state.status, RadarClinicalStatus.question);
      expect(state.question?.id, 'v4_queue_cheval_001');
      expect(state.question?.text, isNotEmpty);
      expect(state.question?.answerType, RadarQuestionAnswerType.yesNo);
      expect(state.question?.availableAnswers, [
        RadarClinicalAnswer.yes,
        RadarClinicalAnswer.no,
      ]);
      expect(state.answeredQuestionIds, isEmpty);
    });

    test('selects the next question from the regional orchestrator', () {
      final directV5InitialQuestionId = ClinicalAdaptiveQuestionEngineV5()
          .initialSession()
          .nextQuestion
          ?.id;
      final controller = _controller();

      final state = controller.startSession(
        region: RadarClinicalRegion.cervical,
      );

      expect(directV5InitialQuestionId, 'v4_queue_cheval_001');
      expect(state.question?.id, 'v4_cervical_vascular_001');
    });

    test(
      'answer no advances through the runtime without positive conversion',
      () {
        final controller = _controller();
        controller.startSession(region: RadarClinicalRegion.lumbar);

        final state = controller.answer(RadarClinicalAnswer.no);

        expect(state.answeredQuestionIds, contains('v4_queue_cheval_001'));
        expect(state.status, RadarClinicalStatus.question);
        expect(state.question?.id, 'v4_oncologic_context_001');
        expect(state.decision, isNull);
      },
    );

    test('answer yes preserves hard stop state returned by the runtime', () {
      final controller = _controller();
      controller.startSession(region: RadarClinicalRegion.lumbar);

      final state = controller.answer(RadarClinicalAnswer.yes);

      expect(state.status, RadarClinicalStatus.hardStop);
      expect(state.question, isNull);
      expect(state.decision?.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(
        state.decision?.hardStopIds,
        contains('v5_hard_stop_queue_cheval'),
      );
      expect(state.answeredQuestionIds, contains('v4_queue_cheval_001'));
    });

    test('unsupported unknown keeps runtime session unchanged', () {
      final controller = _controller();
      final initial = controller.startSession(
        region: RadarClinicalRegion.lumbar,
      );

      final unsupported = controller.answer(RadarClinicalAnswer.unknown);
      final resumed = controller.answer(RadarClinicalAnswer.no);

      expect(unsupported.status, RadarClinicalStatus.unsupportedAnswer);
      expect(unsupported.unsupportedAnswer, RadarClinicalAnswer.unknown);
      expect(unsupported.question?.id, initial.question?.id);
      expect(unsupported.answeredQuestionIds, initial.answeredQuestionIds);
      expect(resumed.status, RadarClinicalStatus.question);
      expect(resumed.answeredQuestionIds, contains('v4_queue_cheval_001'));
      expect(resumed.question?.id, 'v4_oncologic_context_001');
    });

    test('unsupported bilateral keeps runtime session unchanged', () {
      final controller = _controller();
      final initial = controller.startSession(
        region: RadarClinicalRegion.lumbar,
      );

      final unsupported = controller.answer(RadarClinicalAnswer.bilateral);
      final resumed = controller.answer(RadarClinicalAnswer.yes);

      expect(unsupported.status, RadarClinicalStatus.unsupportedAnswer);
      expect(unsupported.unsupportedAnswer, RadarClinicalAnswer.bilateral);
      expect(unsupported.question?.id, initial.question?.id);
      expect(unsupported.answeredQuestionIds, initial.answeredQuestionIds);
      expect(resumed.status, RadarClinicalStatus.hardStop);
      expect(
        resumed.decision?.hardStopIds,
        contains('v5_hard_stop_queue_cheval'),
      );
    });

    test(
      'CAS_01 reaches routine decision after all real runtime no answers',
      () {
        final controller = _controller();
        var state = controller.startSession(region: RadarClinicalRegion.lumbar);

        while (state.status == RadarClinicalStatus.question) {
          state = controller.answer(RadarClinicalAnswer.no);
        }

        expect(state.status, RadarClinicalStatus.decision);
        expect(state.question, isNull);
        expect(state.decision?.decisionLevel, ClinicalDecisionLevel.routine);
        expect(state.decision?.hardStopIds, isEmpty);
        expect(state.decision?.title, 'Prise en charge possible');
        expect(
          state.decision?.summary,
          'Aucun drapeau rouge identifié parmi les éléments évalués.',
        );
        expect(state.answeredQuestionIds, isNotEmpty);
      },
    );

    test('exposes hard stop without recreating clinical rule in Radar', () {
      final controller = _controller();
      var state = controller.startSession(region: RadarClinicalRegion.lumbar);

      state = controller.answer(RadarClinicalAnswer.yes);

      expect(state.status, RadarClinicalStatus.hardStop);
      expect(state.decision?.hardStopIds, isNotEmpty);
      expect(state.decision?.summary, isNot(contains('diagnostic')));
    });

    test(
      'presentation state hides score, percentage, probability and cluster names',
      () {
        final controller = _controller();
        final state = controller.startSession(
          region: RadarClinicalRegion.lumbar,
        );
        final question = state.question;

        expect(question, isNotNull);
        expect(
          question,
          isNot(
            isA<dynamic>().having((value) => value.score, 'score', anything),
          ),
        );
        expect(
          question,
          isNot(
            isA<dynamic>().having(
              (value) => value.progressRatio,
              'progressRatio',
              anything,
            ),
          ),
        );
        expect(
          question,
          isNot(
            isA<dynamic>().having(
              (value) => value.probabilityLevel,
              'probabilityLevel',
              anything,
            ),
          ),
        );
        expect(
          question,
          isNot(
            isA<dynamic>().having(
              (value) => value.clusterId,
              'clusterId',
              anything,
            ),
          ),
        );
      },
    );

    test('summary projection contains real region, outcome and answers', () {
      final controller = _controller();
      var state = controller.startSession(region: RadarClinicalRegion.lumbar);

      while (state.status == RadarClinicalStatus.question) {
        state = controller.answer(RadarClinicalAnswer.no);
      }

      final summary = state.summary;
      expect(summary, isNotNull);
      expect(summary!.sessionId, 'radar-test-session');
      expect(summary.region, RadarClinicalRegion.lumbar);
      expect(summary.status, RadarClinicalStatus.decision);
      expect(summary.regionalOutcome?.name, 'monitor');
      expect(summary.questions, isNotEmpty);
      expect(
        summary.questions.every((question) => !question.isPositive),
        isTrue,
      );
      expect(summary.negativeAnswers.length, summary.questions.length);
      expect(summary.endReason, contains('Complétude régionale'));
    });

    test(
      'summary projection contains gates, triggers and experimental status',
      () {
        final controller = _controller();
        var state = controller.startSession(
          region: RadarClinicalRegion.lumbar,
          initialContext: const RadarClinicalInitialContext(
            triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
          ),
        );

        while (state.status == RadarClinicalStatus.question) {
          state = controller.answer(RadarClinicalAnswer.no);
        }

        final summary = state.summary!;
        expect(
          summary.clinicalTriggers,
          contains(RadarClinicalTrigger.cardiovascularRiskFactors),
        );
        expect(
          summary.contextActivations.single.id,
          'trigger.cardiovascularRiskFactors',
        );
        expect(summary.contextActivations.single.sourceQuestionId, isNull);
        expect(summary.matrixVersion, kRadarPathwayMatrixVersion);
        expect(summary.validationStatus, kRadarPathwayClinicalValidationStatus);
        expect(summary.operatingMode, RadarClinicalOperatingMode.experimental);
        expect(summary.engineVersion, 'ClinicalAdaptiveQuestionEngineV5');
      },
    );

    test(
      'summary projection includes dynamic positive answers only when present',
      () {
        final controller = _controller();
        var state = controller.startSession(region: RadarClinicalRegion.lumbar);

        while (state.status == RadarClinicalStatus.question) {
          final answer = state.question?.id == 'v4_mechanical_pattern_001'
              ? RadarClinicalAnswer.yes
              : RadarClinicalAnswer.no;
          state = controller.answer(answer);
        }

        final summary = state.summary!;
        expect(summary.positiveAnswers, hasLength(1));
        expect(
          summary.positiveAnswers.single.questionId,
          'v4_mechanical_pattern_001',
        );
        expect(summary.positiveAnswers.single.text, contains('mouvement'));
        expect(summary.regionalOutcome?.name, 'reassure');
      },
    );

    test('summary projection does not inject static exclusion wording', () {
      final controller = _controller();
      var state = controller.startSession(region: RadarClinicalRegion.cervical);

      while (state.status == RadarClinicalStatus.question) {
        state = controller.answer(RadarClinicalAnswer.no);
      }

      final summary = state.summary!;
      final renderedProjection = [
        summary.endReason,
        ...summary.questions.map((question) => question.text),
        ...summary.positiveFlagIds,
        ...summary.reassuringFlagIds,
      ].join('\n');

      expect(renderedProjection, isNot(contains('pathologie exclue')));
      expect(renderedProjection, isNot(contains('diagnostic certain')));
      expect(renderedProjection, isNot(contains('absence de risque')));
    });

    test('hard stop projection is terminal and preserves real V5 data', () {
      final controller = _controller();
      controller.startSession(region: RadarClinicalRegion.lumbar);

      final state = controller.answer(RadarClinicalAnswer.yes);
      final hardStop = state.hardStop;

      expect(state.status, RadarClinicalStatus.hardStop);
      expect(state.question, isNull);
      expect(hardStop, isNotNull);
      expect(hardStop!.region, RadarClinicalRegion.lumbar);
      expect(hardStop.hardStopId, 'v5_hard_stop_queue_cheval');
      expect(
        hardStop.hardStopTitle,
        'Suspicion de syndrome de la queue de cheval',
      );
      expect(hardStop.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(hardStop.triggeringQuestionId, 'v4_queue_cheval_001');
      expect(hardStop.contributingQuestionIds, ['v4_queue_cheval_001']);
      expect(hardStop.criticalArguments, isNotEmpty);
      expect(hardStop.stopReason, contains('moteur V5'));
      expect(hardStop.regionalOutcome?.name, 'hardStop');
      expect(hardStop.engineVersion, 'ClinicalAdaptiveQuestionEngineV5');
      expect(hardStop.matrixVersion, kRadarPathwayMatrixVersion);
      expect(hardStop.validationStatus, kRadarPathwayClinicalValidationStatus);
    });

    test(
      'hard stop projection preserves suspected state when V5 reports it',
      () {
        final controller = _controller();
        var state = controller.startSession(
          region: RadarClinicalRegion.lumbar,
          initialContext: const RadarClinicalInitialContext(
            triggers: {RadarClinicalTrigger.cardiovascularRiskFactors},
          ),
        );

        while (state.status == RadarClinicalStatus.question) {
          final answer = state.question?.id == 'v4_aaa_vascular_abdominal_001'
              ? RadarClinicalAnswer.yes
              : RadarClinicalAnswer.no;
          state = controller.answer(answer);
        }

        expect(state.status, RadarClinicalStatus.hardStop);
        expect(state.question, isNull);
        expect(
          state.hardStop?.hardStopId,
          'v5_hard_stop_aaa_vasculaire_abdominal',
        );
        expect(
          state.hardStop?.hardStopState,
          ClinicalHardStopStateV5.suspected,
        );
        expect(
          state.hardStop?.triggeringQuestionId,
          'v4_aaa_vascular_abdominal_001',
        );
      },
    );

    test('hard stop remains prioritized over regional completion', () {
      final controller = _controller();
      controller.startSession(region: RadarClinicalRegion.lumbar);

      final state = controller.answer(RadarClinicalAnswer.yes);

      expect(state.status, RadarClinicalStatus.hardStop);
      expect(state.summary?.regionalOutcome?.name, 'hardStop');
      expect(state.question, isNull);
      expect(state.answeredQuestionIds, ['v4_queue_cheval_001']);
    });

    test('non hard-stop delegation is not converted into hard stop', () {
      final controller = RadarClinicalSessionController(
        orchestrator: RadarRegionalClinicalOrchestrator(
          engineAdapter: _RedFlagWithoutHardStopAdapter(),
          sessionIdFactory: () => 'radar-delegate-test',
        ),
      );

      controller.startSession(region: RadarClinicalRegion.lumbar);
      final state = controller.answer(RadarClinicalAnswer.yes);

      expect(state.status, RadarClinicalStatus.question);
      expect(state.hardStop, isNull);
      expect(state.decision, isNull);
      expect(state.question?.id, 'v4_cardiorespiratory_001');
    });

    test(
      'hard stop projection does not add static clinical recommendations',
      () {
        final controller = _controller();
        controller.startSession(region: RadarClinicalRegion.lumbar);

        final state = controller.answer(RadarClinicalAnswer.yes);
        final hardStop = state.hardStop!;
        final renderedProjection = [
          hardStop.hardStopTitle,
          hardStop.stopReason,
          ...hardStop.criticalArguments,
        ].join('\n');

        expect(
          renderedProjection,
          isNot(contains('Appelez immédiatement le 15')),
        );
        expect(renderedProjection, isNot(contains('Urgence vitale')));
        expect(renderedProjection, isNot(contains('Diagnostic confirmé')));
        expect(renderedProjection, isNot(contains('Le patient présente')));
        expect(
          renderedProjection,
          isNot(contains('Cette pathologie est certaine')),
        );
        expect(renderedProjection, isNot(contains('Aucun autre risque')));
      },
    );

    test('hard stop metadata is read through the Radar adapter', () {
      final adapter = _HardStopMetadataTrackingAdapter();
      final controller = RadarClinicalSessionController(
        orchestrator: RadarRegionalClinicalOrchestrator(
          engineAdapter: adapter,
          sessionIdFactory: () => 'radar-metadata-adapter-test',
        ),
      );
      controller.startSession(region: RadarClinicalRegion.lumbar);

      final state = controller.answer(RadarClinicalAnswer.yes);
      final hardStop = state.hardStop!;

      expect(adapter.requestedHardStopIds, ['v5_hard_stop_queue_cheval']);
      expect(hardStop.hardStopId, 'v5_hard_stop_queue_cheval');
      expect(hardStop.hardStopTitle, 'Titre fourni par adapter Radar');
      expect(hardStop.clinicalFamilyId, 'adapter-family');
      expect(hardStop.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(hardStop.triggeringQuestionId, 'v4_queue_cheval_001');
      expect(hardStop.contributingQuestionIds, ['v4_queue_cheval_001']);
      expect(
        hardStop.criticalArguments,
        contains('Description fournie par adapter Radar.'),
      );
    });

    test('controller does not import ClinicalHardStopCatalogV5 directly', () {
      final source = File(
        'lib/features/radar/application/'
        'radar_clinical_session_controller.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('clinical_hard_stop_catalog_v5.dart')));
      expect(source, isNot(contains('ClinicalHardStopCatalogV5')));
    });
  });
}

RadarClinicalSessionController _controller() {
  return RadarClinicalSessionController(
    engine: ClinicalAdaptiveQuestionEngineV5(),
    sessionIdFactory: () => 'radar-test-session',
  );
}

class _HardStopMetadataTrackingAdapter extends RadarClinicalEngineAdapter {
  final List<String> requestedHardStopIds = [];

  @override
  RadarHardStopMetadata? hardStopMetadataById(String hardStopId) {
    requestedHardStopIds.add(hardStopId);
    return RadarHardStopMetadata(
      id: hardStopId,
      title: 'Titre fourni par adapter Radar',
      clinicalFamilyId: 'adapter-family',
      triggeringQuestionIds: const ['v4_queue_cheval_001'],
      clinicalDescription: 'Description fournie par adapter Radar.',
    );
  }
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
