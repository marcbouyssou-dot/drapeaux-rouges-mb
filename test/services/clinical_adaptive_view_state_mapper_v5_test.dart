import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_question_engine_v5.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_view_state_mapper_v5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalAdaptiveViewStateMapperV5', () {
    late ClinicalAdaptiveQuestionEngineV5 engine;
    late ClinicalAdaptiveViewStateMapperV5 mapper;

    setUp(() {
      engine = ClinicalAdaptiveQuestionEngineV5();
      mapper = ClinicalAdaptiveViewStateMapperV5();
    });

    test('maps initial state with first question', () {
      final viewState = mapper.map(
        sessionId: 'session_initiale',
        session: engine.initialSession(),
      );

      expect(viewState.sessionId, 'session_initiale');
      expect(viewState.questionId, 'v4_queue_cheval_001');
      expect(viewState.patientQuestionText, isNotEmpty);
      expect(viewState.canAnswer, isTrue);
      expect(viewState.answeredCount, 0);
      expect(
        viewState.totalQuestionCount,
        ClinicalScreeningQuestionnaireV4.questions.length,
      );
      expect(viewState.progressRatio, 0);
      expect(
        viewState.progressLabel,
        'Question 1 sur ${ClinicalScreeningQuestionnaireV4.questions.length}',
      );
      expect(viewState.currentRiskLevel, ClinicalDecisionLevel.routine);
      expect(viewState.currentRiskLabel, 'Prise en charge habituelle');
      expect(viewState.isFinal, isFalse);
    });

    test('maps positive answer with strengthened hypothesis', () {
      final session = _manualSession(
        answeredQuestionIds: {'v4_oncologic_context_001': true},
        positiveFlagIds: ['oncologic_context'],
        probabilities: {
          'v5_hypothesis_pathologie_oncologique':
              ClinicalQualitativeProbabilityV5.high,
        },
        nextQuestion: ClinicalScreeningQuestionnaireV4.questions.first,
      );
      final viewState = mapper.map(
        sessionId: 'session_hypothese',
        session: session,
      );

      expect(
        viewState.primaryHypothesisId,
        'v5_hypothesis_pathologie_oncologique',
      );
      expect(
        viewState.primaryHypothesisTitle,
        'Pathologie oncologique sous-jacente',
      );
      expect(viewState.probabilityLevel, ClinicalQualitativeProbabilityV5.high);
      expect(viewState.currentRiskLevel, ClinicalDecisionLevel.urgentReferral);
      expect(viewState.currentRiskLabel, 'Avis médical rapide nécessaire');
      expect(viewState.canAnswer, isTrue);
      expect(viewState.isFinal, isFalse);
    });

    test('maps triggered hard stop as final non answerable state', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );
      final viewState = mapper.map(
        sessionId: 'session_hard_stop',
        session: session,
      );

      expect(viewState.hardStopId, 'v5_hard_stop_queue_cheval');
      expect(
        viewState.hardStopTitle,
        'Suspicion de syndrome de la queue de cheval',
      );
      expect(viewState.currentRiskLevel, ClinicalDecisionLevel.emergency);
      expect(viewState.finalDecisionLevel, ClinicalDecisionLevel.emergency);
      expect(viewState.finalDecisionLabel, 'Urgence immédiate');
      expect(viewState.progressLabel, 'Questionnaire interrompu');
      expect(viewState.canAnswer, isFalse);
      expect(viewState.isFinal, isTrue);
    });

    test('maps completion without next question as final state', () {
      final session = _answerAllQuestionsNegatively(engine);
      final viewState = mapper.map(
        sessionId: 'session_complete',
        session: session,
      );

      expect(viewState.questionId, isNull);
      expect(viewState.patientQuestionText, isNull);
      expect(viewState.canAnswer, isFalse);
      expect(viewState.isFinal, isTrue);
      expect(viewState.finalDecisionLevel, ClinicalDecisionLevel.routine);
      expect(viewState.finalDecisionLabel, 'Prise en charge habituelle');
      expect(viewState.progressLabel, 'Questionnaire terminé');
      expect(viewState.progressRatio, 1);
      expect(
        viewState.shortExplanation,
        'Aucun signal d’alerte prioritaire n’a été retrouvé dans ce questionnaire. La décision finale reste sous la responsabilité du professionnel.',
      );
    });

    test('bounds progress ratio between 0 and 1', () {
      final session = _manualSession(
        answeredQuestionIds: {
          for (var index = 0; index < 20; index++) 'q$index': false,
        },
        nextQuestion: null,
      );
      final viewState = mapper.map(
        sessionId: 'session_progression',
        session: session,
      );

      expect(viewState.answeredCount, 20);
      expect(
        viewState.totalQuestionCount,
        ClinicalScreeningQuestionnaireV4.questions.length,
      );
      expect(viewState.progressRatio, 1);
    });

    test('does not display clinical percentages', () {
      final viewState = mapper.map(
        sessionId: 'session_sans_pourcentage',
        session: engine.initialSession(),
      );
      final visibleText = [
        viewState.progressLabel,
        viewState.currentRiskLabel,
        viewState.finalDecisionLabel,
        viewState.primaryHypothesisTitle,
        viewState.shortExplanation,
      ].whereType<String>().join('\n');

      expect(visibleText, isNot(contains('%')));
      expect(visibleText.toLowerCase(), isNot(contains('pourcent')));
    });

    test('short explanation is brief and non diagnostic', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );
      final viewState = mapper.map(
        sessionId: 'session_explication',
        session: session,
      );

      expect(viewState.shortExplanation.length, lessThanOrEqualTo(180));
      expect(
        viewState.shortExplanation.toLowerCase(),
        isNot(contains('diagnostic')),
      );
      expect(
        viewState.shortExplanation.toLowerCase(),
        isNot(contains('vous avez')),
      );
    });

    test('risk labels are correct', () {
      final initial = mapper.map(
        sessionId: 'session_routine',
        session: engine.initialSession(),
      );
      final urgent = mapper.map(
        sessionId: 'session_urgent',
        session: _manualSession(
          probabilities: {
            'v5_hypothesis_pathologie_oncologique':
                ClinicalQualitativeProbabilityV5.high,
          },
          nextQuestion: null,
        ),
      );
      final emergency = mapper.map(
        sessionId: 'session_urgence',
        session: engine.answerQuestion(
          session: engine.initialSession(),
          questionId: 'v4_queue_cheval_001',
          isPositive: true,
        ),
      );

      expect(initial.currentRiskLabel, 'Prise en charge habituelle');
      expect(urgent.currentRiskLabel, 'Avis médical rapide nécessaire');
      expect(emergency.currentRiskLabel, 'Urgence immédiate');
    });
  });
}

