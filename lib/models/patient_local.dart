class PatientLocal {
  final String localId;
  final String anonymousId;

  final String nom;
  final String prenom;
  final String dateNaissance;

  final bool consentementValide;
  final DateTime dateConsentement;
  final String? signatureBase64;

  const PatientLocal({
    required this.localId,
    required this.anonymousId,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.consentementValide,
    required this.dateConsentement,
    this.signatureBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'anonymousId': anonymousId,
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance,
      'consentementValide': consentementValide,
      'dateConsentement': dateConsentement.toIso8601String(),
      'signatureBase64': signatureBase64,
    };
  }

  factory PatientLocal.fromJson(Map<String, dynamic> json) {
    return PatientLocal(
      localId: json['localId'],
      anonymousId: json['anonymousId'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: json['dateNaissance'],
      consentementValide: json['consentementValide'] ?? false,
      dateConsentement: DateTime.parse(json['dateConsentement']),
      signatureBase64: json['signatureBase64'],
    );
  }

  Map<String, dynamic> toAnonymousExport() {
    return {
      'anonymousId': anonymousId,
      'consentementValide': consentementValide,
      'dateConsentement': dateConsentement.toIso8601String(),

      // IMPORTANT :
      // nom, prénom, date de naissance et signature exclus de l’export.
    };
  }
}