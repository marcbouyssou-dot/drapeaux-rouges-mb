class CloudHdsContractModel {
  static const int schemaVersion = 1;

  static Map<String, dynamic> buildEvaluationPayload({
    required Map<String, dynamic> evaluation,
  }) {
    return {
      'schemaVersion': schemaVersion,

      // Identifiants pseudonymisés uniquement
      'patientPseudonymizedId':
          evaluation['patientAnonymousId']?.toString() ?? 'non_renseigne',
      'evaluationPseudonymizedId': evaluation['evaluationId']?.toString() ?? '',

      // Date réduite au mois pour limiter le risque de réidentification
      'evaluationMonth': _monthOnly(evaluation['date']?.toString()),

      // Données cliniques non directement identifiantes
      'motif': evaluation['motif'],
      'scoreGlobal': evaluation['score'],
      'riskLevel': evaluation['riskLevel'],
      'checkedCount': evaluation['checkedCount'],

      // Drapeaux rouges sans texte nominatif
      'checkedFlags': _checkedFlags(evaluation),

      // Décision clinique
      'decisionTitle': evaluation['decisionTitle'],

      // Ne pas envoyer :
      // - patientDisplayName
      // - nom
      // - prénom
      // - date de naissance complète
      // - signature
      // - texte libre potentiellement identifiant
    };
  }

  static List<Map<String, dynamic>> _checkedFlags(
    Map<String, dynamic> evaluation,
  ) {
    final raw = evaluation['checkedFlags'];

    if (raw is! List) return [];

    return raw.map((item) {
      final flag = Map<String, dynamic>.from(item as Map);

      return {
        'category': flag['category'],
        'severity': flag['severity'],
        'tags': flag['tags'] ?? [],
      };
    }).toList();
  }

  static String _monthOnly(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';

    final date = DateTime.tryParse(rawDate);
    if (date == null) return '';

    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
