import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/services/clinical_adaptive_question_engine_v5.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalAdaptiveQuestionEngineV5', () {
    late ClinicalAdaptiveQuestionEngineV5 engine;

    setUp(() {
      engine = ClinicalAdaptiveQuestionEngineV5();
    });

    test('creates an initial adaptive session', () {
      final session = engine.initialSession();

      expect(session.answeredQuestionIds, isEmpty);
      expect(session.positiveFlagIds, isEmpty);
      expect(session.appliedProbabilityUpdateIds, isEmpty);
      expect(session.triggeredHardStopIds, isEmpty);
      expect(
        session.hypothesisProbabilities.keys,
        containsAll(ClinicalHypothesisCatalogV5.hypothesisIds),
      );
      expect(session.nextQuestion?.id, 'v4_queue_cheval_001');
    });

    test('session collections are non modifiable', () {
      final session = engine.initialSession();

      expect(
        () => session.answeredQuestionIds['x'] = true,
        throwsUnsupportedError,
      );
      expect(() => session.positiveFlagIds.add('x'), throwsUnsupportedError);
      expect(() => session.reassuringFlagIds.add('x'), throwsUnsupportedError);
      expect(
        () => session.hypothesisProbabilities['x'] =
            ClinicalQualitativeProbabilityV5.high,
        throwsUnsupportedError,
      );
      expect(
        () => session.appliedProbabilityUpdateIds.add('x'),
        throwsUnsupportedError,
      );
      expect(
        () => session.triggeredHardStopIds.add('x'),
        throwsUnsupportedError,
      );
    });

    test('negative answer is stored without positive flag or hard stop', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: false,
      );

      expect(session.answeredQuestionIds['v4_queue_cheval_001'], isFalse);
      expect(session.positiveFlagIds, isEmpty);
      expect(session.appliedProbabilityUpdateIds, isEmpty);
      expect(session.triggeredHardStopIds, isEmpty);
      expect(session.nextQuestion?.id, 'v4_embolie_pulmonaire_001');
    });

    test('positive cauda equina answer updates hypothesis and hard stop', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, contains('queue_cheval_suspected'));
      expect(
        session.appliedProbabilityUpdateIds,
        contains('v5_probability_update_queue_cheval_question'),
      );
      expect(
        session.hypothesisProbabilities['v5_hypothesis_queue_cheval'],
        ClinicalQualitativeProbabilityV5.veryHigh,
      );
      expect(
        session.triggeredHardStopIds,
        contains('v5_hard_stop_queue_cheval'),
      );
      expect(session.hasTriggeredHardStop, isTrue);
      expect(session.nextQuestion, isNull);
    });

    test('positive cardiorespiratory answer reaches very high probability', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_cardiorespiratory_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, contains('chest_pain'));
      expect(
        session
            .hypothesisProbabilities['v5_hypothesis_syndrome_cardiorespiratoire_aigu'],
        ClinicalQualitativeProbabilityV5.veryHigh,
      );
      expect(
        session.triggeredHardStopIds,
        contains('v5_hard_stop_cardiorespiratoire'),
      );
      expect(session.nextQuestion, isNull);
    });

    test('positive oncologic answer updates hypothesis qualitatively', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_oncologic_context_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, contains('oncologic_context'));
      expect(
        session.hypothesisProbabilities['v5_hypothesis_pathologie_oncologique'],
        ClinicalQualitativeProbabilityV5.high,
      );
      expect(
        session.triggeredHardStopIds,
        contains('v5_hard_stop_oncologique'),
      );
    });

    test('cervical vascular suspect produces suspected hard stop', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_cervical_vascular_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, contains('cervical_vascular_context'));
      expect(
        session.hypothesisProbabilities['v5_hypothesis_cervical_vasculaire'],
        ClinicalQualitativeProbabilityV5.high,
      );
      expect(
        session.triggeredHardStopIds,
        contains('v5_hard_stop_cervical_vasculaire'),
      );
      expect(session.hardStopState, ClinicalHardStopStateV5.suspected);
      expect(session.canReassure, isFalse);
      expect(session.nextQuestion, isNull);
    });

    test('AAA vascular abdominal suspect produces suspected hard stop', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_aaa_vascular_abdominal_001',
        isPositive: true,
      );

      expect(
        session.positiveFlagIds,
        contains('aaa_vascular_abdominal_context'),
      );
      expect(
        session
            .hypothesisProbabilities['v5_hypothesis_aaa_vasculaire_abdominal'],
        ClinicalQualitativeProbabilityV5.high,
      );
      expect(
        session.triggeredHardStopIds,
        contains('v5_hard_stop_aaa_vasculaire_abdominal'),
      );
      expect(session.hardStopState, ClinicalHardStopStateV5.suspected);
      expect(session.canReassure, isFalse);
      expect(session.nextQuestion, isNull);
    });

    test('confirmed hard stop blocks reassurance and confirms urgency', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );

      expect(session.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(session.canReassure, isFalse);
      expect(session.hasTriggeredHardStop, isTrue);
    });

    test('mechanical reassurance remains possible without hard stop', () {
      var session = engine.initialSession();

      while (session.nextQuestion != null) {
        session = engine.answerQuestion(
          session: session,
          questionId: session.nextQuestion!.id,
          isPositive: false,
        );
      }

      expect(session.hardStopState, ClinicalHardStopStateV5.absent);
      expect(session.canReassure, isTrue);
      expect(session.nextQuestion, isNull);
    });

    test('mechanical reassurance flags are tracked separately', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_mechanical_pattern_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, isEmpty);
      expect(session.reassuringFlagIds, contains('mechanical_pain_pattern'));
      expect(session.triggeredHardStopIds, isEmpty);
      expect(session.canReassure, isTrue);
      expect(session.reasoningSummary, contains('Arguments rassurants'));
    });

    test('psychosocial flags do not create hard stops or urgent decisions', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_psychosocial_anxiety_001',
        isPositive: true,
      );

      expect(session.positiveFlagIds, isEmpty);
      expect(session.reassuringFlagIds, contains('psychosocial_anxiety'));
      expect(session.triggeredHardStopIds, isEmpty);
      expect(session.hardStopState, ClinicalHardStopStateV5.absent);
      expect(session.canReassure, isTrue);
    });

    test(
      'isolated critical sign is not neutralized by reassurance context',
      () {
        final mechanicalSession = engine.answerQuestion(
          session: engine.initialSession(),
          questionId: 'v4_mechanical_pattern_001',
          isPositive: true,
        );
        final session = engine.answerQuestion(
          session: mechanicalSession,
          questionId: 'v4_queue_cheval_001',
          isPositive: true,
        );

        expect(session.reassuringFlagIds, contains('mechanical_pain_pattern'));
        expect(session.positiveFlagIds, contains('queue_cheval_suspected'));
        expect(session.hardStopState, ClinicalHardStopStateV5.confirmed);
        expect(session.canReassure, isFalse);
        expect(session.nextQuestion, isNull);
      },
    );

    test('hard stop remains blocking after psychosocial context', () {
      final psychosocialSession = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_psychosocial_catastrophizing_001',
        isPositive: true,
      );
      final session = engine.answerQuestion(
        session: psychosocialSession,
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );

      expect(
        session.reassuringFlagIds,
        contains('psychosocial_catastrophizing'),
      );
      expect(session.positiveFlagIds, contains('queue_cheval_suspected'));
      expect(session.hardStopState, ClinicalHardStopStateV5.confirmed);
      expect(session.canReassure, isFalse);
      expect(session.nextQuestion, isNull);
    });

    test('next question prioritizes remaining immediate danger questions', () {
      final afterCaudaNegative = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: false,
      );
      final afterPulmonaryNegative = engine.answerQuestion(
        session: afterCaudaNegative,
        questionId: 'v4_embolie_pulmonaire_001',
        isPositive: false,
      );

      expect(
        afterPulmonaryNegative.nextQuestion?.id,
        'v4_fracture_ouverte_001',
      );
    });

    test(
      'cardiorespiratory question remains prioritized before non emergencies',
      () {
        final afterCaudaNegative = engine.answerQuestion(
          session: engine.initialSession(),
          questionId: 'v4_queue_cheval_001',
          isPositive: false,
        );
        final afterPulmonaryNegative = engine.answerQuestion(
          session: afterCaudaNegative,
          questionId: 'v4_embolie_pulmonaire_001',
          isPositive: false,
        );
        final afterFractureNegative = engine.answerQuestion(
          session: afterPulmonaryNegative,
          questionId: 'v4_fracture_ouverte_001',
          isPositive: false,
        );

        expect(
          afterFractureNegative.nextQuestion?.id,
          'v4_cardiorespiratory_001',
        );
      },
    );

    test('repeated positive answer does not duplicate clinical ids', () {
      final first = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );
      final second = engine.answerQuestion(
        session: first,
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );

      expect(
        second.positiveFlagIds.where((id) => id == 'queue_cheval_suspected'),
        hasLength(1),
      );
      expect(
        second.appliedProbabilityUpdateIds.where(
          (id) => id == 'v5_probability_update_queue_cheval_question',
        ),
        hasLength(1),
      );
      expect(
        second.triggeredHardStopIds.where(
          (id) => id == 'v5_hard_stop_queue_cheval',
        ),
        hasLength(1),
      );
    });

    test('reasoning summary exposes answered state and next question', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: false,
      );

      expect(session.reasoningSummary, contains('Questions répondues : 1'));
      expect(
        session.reasoningSummary,
        contains('Prochaine question : v4_embolie_pulmonaire_001'),
      );
    });

    test('reasoning summary exposes hard stops and raised hypotheses', () {
      final session = engine.answerQuestion(
        session: engine.initialSession(),
        questionId: 'v4_queue_cheval_001',
        isPositive: true,
      );

      expect(session.reasoningSummary, contains('Hard Stops déclenchés'));
      expect(session.reasoningSummary, contains('v5_hypothesis_queue_cheval'));
      expect(session.reasoningSummary, contains('Prochaine question : aucune'));
    });

    test('unknown question id throws an argument error', () {
      expect(
        () => engine.answerQuestion(
          session: engine.initialSession(),
          questionId: 'unknown_question',
          isPositive: true,
        ),
        throwsArgumentError,
      );
    });
  });
}
