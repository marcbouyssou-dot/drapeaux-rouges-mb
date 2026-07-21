class BDKClinicalPrefill {
  const BDKClinicalPrefill({
    required this.regionLabel,
    required this.decisionTitle,
    required this.decisionSummary,
    required this.vigilanceMessage,
    required this.clinicalExplanation,
    this.positiveFindings = const [],
    this.negativeFindings = const [],
  });

  final String regionLabel;
  final String decisionTitle;
  final String decisionSummary;
  final String vigilanceMessage;
  final String clinicalExplanation;
  final List<String> positiveFindings;
  final List<String> negativeFindings;
}

class BDKSessionService {
  static String motif = '';
  static String contexte = '';
  static String antecedents = '';

  static String evaluation = '';
  static String tests = '';
  static String limitations = '';

  static String diagnostic = '';
  static String vigilance = '';

  static String objectifs = '';
  static String planTraitement = '';
  static String criteresReevaluation = '';
  static String syntheseClinique = '';

  static String riskLevel = '';
  static int riskScore = 0;

  static List<String> redFlags = [];

  static void clear() {
    motif = '';
    contexte = '';
    antecedents = '';

    evaluation = '';
    tests = '';
    limitations = '';

    diagnostic = '';
    vigilance = '';

    objectifs = '';
    planTraitement = '';
    criteresReevaluation = '';
    syntheseClinique = '';

    riskLevel = '';
    riskScore = 0;

    redFlags.clear();
  }

  static void loadFromEvaluation({
    required String selectedCategory,
    required int score,
    required String risk,
    required List<Map<String, dynamic>> checkedFlagsData,
    required String aiSummary,
    required String decisionMessage,
  }) {
    motif = selectedCategory;

    riskScore = score;
    riskLevel = risk;

    redFlags = checkedFlagsData
        .map(
          (flag) =>
              flag['title']?.toString() ??
              flag['label']?.toString() ??
              flag['question']?.toString() ??
              flag['text']?.toString() ??
              'Drapeau',
        )
        .toList();

    evaluation = aiSummary;

    vigilance = decisionMessage;

    diagnostic =
        '''
Évaluation réalisée dans le cadre de l’accès direct.

Le niveau de risque identifié est : $risk.
Le score clinique est de $score.

Les éléments cochés nécessitent une vigilance clinique adaptée et une réévaluation selon l’évolution.
''';

    objectifs = '''
- Sécuriser la prise en charge
- Adapter les soins au niveau de risque
- Surveiller l’évolution clinique
- Réorienter si apparition ou aggravation de signes d’alerte
''';

    planTraitement = '''
Prise en charge kinésithérapique adaptée au tableau clinique, avec surveillance des signes d’alerte et réévaluation régulière.
''';

    criteresReevaluation = '''
- Évolution de la douleur
- Évolution fonctionnelle
- Apparition de nouveaux signes d’alerte
- Tolérance à la prise en charge
''';

    syntheseClinique =
        '''
Motif principal : $selectedCategory

Niveau de risque : $risk
Score clinique : $score

Drapeaux retrouvés :
${redFlags.isEmpty ? '- Aucun drapeau transféré' : redFlags.map((e) => '- $e').join('\n')}

Synthèse clinique :
$aiSummary
''';
  }

  static void loadFromClinicalSummary(BDKClinicalPrefill prefill) {
    clear();

    motif = _joinNonEmpty([
      'Évaluation de sécurité clinique',
      if (prefill.regionLabel.trim().isNotEmpty) prefill.regionLabel,
    ], separator: ' - ');

    contexte = _joinNonEmpty([
      if (prefill.regionLabel.trim().isNotEmpty)
        'Région évaluée : ${prefill.regionLabel.trim()}',
      'Évaluation de sécurité clinique réalisée avant le bilan.',
    ]);

    evaluation = _joinNonEmpty([
      prefill.clinicalExplanation,
      prefill.decisionSummary,
      if (prefill.positiveFindings.isNotEmpty) ...[
        'Éléments cliniques retrouvés :',
        ...prefill.positiveFindings.map((finding) => '- ${finding.trim()}'),
      ],
      if (prefill.negativeFindings.isNotEmpty) ...[
        'Éléments non retrouvés utiles :',
        ...prefill.negativeFindings.map((finding) => '- ${finding.trim()}'),
      ],
    ]);

    vigilance = prefill.vigilanceMessage.trim();

    syntheseClinique = _joinNonEmpty([
      if (motif.trim().isNotEmpty) 'Motif : $motif',
      if (prefill.decisionTitle.trim().isNotEmpty)
        'Conclusion Radar : ${prefill.decisionTitle.trim()}',
      if (prefill.decisionSummary.trim().isNotEmpty)
        prefill.decisionSummary.trim(),
      if (prefill.vigilanceMessage.trim().isNotEmpty)
        prefill.vigilanceMessage.trim(),
    ]);
  }

  static String _joinNonEmpty(
    Iterable<String> values, {
    String separator = '\n',
  }) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(separator);
  }
}
