import '../../../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../../../models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import '../../../models/clinical_screening/clinical_screening_models.dart';
import '../../../models/clinical_screening/clinical_screening_question_v4.dart';
import '../../../services/clinical_adaptive_question_engine_v5.dart';
import '../../../services/clinical_adaptive_view_state_mapper_v5.dart';
import 'radar_clinical_answer.dart';
import 'radar_clinical_engine_adapter.dart';
import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_status.dart';
import 'radar_clinical_stop_policy.dart';
import 'radar_clinical_view_state.dart';
import 'radar_decision_view_data.dart';
import 'radar_question_view_data.dart';
import 'radar_regional_clinical_orchestrator.dart';

class RadarClinicalSessionController {
  RadarClinicalSessionController({
    ClinicalAdaptiveQuestionEngineV5? engine,
    ClinicalAdaptiveViewStateMapperV5? mapper,
    RadarRegionalClinicalOrchestrator? orchestrator,
    String Function()? sessionIdFactory,
  }) : _orchestrator =
           orchestrator ??
           RadarRegionalClinicalOrchestrator(
             engineAdapter: RadarClinicalEngineAdapter(
               engine: engine,
               mapper: mapper,
             ),
             sessionIdFactory: sessionIdFactory,
           );

  final RadarRegionalClinicalOrchestrator _orchestrator;

  RadarClinicalRegion? _region;
  String? _sessionId;
  RadarClinicalViewState? _state;

  RadarClinicalViewState get state {
    final current = _state;
    if (current == null) {
      throw StateError('No Radar clinical session has been started.');
    }
    return current;
  }

  RadarClinicalViewState startSession({
    required RadarClinicalRegion region,
    RadarClinicalInitialContext initialContext =
        const RadarClinicalInitialContext(),
  }) {
    _region = region;
    _orchestrator.startSession(region: region, initialContext: initialContext);
    _sessionId = _orchestrator.sessionId;
    _state = _buildState();
    return state;
  }

  RadarClinicalViewState answer(
    RadarClinicalAnswer answer, {
    RadarClinicalResponseContext responseContext =
        const RadarClinicalResponseContext(),
  }) {
    final question = _orchestrator.nextQuestion();
    if (question == null) {
      _state = _buildState();
      return state;
    }

    final runtimeValue = answer.runtimeBooleanValue;
    if (runtimeValue == null) {
      _state = _buildState(
        statusOverride: RadarClinicalStatus.unsupportedAnswer,
        unsupportedAnswer: answer,
      );
      return state;
    }

    _orchestrator.answerQuestion(
      question.id,
      isPositive: runtimeValue,
      responseContext: responseContext,
    );
    _state = _buildState();
    return state;
  }

  ClinicalAdaptiveSessionV5 _requireSession() {
    final session = _orchestrator.engineSession;
    if (session == null) {
      throw StateError('No Radar clinical session has been started.');
    }
    return session;
  }

  RadarClinicalViewState _buildState({
    RadarClinicalStatus? statusOverride,
    RadarClinicalAnswer? unsupportedAnswer,
  }) {
    final session = _requireSession();
    final region = _region;
    final sessionId = _sessionId;
    if (region == null || sessionId == null) {
      throw StateError('No Radar clinical session has been started.');
    }

    final mapped = _orchestrator.engineViewState;
    if (mapped == null) {
      throw StateError('No Radar clinical session has been started.');
    }
    final status = statusOverride ?? _statusFrom(mapped);

    return RadarClinicalViewState(
      sessionId: sessionId,
      region: region,
      status: status,
      question: _questionFrom(_orchestrator.nextQuestion()),
      decision: _decisionFrom(mapped, session),
      answeredQuestionIds: session.answeredQuestionIds.keys.toSet(),
      unsupportedAnswer: unsupportedAnswer,
    );
  }

  RadarClinicalStatus _statusFrom(ClinicalAdaptiveViewStateV5 mapped) {
    if (mapped.hardStopId != null) {
      return RadarClinicalStatus.hardStop;
    }
    if (mapped.isFinal || _hasRegionalDecision) {
      return RadarClinicalStatus.decision;
    }
    return RadarClinicalStatus.question;
  }

