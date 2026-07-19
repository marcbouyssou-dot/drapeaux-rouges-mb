import '../../../models/clinical_screening/clinical_screening_models.dart';

class RadarDecisionViewData {
  RadarDecisionViewData({
    required this.decisionLevel,
    required this.title,
    required this.summary,
    required this.vigilanceMessage,
    List<String> hardStopIds = const [],
  }) : hardStopIds = List.unmodifiable(hardStopIds);

  final ClinicalDecisionLevel decisionLevel;
  final String title;
  final String summary;
  final String vigilanceMessage;
  final List<String> hardStopIds;
}
