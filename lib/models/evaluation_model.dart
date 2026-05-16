class EvaluationModel {
  final String evaluationId;

  final String? patientLocalId;
  final String? patientAnonymousId;

  final String patientDisplayName;

  final DateTime date;

  final String motif;

  final int score;

  final String riskLevel;

  final int checkedCount;

  final List<Map<String, dynamic>> checkedFlags;

  final String decisionTitle;

  final String decisionMessage;

  // NOUVEAU
  final String aiSummary;

  const EvaluationModel({
    required this.evaluationId,
    required this.patientLocalId,
    required this.patientAnonymousId,
    required this.patientDisplayName,
    required this.date,
    required this.motif,
    required this.score,
    required this.riskLevel,
    required this.checkedCount,
    required this.checkedFlags,
    required this.decisionTitle,
    required this.decisionMessage,

    // NOUVEAU
    required this.aiSummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'patientLocalId': patientLocalId,
      'patientAnonymousId': patientAnonymousId,
      'patientDisplayName': patientDisplayName,
      'date': date.toIso8601String(),
      'motif': motif,
      'score': score,
      'riskLevel': riskLevel,
      'checkedCount': checkedCount,
      'checkedFlags': checkedFlags,
      'decisionTitle': decisionTitle,
      'decisionMessage': decisionMessage,

      // NOUVEAU
      'aiSummary': aiSummary,
    };
  }

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      evaluationId: json['evaluationId'] ?? '',

      patientLocalId: json['patientLocalId'],

      patientAnonymousId: json['patientAnonymousId'],

      patientDisplayName:
          json['patientDisplayName'] ?? 'Patient non renseigné',

      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),

      motif: json['motif'] ?? 'Motif non renseigné',

      score: json['score'] ?? 0,

      riskLevel: json['riskLevel'] ?? 'Risque inconnu',

      checkedCount: json['checkedCount'] ?? 0,

      checkedFlags:
          List<Map<String, dynamic>>.from(json['checkedFlags'] ?? []),

      decisionTitle:
          json['decisionTitle'] ?? 'Décision non renseignée',

      decisionMessage:
          json['decisionMessage'] ?? 'Aucun message.',

      // NOUVEAU
      aiSummary:
          json['aiSummary'] ?? 'Synthèse IA non disponible.',
    );
  }
}