ClinicalAdaptiveSessionV5 _answerAllQuestionsNegatively(
  ClinicalAdaptiveQuestionEngineV5 engine,
) {
  var session = engine.initialSession();

  while (session.nextQuestion != null) {
    session = engine.answerQuestion(
      session: session,
      questionId: session.nextQuestion!.id,
      isPositive: false,
    );
  }

  return session;
}

ClinicalAdaptiveSessionV5 _manualSession({
  Map<String, bool> answeredQuestionIds = const {},
  List<String> positiveFlagIds = const [],
  Map<String, ClinicalQualitativeProbabilityV5> probabilities = const {},
  List<String> appliedProbabilityUpdateIds = const [],
  List<String> triggeredHardStopIds = const [],
  dynamic nextQuestion,
}) {
  return ClinicalAdaptiveSessionV5(
    answeredQuestionIds: answeredQuestionIds,
    positiveFlagIds: positiveFlagIds,
    reassuringFlagIds: const [],
    hypothesisProbabilities: {
      for (final hypothesisId in _allHypothesisIds)
        hypothesisId: ClinicalQualitativeProbabilityV5.low,
      ...probabilities,
    },
    appliedProbabilityUpdateIds: appliedProbabilityUpdateIds,
    triggeredHardStopIds: triggeredHardStopIds,
    nextQuestion: nextQuestion,
    reasoningSummary: 'Résumé technique de test.',
  );
}

const _allHypothesisIds = [
  'v5_hypothesis_queue_cheval',
  'v5_hypothesis_embolie_pulmonaire',
  'v5_hypothesis_fracture_ouverte',
  'v5_hypothesis_pathologie_oncologique',
  'v5_hypothesis_infection_systemique_fragile',
  'v5_hypothesis_atteinte_neurologique_progressive',
  'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
  'v5_hypothesis_fracture_fragilite',
  'v5_hypothesis_tvp',
];
