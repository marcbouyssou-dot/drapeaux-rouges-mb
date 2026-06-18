class PatientRecordModel {
  final String patientLocalId;
  final String patientAnonymousId;
  final String patientDisplayName;

  final List<Map<String, dynamic>> evaluations;
  final List<Map<String, dynamic>> prescriptions;

  const PatientRecordModel({
    required this.patientLocalId,
    required this.patientAnonymousId,
    required this.patientDisplayName,
    required this.evaluations,
    required this.prescriptions,
  });

  int get evaluationCount => evaluations.length;

  int get prescriptionCount => prescriptions.length;

  int get totalFlags {
    return evaluations.fold<int>(0, (sum, evaluation) {
      final value = evaluation['checkedCount'];

      if (value is int) return sum + value;

      return sum + (int.tryParse(value?.toString() ?? '') ?? 0);
    });
  }

  double get averageScore {
    if (evaluations.isEmpty) return 0;

    final total = evaluations.fold<double>(0, (sum, evaluation) {
      final value = evaluation['score'];

      if (value is int) return sum + value;
      if (value is double) return sum + value;

      return sum + (double.tryParse(value?.toString() ?? '') ?? 0);
    });

    return total / evaluations.length;
  }

  Map<String, dynamic> toAnonymousExport() {
    return {
      'patientAnonymousId': patientAnonymousId,
      'evaluationCount': evaluationCount,
      'prescriptionCount': prescriptionCount,
      'totalFlags': totalFlags,
      'averageScore': averageScore,
      'evaluations': evaluations.map((evaluation) {
        return {
          'date': evaluation['date'],
          'motif': evaluation['motif'],
          'score': evaluation['score'],
          'riskLevel': evaluation['riskLevel'],
          'checkedCount': evaluation['checkedCount'],
          'checkedFlags': evaluation['checkedFlags'],
          'decisionTitle': evaluation['decisionTitle'],
        };
      }).toList(),
    };
  }
}
