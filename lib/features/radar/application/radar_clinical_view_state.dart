import 'radar_clinical_answer.dart';
import 'radar_clinical_hard_stop_view_state.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_summary_view_state.dart';
import 'radar_clinical_status.dart';
import 'radar_decision_view_data.dart';
import 'radar_question_view_data.dart';

class RadarClinicalViewState {
  RadarClinicalViewState({
    required this.sessionId,
    required this.region,
    required this.status,
    required this.question,
    required this.decision,
    required Set<String> answeredQuestionIds,
    this.hardStop,
    this.summary,
    this.unsupportedAnswer,
  }) : answeredQuestionIds = Set.unmodifiable(answeredQuestionIds);

  final String sessionId;
  final RadarClinicalRegion region;
  final RadarClinicalStatus status;
  final RadarQuestionViewData? question;
  final RadarDecisionViewData? decision;
  final Set<String> answeredQuestionIds;
  final RadarClinicalHardStopViewState? hardStop;
  final RadarClinicalSummaryViewState? summary;
  final RadarClinicalAnswer? unsupportedAnswer;
}
