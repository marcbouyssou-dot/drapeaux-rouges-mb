class AccessDirectModel {
  final bool isCoordinatedExercise;
  final bool isExperimentalDepartment;
  final bool hasArsDeclaration;
  final bool hasMedicalDiagnosis;
  final String? diagnosisDocumentPath;
  final int sessionsDone;

  const AccessDirectModel({
    required this.isCoordinatedExercise,
    required this.isExperimentalDepartment,
    required this.hasArsDeclaration,
    required this.hasMedicalDiagnosis,
    this.diagnosisDocumentPath,
    required this.sessionsDone,
  });

  bool get isAccessDirectEligible {
    return isCoordinatedExercise &&
        isExperimentalDepartment &&
        hasArsDeclaration;
  }

  bool get hasDiagnosisProof {
    return hasMedicalDiagnosis && diagnosisDocumentPath != null;
  }

  int? get maxSessions {
    if (!isAccessDirectEligible) return null;
    if (hasMedicalDiagnosis) return null;
    return 8;
  }

  bool get isSessionLimitReached {
    if (maxSessions == null) return false;
    return sessionsDone >= maxSessions!;
  }

  bool get shouldAlertBeforeLimit {
    if (maxSessions == null) return false;
    return sessionsDone >= 6 && sessionsDone < maxSessions!;
  }

  String get statusLabel {
    if (!isAccessDirectEligible) {
      return 'Accès direct non validé';
    }

    if (hasMedicalDiagnosis) {
      if (hasDiagnosisProof) {
        return 'Diagnostic préalable justifié';
      }
      return 'Diagnostic déclaré — justificatif manquant';
    }

    return 'Accès direct limité à 8 séances';
  }

  String get sessionLabel {
    if (!isAccessDirectEligible) {
      return 'Conditions réglementaires incomplètes';
    }

    if (hasMedicalDiagnosis) {
      return 'Pas de limitation réglementaire de séances';
    }

    return '$sessionsDone / 8 séances';
  }

  Map<String, dynamic> toJson() {
    return {
      'isCoordinatedExercise': isCoordinatedExercise,
      'isExperimentalDepartment': isExperimentalDepartment,
      'hasArsDeclaration': hasArsDeclaration,
      'hasMedicalDiagnosis': hasMedicalDiagnosis,
      'diagnosisDocumentPath': diagnosisDocumentPath,
      'sessionsDone': sessionsDone,
    };
  }

  factory AccessDirectModel.fromJson(Map<String, dynamic> json) {
    return AccessDirectModel(
      isCoordinatedExercise: json['isCoordinatedExercise'] == true,
      isExperimentalDepartment: json['isExperimentalDepartment'] == true,
      hasArsDeclaration: json['hasArsDeclaration'] == true,
      hasMedicalDiagnosis: json['hasMedicalDiagnosis'] == true,
      diagnosisDocumentPath: json['diagnosisDocumentPath']?.toString(),
      sessionsDone: json['sessionsDone'] is int ? json['sessionsDone'] : 0,
    );
  }

  static const empty = AccessDirectModel(
    isCoordinatedExercise: false,
    isExperimentalDepartment: false,
    hasArsDeclaration: false,
    hasMedicalDiagnosis: false,
    diagnosisDocumentPath: null,
    sessionsDone: 0,
  );
}