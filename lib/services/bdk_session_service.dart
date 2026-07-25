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
  static const int draftSchemaVersion = 1;

  static String? patientLocalId;
  static String? patientAnonymousId;
  static String patientDisplayName = '';

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

  static bool get hasPatientAssociation {
    return (patientLocalId?.trim().isNotEmpty ?? false) ||
        (patientAnonymousId?.trim().isNotEmpty ?? false) ||
        patientDisplayName.trim().isNotEmpty;
  }

  static bool isAssociatedWithPatient({
    required String? localId,
    required String? anonymousId,
  }) {
    final associatedLocalId = patientLocalId?.trim() ?? '';
    final associatedAnonymousId = patientAnonymousId?.trim() ?? '';
    final targetLocalId = localId?.trim() ?? '';
    final targetAnonymousId = anonymousId?.trim() ?? '';

    if (targetLocalId.isEmpty && targetAnonymousId.isEmpty) {
      return associatedLocalId.isEmpty && associatedAnonymousId.isEmpty;
    }

    if (associatedLocalId.isNotEmpty && targetLocalId.isNotEmpty) {
      return associatedLocalId == targetLocalId;
    }

    if (associatedAnonymousId.isNotEmpty && targetAnonymousId.isNotEmpty) {
      return associatedAnonymousId == targetAnonymousId;
    }

    return false;
  }

  static void associatePatient({
    required String? localId,
    required String? anonymousId,
    required String displayName,
  }) {
    patientLocalId = localId;
    patientAnonymousId = anonymousId;
    patientDisplayName = displayName.trim();
  }

  static void clear() {
    patientLocalId = null;
    patientAnonymousId = null;
    patientDisplayName = '';

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

  static bool get hasDraftContent {
    return [
          motif,
          contexte,
          antecedents,
          evaluation,
          tests,
          limitations,
          diagnostic,
          vigilance,
          objectifs,
          planTraitement,
          criteresReevaluation,
          syntheseClinique,
          riskLevel,
        ].any((value) => value.trim().isNotEmpty) ||
        riskScore != 0 ||
        redFlags.isNotEmpty;
  }

  static Map<String, dynamic> toDraftMap({
    required String title,
    String? customContext,
    required DateTime updatedAt,
  }) {
    return {
      'schemaVersion': draftSchemaVersion,
      'title': title.trim(),
      'customContext': customContext?.trim(),
      'updatedAt': updatedAt.toIso8601String(),
      'patientLocalId': patientLocalId,
      'patientAnonymousId': patientAnonymousId,
      'patientDisplayName': patientDisplayName,
      'motif': motif,
      'contexte': contexte,
      'antecedents': antecedents,
      'evaluation': evaluation,
      'tests': tests,
      'limitations': limitations,
      'diagnostic': diagnostic,
      'vigilance': vigilance,
      'objectifs': objectifs,
      'planTraitement': planTraitement,
      'criteresReevaluation': criteresReevaluation,
      'syntheseClinique': syntheseClinique,
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'redFlags': List<String>.from(redFlags),
    };
  }

  static void loadFromDraftMap(Map<String, dynamic> draft) {
    patientLocalId = _nullableString(draft['patientLocalId']);
    patientAnonymousId = _nullableString(draft['patientAnonymousId']);
    patientDisplayName = _stringValue(draft['patientDisplayName']);

    motif = _stringValue(draft['motif']);
    contexte = _stringValue(draft['contexte']);
    antecedents = _stringValue(draft['antecedents']);

    evaluation = _stringValue(draft['evaluation']);
    tests = _stringValue(draft['tests']);
    limitations = _stringValue(draft['limitations']);

    diagnostic = _stringValue(draft['diagnostic']);
    vigilance = _stringValue(draft['vigilance']);

    objectifs = _stringValue(draft['objectifs']);
    planTraitement = _stringValue(draft['planTraitement']);
    criteresReevaluation = _stringValue(draft['criteresReevaluation']);
    syntheseClinique = _stringValue(draft['syntheseClinique']);

    riskLevel = _stringValue(draft['riskLevel']);
    riskScore = _intValue(draft['riskScore']);
    redFlags = _stringList(draft['redFlags']);
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

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).toList();
  }
}
