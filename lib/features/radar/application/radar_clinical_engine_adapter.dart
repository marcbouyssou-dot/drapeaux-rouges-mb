import '../../../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../../../models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import '../../../models/clinical_screening/clinical_screening_question_v4.dart';
import '../../../models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import '../../../services/clinical_adaptive_question_engine_v5.dart';
import '../../../services/clinical_adaptive_view_state_mapper_v5.dart';

const String kRadarClinicalEngineVersion = 'ClinicalAdaptiveQuestionEngineV5';

class RadarClinicalEngineAdapter {
  RadarClinicalEngineAdapter({
    ClinicalAdaptiveQuestionEngineV5? engine,
    ClinicalAdaptiveViewStateMapperV5? mapper,
  }) : _engine = engine ?? ClinicalAdaptiveQuestionEngineV5(),
       _mapper = mapper ?? ClinicalAdaptiveViewStateMapperV5();

  final ClinicalAdaptiveQuestionEngineV5 _engine;
  final ClinicalAdaptiveViewStateMapperV5 _mapper;

  ClinicalAdaptiveSessionV5 initialSession() => _engine.initialSession();

  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    return _engine.answerQuestion(
      session: session,
      questionId: questionId,
      isPositive: isPositive,
    );
  }

  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    return _mapper.map(sessionId: sessionId, session: session);
  }

  ClinicalScreeningQuestionV4 questionById(String questionId) {
    for (final question in ClinicalScreeningQuestionnaireV4.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    throw ArgumentError.value(questionId, 'questionId', 'Unknown V4 question');
  }

  Set<String> get catalogQuestionIds =>
      ClinicalScreeningQuestionnaireV4.questionIds;
}
