import '../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import '../models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import '../models/clinical_screening/clinical_hypothesis_v5.dart';
import '../models/clinical_screening/clinical_probability_update_catalog_v5.dart';
import '../models/clinical_screening/clinical_probability_update_v5.dart';
import '../models/clinical_screening/clinical_screening_models.dart';
import '../models/clinical_screening/clinical_screening_question_v4.dart';
import '../models/clinical_screening/clinical_screening_questionnaire_v4.dart';

class ClinicalAdaptiveQuestionEngineV5 {
  ClinicalAdaptiveSessionV5 initialSession() {
    final probabilities = {
      for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses)
        hypothesis.id: _initialProbabilityFor(hypothesis.initialProbability),
    };
    final nextQuestion = _selectNextQuestion(
      answeredQuestionIds: const {},
      hypothesisProbabilities: probabilities,
      hasBlockingHardStop: false,
    );

    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: const {},
      positiveFlagIds: const [],
      hypothesisProbabilities: probabilities,
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: nextQuestion,
      reasoningSummary: _buildSummary(
        answeredQuestionIds: const {},
        positiveFlagIds: const [],
        hypothesisProbabilities: probabilities,
        appliedProbabilityUpdateIds: const [],
        triggeredHardStopIds: const [],
        nextQuestion: nextQuestion,
      ),
    );
  }

  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    final question = _questionById(questionId);
    if (question == null) {
      throw ArgumentError.value(
        questionId,
        'questionId',
        'Unknown V4 question',
      );
    }

    final answeredQuestionIds = {
      ...session.answeredQuestionIds,
      questionId: isPositive,
    };
    final positiveFlagIds = [...session.positiveFlagIds];
    final hypothesisProbabilities = {...session.hypothesisProbabilities};
    final appliedProbabilityUpdateIds = [
      ...session.appliedProbabilityUpdateIds,
    ];
    final triggeredHardStopIds = [...session.triggeredHardStopIds];

    if (isPositive) {
      _addIfAbsent(positiveFlagIds, question.associatedFlagId);

      final probabilityUpdates = _updatesTriggeredBy(question);
      for (final update in probabilityUpdates) {
        hypothesisProbabilities[update.hypothesisId] = _maxProbability(
          hypothesisProbabilities[update.hypothesisId],
          update.updatedProbability,
        );
        _addIfAbsent(appliedProbabilityUpdateIds, update.id);
      }

      for (final hardStop in ClinicalHardStopCatalogV5.rules) {
        final matchesQuestion = hardStop.triggeringQuestionIds.contains(
          question.id,
        );
        final matchesFlag = hardStop.triggeringFlagIds.contains(
          question.associatedFlagId,
        );

        if (matchesQuestion || matchesFlag) {
          _addIfAbsent(triggeredHardStopIds, hardStop.id);
        }
      }
    }

    final hasBlockingHardStop = triggeredHardStopIds.isNotEmpty;
    final nextQuestion = _selectNextQuestion(
      answeredQuestionIds: answeredQuestionIds,
      hypothesisProbabilities: hypothesisProbabilities,
      hasBlockingHardStop: hasBlockingHardStop,
    );

    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: answeredQuestionIds,
      positiveFlagIds: positiveFlagIds,
      hypothesisProbabilities: hypothesisProbabilities,
      appliedProbabilityUpdateIds: appliedProbabilityUpdateIds,
      triggeredHardStopIds: triggeredHardStopIds,
      nextQuestion: nextQuestion,
      reasoningSummary: _buildSummary(
        answeredQuestionIds: answeredQuestionIds,
        positiveFlagIds: positiveFlagIds,
        hypothesisProbabilities: hypothesisProbabilities,
        appliedProbabilityUpdateIds: appliedProbabilityUpdateIds,
        triggeredHardStopIds: triggeredHardStopIds,
        nextQuestion: nextQuestion,
      ),
    );
  }

  ClinicalScreeningQuestionV4? _selectNextQuestion({
    required Map<String, bool> answeredQuestionIds,
    required Map<String, ClinicalQualitativeProbabilityV5>
    hypothesisProbabilities,
    required bool hasBlockingHardStop,
  }) {
    if (hasBlockingHardStop) {
      return null;
    }

    final unansweredQuestions = ClinicalScreeningQuestionnaireV4.questions
        .where((question) => !answeredQuestionIds.containsKey(question.id))
        .toList(growable: false);
    if (unansweredQuestions.isEmpty) {
      return null;
    }

    ClinicalScreeningQuestionV4? bestQuestion;
    var bestScore = -1;
    for (final question in unansweredQuestions) {
      final score =
          _decisionPriority(question.potentialDecisionLevel) +
          _scoreQuestion(question, hypothesisProbabilities);
      if (score > bestScore) {
        bestScore = score;
        bestQuestion = question;
      }
    }

    return bestQuestion;
  }

  int _scoreQuestion(
    ClinicalScreeningQuestionV4 question,
    Map<String, ClinicalQualitativeProbabilityV5> hypothesisProbabilities,
  ) {
    var score = 0;
    for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses) {
      final isRelated =
          hypothesis.associatedClusterIds.contains(question.ruleId) ||
          hypothesis.associatedFlagIds.contains(question.associatedFlagId);
      if (!isRelated) {
        continue;
      }

      score = _maxInt(
        score,
        _rank(
          hypothesisProbabilities[hypothesis.id] ??
              ClinicalQualitativeProbabilityV5.veryLow,
        ),
      );
    }

    return score;
  }

  List<ClinicalProbabilityUpdateV5> _updatesTriggeredBy(
    ClinicalScreeningQuestionV4 question,
  ) {
    return ClinicalProbabilityUpdateCatalogV5.updates
        .where((update) {
          final matchesQuestion = update.triggerQuestionId == question.id;
          final matchesFlag = update.triggerFlagId == question.associatedFlagId;
          return matchesQuestion || matchesFlag;
        })
        .toList(growable: false);
  }

  ClinicalScreeningQuestionV4? _questionById(String questionId) {
    for (final question in ClinicalScreeningQuestionnaireV4.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }

  ClinicalQualitativeProbabilityV5 _initialProbabilityFor(
    ClinicalHypothesisInitialProbabilityV5 probability,
  ) {
    switch (probability) {
      case ClinicalHypothesisInitialProbabilityV5.low:
        return ClinicalQualitativeProbabilityV5.low;
      case ClinicalHypothesisInitialProbabilityV5.moderate:
        return ClinicalQualitativeProbabilityV5.moderate;
      case ClinicalHypothesisInitialProbabilityV5.high:
        return ClinicalQualitativeProbabilityV5.high;
    }
  }

  ClinicalQualitativeProbabilityV5 _maxProbability(
    ClinicalQualitativeProbabilityV5? current,
    ClinicalQualitativeProbabilityV5 candidate,
  ) {
    if (current == null) {
      return candidate;
    }

    return _rank(candidate) >= _rank(current) ? candidate : current;
  }

  String _buildSummary({
    required Map<String, bool> answeredQuestionIds,
    required List<String> positiveFlagIds,
    required Map<String, ClinicalQualitativeProbabilityV5>
    hypothesisProbabilities,
    required List<String> appliedProbabilityUpdateIds,
    required List<String> triggeredHardStopIds,
    required ClinicalScreeningQuestionV4? nextQuestion,
  }) {
    final raisedHypotheses = hypothesisProbabilities.entries
        .where(
          (entry) =>
              entry.value == ClinicalQualitativeProbabilityV5.high ||
              entry.value == ClinicalQualitativeProbabilityV5.veryHigh,
        )
        .map((entry) => '${entry.key}: ${entry.value.name}')
        .toList(growable: false);

    return [
      'Questions répondues : ${answeredQuestionIds.length}.',
      if (positiveFlagIds.isNotEmpty)
        'Flags positifs : ${positiveFlagIds.join(', ')}.',
      if (appliedProbabilityUpdateIds.isNotEmpty)
        'Mises à jour appliquées : ${appliedProbabilityUpdateIds.join(', ')}.',
      if (raisedHypotheses.isNotEmpty)
        'Hypothèses augmentées : ${raisedHypotheses.join(', ')}.',
      if (triggeredHardStopIds.isNotEmpty)
        'Hard Stops déclenchés : ${triggeredHardStopIds.join(', ')}.',
      if (nextQuestion != null)
        'Prochaine question : ${nextQuestion.id}.'
      else
        'Prochaine question : aucune.',
    ].join('\n');
  }

  int _rank(ClinicalQualitativeProbabilityV5 probability) {
    return ClinicalQualitativeProbabilityV5.values.indexOf(probability);
  }

  int _decisionPriority(ClinicalDecisionLevel level) {
    switch (level) {
      case ClinicalDecisionLevel.emergency:
        return 100;
      case ClinicalDecisionLevel.urgentReferral:
        return 50;
      case ClinicalDecisionLevel.medicalAdvice:
        return 20;
      case ClinicalDecisionLevel.monitor:
        return 10;
      case ClinicalDecisionLevel.routine:
        return 0;
    }
  }

  int _maxInt(int current, int candidate) {
    return candidate > current ? candidate : current;
  }

  void _addIfAbsent(List<String> values, String value) {
    if (!values.contains(value)) {
      values.add(value);
    }
  }
}