  bool get _hasRegionalDecision {
    return switch (_orchestrator.currentOutcome) {
      RadarSessionOutcome.reassure ||
      RadarSessionOutcome.monitor ||
      RadarSessionOutcome.monitorWithShortFollowUpAndLetter ||
      RadarSessionOutcome.immediateOrientation => true,
      RadarSessionOutcome.hardStop ||
      RadarSessionOutcome.delegateToEngine ||
      null => false,
    };
  }

  RadarQuestionViewData? _questionFrom(ClinicalScreeningQuestionV4? question) {
    if (question == null) {
      return null;
    }

    return RadarQuestionViewData(
      id: question.id,
      text: question.text,
      answerType: RadarQuestionAnswerType.yesNo,
      availableAnswers: const [RadarClinicalAnswer.yes, RadarClinicalAnswer.no],
    );
  }

  RadarDecisionViewData? _decisionFrom(
    ClinicalAdaptiveViewStateV5 mapped,
    ClinicalAdaptiveSessionV5 session,
  ) {
    if (!mapped.isFinal && !_hasRegionalDecision) {
      return null;
    }

    final decisionLevel = mapped.finalDecisionLevel ?? mapped.currentRiskLevel;
    final hardStopIds = session.triggeredHardStopIds;

    return RadarDecisionViewData(
      decisionLevel: decisionLevel,
      title: _decisionTitle(decisionLevel, hardStopIds),
      summary: _decisionSummary(decisionLevel, hardStopIds),
      vigilanceMessage: _vigilanceMessage(decisionLevel, hardStopIds),
      hardStopIds: hardStopIds,
    );
  }

  String _decisionTitle(ClinicalDecisionLevel level, List<String> hardStopIds) {
    if (hardStopIds.isNotEmpty) {
      return 'Orientation prioritaire';
    }

    return switch (level) {
      ClinicalDecisionLevel.routine => 'Prise en charge possible',
      ClinicalDecisionLevel.monitor => 'Surveillance renforcée',
      ClinicalDecisionLevel.medicalAdvice => 'Avis médical recommandé',
      ClinicalDecisionLevel.urgentReferral => 'Avis médical rapide nécessaire',
      ClinicalDecisionLevel.emergency => 'Urgence immédiate',
    };
  }

  String _decisionSummary(
    ClinicalDecisionLevel level,
    List<String> hardStopIds,
  ) {
    if (hardStopIds.isNotEmpty) {
      return 'Un élément prioritaire a été identifié par le questionnaire.';
    }

    return switch (level) {
      ClinicalDecisionLevel.routine =>
        'Aucun drapeau rouge identifié parmi les éléments évalués.',
      ClinicalDecisionLevel.monitor =>
        'Les éléments recueillis justifient une surveillance clinique renforcée.',
      ClinicalDecisionLevel.medicalAdvice =>
        'Les éléments recueillis justifient un avis médical avant de poursuivre.',
      ClinicalDecisionLevel.urgentReferral =>
        'Les éléments recueillis justifient un avis médical rapide.',
      ClinicalDecisionLevel.emergency =>
        'Les éléments recueillis justifient une conduite immédiate.',
    };
  }

  String _vigilanceMessage(
    ClinicalDecisionLevel level,
    List<String> hardStopIds,
  ) {
    if (hardStopIds.isNotEmpty) {
      return 'Interrompre la prise en charge habituelle et suivre la conduite adaptée.';
    }

    return switch (level) {
      ClinicalDecisionLevel.routine =>
        'Réévaluer en cas d’évolution défavorable ou d’apparition de nouveaux signes.',
      ClinicalDecisionLevel.monitor =>
        'Réévaluer régulièrement et adapter la conduite si la situation évolue.',
      ClinicalDecisionLevel.medicalAdvice =>
        'Ne pas poursuivre sans avoir clarifié la conduite avec un avis médical.',
      ClinicalDecisionLevel.urgentReferral =>
        'Organiser l’orientation médicale dans un délai compatible avec la situation.',
      ClinicalDecisionLevel.emergency =>
        'Mettre en œuvre une conduite immédiate adaptée à la situation.',
    };
  }
}
