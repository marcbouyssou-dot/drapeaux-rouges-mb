import 'radar_clinical_answer.dart';

enum RadarQuestionAnswerType { yesNo }

class RadarQuestionViewData {
  RadarQuestionViewData({
    required this.id,
    required this.text,
    required this.answerType,
    required List<RadarClinicalAnswer> availableAnswers,
  }) : availableAnswers = List.unmodifiable(availableAnswers);

  final String id;
  final String text;
  final RadarQuestionAnswerType answerType;
  final List<RadarClinicalAnswer> availableAnswers;
}
