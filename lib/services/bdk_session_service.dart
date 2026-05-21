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

    diagnostic = '''
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

    syntheseClinique = '''
Motif principal : $selectedCategory

Niveau de risque : $risk
Score clinique : $score

Drapeaux retrouvés :
${redFlags.isEmpty ? '- Aucun drapeau transféré' : redFlags.map((e) => '- $e').join('\n')}

Synthèse clinique :
$aiSummary
''';
  }
}