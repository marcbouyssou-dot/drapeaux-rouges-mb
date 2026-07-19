import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_answer.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_session_controller.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_status.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_question_view_data.dart';
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

    test(
      'answer no advances through the runtime without positive conversion',
      () {
        final controller = _controller();
        controller.startSession(region: RadarClinicalRegion.lumbar);

        final state = controller.answer(RadarClinicalAnswer.no);

        expect(state.answeredQuestionIds, contains('v4_queue_cheval_001'));
        expect(state.status, RadarClinicalStatus.question);
        expect(state.question?.id, 'v4_embolie_pulmonaire_001');
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
      expect(resumed.question?.id, 'v4_embolie_pulmonaire_001');
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
  });
}

RadarClinicalSessionController _controller() {
  return RadarClinicalSessionController(
    engine: ClinicalAdaptiveQuestionEngineV5(),
    sessionIdFactory: () => 'radar-test-session',
  );
}
