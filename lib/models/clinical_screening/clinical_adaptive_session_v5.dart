import 'clinical_hard_stop_catalog_v5.dart';
import 'clinical_hard_stop_rule_v5.dart';
import 'clinical_probability_update_v5.dart';
import 'clinical_screening_question_v4.dart';

class ClinicalAdaptiveSessionV5 {
  final Map<String, bool> answeredQuestionIds;
  final List<String> positiveFlagIds;
  final List<String> reassuringFlagIds;
  final Map<String, ClinicalQualitativeProbabilityV5> hypothesisProbabilities;
  final List<String> appliedProbabilityUpdateIds;
  final List<String> triggeredHardStopIds;
  final ClinicalScreeningQuestionV4? nextQuestion;
  final String reasoningSummary;

  ClinicalAdaptiveSessionV5({
    required Map<String, bool> answeredQuestionIds,
    required List<String> positiveFlagIds,
    required List<String> reassuringFlagIds,
    required Map<String, ClinicalQualitativeProbabilityV5>
    hypothesisProbabilities,
    required List<String> appliedProbabilityUpdateIds,
    required List<String> triggeredHardStopIds,
    required this.nextQuestion,
    required this.reasoningSummary,
  }) : answeredQuestionIds = Map.unmodifiable(answeredQuestionIds),
       positiveFlagIds = List.unmodifiable(positiveFlagIds),
       reassuringFlagIds = List.unmodifiable(reassuringFlagIds),
       hypothesisProbabilities = Map.unmodifiable(hypothesisProbabilities),
       appliedProbabilityUpdateIds = List.unmodifiable(
         appliedProbabilityUpdateIds,
       ),
       triggeredHardStopIds = List.unmodifiable(triggeredHardStopIds);

  bool get hasTriggeredHardStop => triggeredHardStopIds.isNotEmpty;

  ClinicalHardStopStateV5 get hardStopState {
    if (triggeredHardStopIds.isEmpty) {
      return ClinicalHardStopStateV5.absent;
    }

    final states = triggeredHardStopIds
        .map(ClinicalHardStopCatalogV5.ruleById)
        .whereType<ClinicalHardStopRuleV5>()
        .map((rule) => rule.state);

    return states.contains(ClinicalHardStopStateV5.confirmed)
        ? ClinicalHardStopStateV5.confirmed
        : ClinicalHardStopStateV5.suspected;
  }

  bool get canReassure =>
      hardStopState == ClinicalHardStopStateV5.absent &&
      positiveFlagIds.isEmpty;

  ClinicalAdaptiveSessionV5 copyWith({
    Map<String, bool>? answeredQuestionIds,
    List<String>? positiveFlagIds,
    List<String>? reassuringFlagIds,
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
      reassuringFlagIds: reassuringFlagIds ?? this.reassuringFlagIds,
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
