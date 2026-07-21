import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_answer.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_status.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_question_view_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadarClinicalViewState', () {
    test('derives navigation destination from clinical status', () {
      expect(
        _stateWithStatus(RadarClinicalStatus.question).destination,
        RadarClinicalDestination.question,
      );
      expect(
        _stateWithStatus(RadarClinicalStatus.decision).destination,
        RadarClinicalDestination.summary,
      );
      expect(
        _stateWithStatus(RadarClinicalStatus.hardStop).destination,
        RadarClinicalDestination.hardStop,
      );
      expect(
        _stateWithStatus(RadarClinicalStatus.unsupportedAnswer).destination,
        RadarClinicalDestination.unsupportedAnswer,
      );
    });

    test('stores answered question ids as an immutable set', () {
      final state = RadarClinicalViewState(
        sessionId: 'session-test',
        region: RadarClinicalRegion.lumbar,
        status: RadarClinicalStatus.question,
        question: RadarQuestionViewData(
          id: 'question-1',
          text: 'Question clinique',
          answerType: RadarQuestionAnswerType.yesNo,
          availableAnswers: [RadarClinicalAnswer.yes, RadarClinicalAnswer.no],
        ),
        decision: null,
        answeredQuestionIds: {'question-0'},
      );

      expect(state.answeredQuestionIds, {'question-0'});
      expect(
        () => state.answeredQuestionIds.add('question-1'),
        throwsA(anything),
      );
    });

    test('keeps unsupported answer without exposing technical UI fields', () {
      final state = RadarClinicalViewState(
        sessionId: 'session-test',
        region: RadarClinicalRegion.lumbar,
        status: RadarClinicalStatus.unsupportedAnswer,
        question: null,
        decision: null,
        answeredQuestionIds: {},
        unsupportedAnswer: RadarClinicalAnswer.unknown,
      );

      expect(state.unsupportedAnswer, RadarClinicalAnswer.unknown);
      expect(
        state,
        isNot(isA<dynamic>().having((value) => value.score, 'score', anything)),
      );
      expect(
        state,
        isNot(
          isA<dynamic>().having(
            (value) => value.progressRatio,
            'progressRatio',
            anything,
          ),
        ),
      );
      expect(
        state,
        isNot(
          isA<dynamic>().having(
            (value) => value.probabilityLevel,
            'probabilityLevel',
            anything,
          ),
        ),
      );
      expect(
        state,
        isNot(
          isA<dynamic>().having(
            (value) => value.clusterId,
            'clusterId',
            anything,
          ),
        ),
      );
    });
  });
}

RadarClinicalViewState _stateWithStatus(RadarClinicalStatus status) {
  return RadarClinicalViewState(
    sessionId: 'session-test',
    region: RadarClinicalRegion.lumbar,
    status: status,
    question: null,
    decision: null,
    answeredQuestionIds: const {},
  );
}
