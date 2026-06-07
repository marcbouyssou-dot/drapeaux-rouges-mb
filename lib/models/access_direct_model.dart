class AccessDirectModel {
  final bool isCoordinatedExercise;
  final bool isExperimentalDepartment;
  final bool hasArsDeclaration;
  final bool hasMedicalDiagnosis;
  final String? diagnosisDocumentPath;
  final String? diagnosisDocumentName;
  final String? diagnosisDocumentBase64;
  final String? diagnosisDocumentAddedAt;
  final int sessionsDone;

  const AccessDirectModel({
    required this.isCoordinatedExercise,
    required this.isExperimentalDepartment,
    required this.hasArsDeclaration,
    required this.hasMedicalDiagnosis,
    this.diagnosisDocumentPath,
    this.diagnosisDocumentName,
    this.diagnosisDocumentBase64,
    this.diagnosisDocumentAddedAt,
    required this.sessionsDone,
  });

  bool get isAccessDirectEligible {
    return isCoordinatedExercise &&
        isExperimentalDepartment &&
        hasArsDeclaration;
  }

  bool get hasDiagnosisProof {
    return hasMedicalDiagnosis &&
        ((diagnosisDocumentBase64?.trim().isNotEmpty ?? false) ||
            (diagnosisDocumentPath?.trim().isNotEmpty ?? false));
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
      'diagnosisDocumentName': diagnosisDocumentName,
      'diagnosisDocumentBase64': diagnosisDocumentBase64,
      'diagnosisDocumentAddedAt': diagnosisDocumentAddedAt,
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
      diagnosisDocumentName: json['diagnosisDocumentName']?.toString(),
      diagnosisDocumentBase64: json['diagnosisDocumentBase64']?.toString(),
      diagnosisDocumentAddedAt: json['diagnosisDocumentAddedAt']?.toString(),
      sessionsDone: json['sessionsDone'] is int ? json['sessionsDone'] : 0,
    );
  }

  static const empty = AccessDirectModel(
    isCoordinatedExercise: false,
    isExperimentalDepartment: false,
    hasArsDeclaration: false,
    hasMedicalDiagnosis: false,
    diagnosisDocumentPath: null,
    diagnosisDocumentName: null,
    diagnosisDocumentBase64: null,
    diagnosisDocumentAddedAt: null,
    sessionsDone: 0,
  );
}
