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
  final String nomStructure;
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
    this.nomStructure = '',
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
    return exerciceCoordonne || nomStructure.trim().isNotEmpty;
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
    String? nomStructure,
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
      nomStructure: nomStructure ?? this.nomStructure,
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
      'nomStructure': nomStructure,
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
      nomStructure: json['nomStructure']?.toString() ?? '',
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
      nomStructure: '',
      signatureBase64: '',
    );
  }
}
