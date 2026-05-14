class PrescriptionModel {
  final String professional;
  final String patient;
  final String clinicalContext;
  final String prescription;
  final String frequency;
  final String duration;
  final String nomenclature;
  final DateTime createdAt;

  PrescriptionModel({
    required this.professional,
    required this.patient,
    required this.clinicalContext,
    required this.prescription,
    required this.frequency,
    required this.duration,
    required this.nomenclature,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'professional': professional,
      'patient': patient,
      'clinicalContext': clinicalContext,
      'prescription': prescription,
      'frequency': frequency,
      'duration': duration,
      'nomenclature': nomenclature,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrescriptionModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionModel(
      professional: map['professional'] ?? '',
      patient: map['patient'] ?? '',
      clinicalContext: map['clinicalContext'] ?? '',
      prescription: map['prescription'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      nomenclature: map['nomenclature'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}