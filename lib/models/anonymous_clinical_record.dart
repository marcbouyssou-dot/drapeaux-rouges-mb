class AnonymousClinicalRecord {
  final String anonymousPatientId;
  final DateTime evaluationDate;

  final String clinicalCategory;
  final int score;
  final String riskLevel;
  final String orientation;

  final List<String> selectedRedFlags;

  const AnonymousClinicalRecord({
    required this.anonymousPatientId,
    required this.evaluationDate,
    required this.clinicalCategory,
    required this.score,
    required this.riskLevel,
    required this.orientation,
    required this.selectedRedFlags,
  });

  Map<String, dynamic> toJson() {
    return {
      'anonymousPatientId': anonymousPatientId,
      'evaluationDate': evaluationDate.toIso8601String(),
      'clinicalCategory': clinicalCategory,
      'score': score,
      'riskLevel': riskLevel,
      'orientation': orientation,
      'selectedRedFlags': selectedRedFlags,
    };
  }

  factory AnonymousClinicalRecord.fromJson(Map<String, dynamic> json) {
    return AnonymousClinicalRecord(
      anonymousPatientId: json['anonymousPatientId'],
      evaluationDate: DateTime.parse(json['evaluationDate']),
      clinicalCategory: json['clinicalCategory'],
      score: json['score'],
      riskLevel: json['riskLevel'],
      orientation: json['orientation'],
      selectedRedFlags: List<String>.from(json['selectedRedFlags'] ?? []),
    );
  }
}