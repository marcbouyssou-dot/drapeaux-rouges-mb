import 'radar_clinical_region.dart';

/// Version de la matrice clinique encodée dans ce fichier.
/// Cette constante DOIT être écrite dans le log de chaque session Radar :
/// c'est la chaîne de traçabilité « fichier voté → code → log ».
/// À incrémenter uniquement après un tour de Delphi consolidé.
const String kRadarPathwayMatrixVersion = '0.1-experimental';
const String kRadarPathwayClinicalValidationStatus = 'NON VALIDÉE';

enum RadarClinicalOperatingMode { experimental }

/// Rôle d'une question dans un pathway régional.
enum RadarQuestionRole {
  /// Socle universel : posée à 100 % des patients, toutes régions,
  /// sans condition. Plancher de sensibilité du système.
  universal,

  /// Régionale critique : toujours posée dans la région, hard-stop régional
  /// en tête de parcours.
  regionalCritical,

  /// Conditionnelle : posée uniquement si sa condition d'activation est vraie
  /// (portes contextuelles et/ou déclencheurs cliniques).
  conditional,

  /// Clôture : confirmation d'une explication mécanique cohérente.
  /// Requise pour atteindre DEC_REASSURE (réassurance positive).
  closure,
}

/// Clause d'activation : vraie si TOUTES les portes ET TOUS les déclencheurs
/// listés sont vrais (conjonction). Une clause vide est toujours vraie.
class RadarActivationClause {
  final Set<RadarContextGate> gates;
  final Set<RadarClinicalTrigger> triggers;

  const RadarActivationClause({
    this.gates = const {},
    this.triggers = const {},
  });

  bool isSatisfied(
    Set<RadarContextGate> activeGates,
    Set<RadarClinicalTrigger> activeTriggers,
  ) => activeGates.containsAll(gates) && activeTriggers.containsAll(triggers);
}

/// Condition d'activation : disjonction de clauses (OU logique).
/// Exemple AAA lombaire : anyOf [ {P2}, {FDR cardiovasculaires} ].
class RadarActivationCondition {
  final List<RadarActivationClause> anyOf;

  const RadarActivationCondition(this.anyOf);

  /// Condition toujours vraie (questions U / RC / clôture).
  static const RadarActivationCondition always = RadarActivationCondition([
    RadarActivationClause(),
  ]);

  bool isSatisfied(
    Set<RadarContextGate> activeGates,
    Set<RadarClinicalTrigger> activeTriggers,
  ) => anyOf.any((c) => c.isSatisfied(activeGates, activeTriggers));
}

/// Un emplacement de question dans un pathway régional.
class RadarPathwaySlot {
  /// ID exact du catalogue V4 (ex. 'v4_queue_cheval_001').
  /// L'orchestrateur ne connaît QUE des IDs : le contenu, la réponse,
  /// les probabilités et les Hard Stops restent la responsabilité de V5.
  final String questionId;

  final RadarQuestionRole role;

  /// Ordre intra-pathway. Convention :
  /// 0 = fracture ouverte si porte trauma (pré-emption absolue)
  /// 1 = hard-stop régional
  /// 2-4 = socle universel
  /// 5-8 = conditionnelles
  /// 9 = clôture
  final int order;

  final RadarActivationCondition activation;

  /// Justification d'une ligne — reprise de la matrice Delphi.
  /// Sert la traçabilité inversée : « pourquoi X n'a pas été posée »
  /// doit toujours avoir une réponse versionnée.
  final String rationale;

  const RadarPathwaySlot({
    required this.questionId,
    required this.role,
    required this.order,
    this.activation = RadarActivationCondition.always,
    required this.rationale,
  });
}

/// Définition complète d'un pathway régional.
class RadarClinicalPathwayDefinition {
  final RadarClinicalRegion region;
  final List<RadarPathwaySlot> slots;

  /// DEC_REASSURE atteignable dans cette région ?
  /// false pour thoracique (point Delphi n°9) et diffus (point n°6).
  final bool reassureReachable;

  /// Diffus + porte trauma = orientation d'emblée, pas de questionnaire.
  final bool traumaTriggersImmediateOrientation;

  const RadarClinicalPathwayDefinition({
    required this.region,
    required this.slots,
    required this.reassureReachable,
    this.traumaTriggersImmediateOrientation = false,
  });

  /// Sous-ensemble ordonné des questions à poser pour un contexte donné.
  /// C'est la SEULE opération de sélection de l'orchestrateur : V5 garde
  /// la main sur tout le reste.
  List<RadarPathwaySlot> activeSlots(
    Set<RadarContextGate> gates,
    Set<RadarClinicalTrigger> triggers,
  ) {
    final active =
        slots.where((s) => s.activation.isSatisfied(gates, triggers)).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return active;
  }

  /// IDs du catalogue V4 volontairement exclus de ce pathway,
  /// avec leur justification — pour le log de session (traçabilité inversée).
  Map<String, String> excludedWithRationale(Set<String> fullCatalogIds) {
    final included = slots.map((s) => s.questionId).toSet();
    return {
      for (final id in fullCatalogIds.difference(included))
        id:
            'Exclue du pathway ${region.name} — voir matrice '
            '$kRadarPathwayMatrixVersion',
    };
  }
}
