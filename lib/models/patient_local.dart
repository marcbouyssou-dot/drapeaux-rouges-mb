class PatientMedicalDocument {
  final String type;
  final String? documentPath;
  final String? documentName;
  final String? documentBase64;
  final String? documentAddedAt;

  const PatientMedicalDocument({
    required this.type,
    this.documentPath,
    this.documentName,
    this.documentBase64,
    this.documentAddedAt,
  });

  bool get hasStoredDocument {
    return (documentBase64?.trim().isNotEmpty ?? false) ||
        (documentPath?.trim().isNotEmpty ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'documentPath': documentPath,
      'documentName': documentName,
      'documentBase64': documentBase64,
      'documentAddedAt': documentAddedAt,
    };
  }

  factory PatientMedicalDocument.fromJson(Map<String, dynamic> json) {
    return PatientMedicalDocument(
      type: json['type']?.toString() ?? 'Autre justificatif',
      documentPath: json['documentPath']?.toString(),
      documentName: json['documentName']?.toString(),
      documentBase64: json['documentBase64']?.toString(),
      documentAddedAt: json['documentAddedAt']?.toString(),
    );
  }
}

class PatientLocal {
  final String localId;
  final String anonymousId;

  final String nom;
  final String prenom;
  final String dateNaissance;

  final bool consentementValide;
  final DateTime dateConsentement;
  final String? signatureBase64;
  final String adresse;
  final String codePostal;
  final String ville;
  final String telephone;
  final String email;
  final String profession;
  final String personnePrevenir;
  final String telephoneContact;
  final String medecinNom;
  final String medecinRpps;
  final String medecinAdeli;
  final String medecinAdresse;
  final String medecinTelephone;
  final String medecinEmail;
  final bool carteVitalePresentee;
  final bool identiteVerifiee;
  final List<PatientMedicalDocument> medicalDocuments;

  const PatientLocal({
    required this.localId,
    required this.anonymousId,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.consentementValide,
    required this.dateConsentement,
    this.signatureBase64,
    this.adresse = '',
    this.codePostal = '',
    this.ville = '',
    this.telephone = '',
    this.email = '',
    this.profession = '',
    this.personnePrevenir = '',
    this.telephoneContact = '',
    this.medecinNom = '',
    this.medecinRpps = '',
    this.medecinAdeli = '',
    this.medecinAdresse = '',
    this.medecinTelephone = '',
    this.medecinEmail = '',
    this.carteVitalePresentee = false,
    this.identiteVerifiee = false,
    this.medicalDocuments = const [],
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
      'adresse': adresse,
      'codePostal': codePostal,
      'ville': ville,
      'telephone': telephone,
      'email': email,
      'profession': profession,
      'personnePrevenir': personnePrevenir,
      'telephoneContact': telephoneContact,
      'medecinNom': medecinNom,
      'medecinRpps': medecinRpps,
      'medecinAdeli': medecinAdeli,
      'medecinAdresse': medecinAdresse,
      'medecinTelephone': medecinTelephone,
      'medecinEmail': medecinEmail,
      'carteVitalePresentee': carteVitalePresentee,
      'identiteVerifiee': identiteVerifiee,
      'medicalDocuments': medicalDocuments
          .map((document) => document.toJson())
          .toList(),
    };
  }

  factory PatientLocal.fromJson(Map<String, dynamic> json) {
    final rawDocuments = json['medicalDocuments'];

    return PatientLocal(
      localId: json['localId'],
      anonymousId: json['anonymousId'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: json['dateNaissance'],
      consentementValide: json['consentementValide'] ?? false,
      dateConsentement: DateTime.parse(json['dateConsentement']),
      signatureBase64: json['signatureBase64'],
      adresse: json['adresse']?.toString() ?? '',
      codePostal: json['codePostal']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      personnePrevenir: json['personnePrevenir']?.toString() ?? '',
      telephoneContact: json['telephoneContact']?.toString() ?? '',
      medecinNom: json['medecinNom']?.toString() ?? '',
      medecinRpps: json['medecinRpps']?.toString() ?? '',
      medecinAdeli: json['medecinAdeli']?.toString() ?? '',
      medecinAdresse: json['medecinAdresse']?.toString() ?? '',
      medecinTelephone: json['medecinTelephone']?.toString() ?? '',
      medecinEmail: json['medecinEmail']?.toString() ?? '',
      carteVitalePresentee: json['carteVitalePresentee'] == true,
      identiteVerifiee: json['identiteVerifiee'] == true,
      medicalDocuments: rawDocuments is List
          ? rawDocuments
                .whereType<Map>()
                .map(
                  (document) => PatientMedicalDocument.fromJson(
                    Map<String, dynamic>.from(document),
                  ),
                )
                .toList()
          : const [],
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
