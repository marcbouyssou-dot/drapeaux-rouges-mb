class PractitionerProfile {
  final String nom;
  final String prenom;
  final String adresse;
  final String adeli;
  final String rpps;

  const PractitionerProfile({
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.adeli,
    required this.rpps,
  });

  bool get isComplete {
    return nom.trim().isNotEmpty &&
        prenom.trim().isNotEmpty &&
        adresse.trim().isNotEmpty;
  }

  String get fullName {
    return '${prenom.trim()} ${nom.trim().toUpperCase()}'.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'adeli': adeli,
      'rpps': rpps,
    };
  }

  factory PractitionerProfile.fromJson(Map<String, dynamic> json) {
    return PractitionerProfile(
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      adeli: json['adeli']?.toString() ?? '',
      rpps: json['rpps']?.toString() ?? '',
    );
  }

  factory PractitionerProfile.empty() {
    return const PractitionerProfile(
      nom: '',
      prenom: '',
      adresse: '',
      adeli: '',
      rpps: '',
    );
  }
}