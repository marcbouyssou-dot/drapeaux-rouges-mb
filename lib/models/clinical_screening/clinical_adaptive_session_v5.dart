import 'clinical_probability_update_v5.dart';
import 'clinical_screening_question_v4.dart';

class ClinicalAdaptiveSessionV5 {
  final Map<String, bool> answeredQuestionIds;
  final List<String> positiveFlagIds;
  final Map<String, ClinicalQualitativeProbabilityV5> hypothesisProbabilities;
  final List<String> appliedProbabilityUpdateIds;
  final List<String> triggeredHardStopIds;
  final ClinicalScreeningQuestionV4? nextQuestion;
  final String reasoningSummary;

  ClinicalAdaptiveSessionV5({
    required Map<String, bool> answeredQuestionIds,
    required List<String> positiveFlagIds,
    required Map<String, ClinicalQualitativeProbabilityV5>
    hypothesisProbabilities,
    required List<String> appliedProbabilityUpdateIds,
    required List<String> triggeredHardStopIds,
    required this.nextQuestion,
    required this.reasoningSummary,
  }) : answeredQuestionIds = Map.unmodifiable(answeredQuestionIds),
       positiveFlagIds = List.unmodifiable(positiveFlagIds),
       hypothesisProbabilities = Map.unmodifiable(hypothesisProbabilities),
       appliedProbabilityUpdateIds = List.unmodifiable(
         appliedProbabilityUpdateIds,
       ),
       triggeredHardStopIds = List.unmodifiable(triggeredHardStopIds);

  bool get hasTriggeredHardStop => triggeredHardStopIds.isNotEmpty;

  ClinicalAdaptiveSessionV5 copyWith({
    Map<String, bool>? answeredQuestionIds,
    List<String>? positiveFlagIds,
    Map<String, ClinicalQualitativeProbabilityV5>? hypothesisProbabilities,
    List<String>? appliedProbabilityUpdateIds,
    List<String>? triggeredHardStopIds,
    ClinicalScreeningQuestionV4? nextQuestion,
    bool clearNextQuestion = false,
    String? reasoningSummary,
  }) {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
      positiveFlagIds: positiveFlagIds ?? this.positiveFlagIds,
      hypothesisProbabilities:
          hypothesisProbabilities ?? this.hypothesisProbabilities,
      appliedProbabilityUpdateIds:
          appliedProbabilityUpdateIds ?? this.appliedProbabilityUpdateIds,
      triggeredHardStopIds: triggeredHardStopIds ?? this.triggeredHardStopIds,
      nextQuestion: clearNextQuestion
          ? null
          : nextQuestion ?? this.nextQuestion,
      reasoningSummary: reasoningSummary ?? this.reasoningSummary,
    );
  }
}
