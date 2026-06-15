class PractitionerProfile {
  final String nom;
  final String prenom;
  final String adresse;
  final String adeli;
  final String rpps;
  final String profession;
  final String email;
  final String telephone;
  final bool exerciceCoordonne;
  final bool exerciceAccesDirect;
  final String nomStructure;
  final String adresseStructure;
  final String departement;
  final String signatureBase64;

  const PractitionerProfile({
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.adeli,
    required this.rpps,
    this.profession = '',
    this.email = '',
    this.telephone = '',
    this.exerciceCoordonne = false,
    this.exerciceAccesDirect = false,
    this.nomStructure = '',
    this.adresseStructure = '',
    this.departement = '',
    this.signatureBase64 = '',
  });

  bool get isComplete {
    return nom.trim().isNotEmpty &&
        prenom.trim().isNotEmpty &&
        adresse.trim().isNotEmpty;
  }

  String get fullName {
    return '${prenom.trim()} ${nom.trim().toUpperCase()}'.trim();
  }

  String get professionLabel {
    final value = profession.trim();
    return value.isEmpty ? 'Masseur-kinésithérapeute' : value;
  }

  bool get hasStructure {
    return exerciceCoordonne ||
        exerciceAccesDirect ||
        nomStructure.trim().isNotEmpty ||
        adresseStructure.trim().isNotEmpty ||
        departement.trim().isNotEmpty;
  }

  bool get hasDirectAccess {
    return exerciceAccesDirect ||
        nomStructure.trim().isNotEmpty ||
        adresseStructure.trim().isNotEmpty ||
        departement.trim().isNotEmpty;
  }

  String get practiceStructureLine {
    final parts = <String>[];

    if (exerciceAccesDirect) {
      parts.add('Exercice en accès direct');
    }
    if (exerciceCoordonne) {
      parts.add('Exercice coordonné');
    }
    if (nomStructure.trim().isNotEmpty) {
      parts.add('Structure : ${nomStructure.trim()}');
    }
    if (adresseStructure.trim().isNotEmpty) {
      parts.add(adresseStructure.trim());
    }
    if (departement.trim().isNotEmpty) {
      parts.add('Département : ${departement.trim()}');
    }

    return parts.join(' · ');
  }

  bool get hasSignature {
    return signatureBase64.trim().isNotEmpty;
  }

  PractitionerProfile copyWith({
    String? nom,
    String? prenom,
    String? adresse,
    String? adeli,
    String? rpps,
    String? profession,
    String? email,
    String? telephone,
    bool? exerciceCoordonne,
    bool? exerciceAccesDirect,
    String? nomStructure,
    String? adresseStructure,
    String? departement,
    String? signatureBase64,
  }) {
    return PractitionerProfile(
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      adresse: adresse ?? this.adresse,
      adeli: adeli ?? this.adeli,
      rpps: rpps ?? this.rpps,
      profession: profession ?? this.profession,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      exerciceCoordonne: exerciceCoordonne ?? this.exerciceCoordonne,
      exerciceAccesDirect: exerciceAccesDirect ?? this.exerciceAccesDirect,
      nomStructure: nomStructure ?? this.nomStructure,
      adresseStructure: adresseStructure ?? this.adresseStructure,
      departement: departement ?? this.departement,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'adeli': adeli,
      'rpps': rpps,
      'profession': profession,
      'email': email,
      'telephone': telephone,
      'exerciceCoordonne': exerciceCoordonne,
      'exerciceAccesDirect': exerciceAccesDirect,
      'nomStructure': nomStructure,
      'adresseStructure': adresseStructure,
      'departement': departement,
      'signatureBase64': signatureBase64,
    };
  }

  factory PractitionerProfile.fromJson(Map<String, dynamic> json) {
    return PractitionerProfile(
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      adeli: json['adeli']?.toString() ?? '',
      rpps: json['rpps']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      exerciceCoordonne: json['exerciceCoordonne'] == true,
      exerciceAccesDirect: json['exerciceAccesDirect'] == true,
      nomStructure: json['nomStructure']?.toString() ?? '',
      adresseStructure: json['adresseStructure']?.toString() ?? '',
      departement: json['departement']?.toString() ?? '',
      signatureBase64: json['signatureBase64']?.toString() ?? '',
    );
  }

  factory PractitionerProfile.empty() {
    return const PractitionerProfile(
      nom: '',
      prenom: '',
      adresse: '',
      adeli: '',
      rpps: '',
      profession: '',
      email: '',
      telephone: '',
      exerciceCoordonne: false,
      exerciceAccesDirect: false,
      nomStructure: '',
      adresseStructure: '',
      departement: '',
      signatureBase64: '',
    );
  }
}
