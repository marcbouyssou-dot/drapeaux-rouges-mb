import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_region.dart';

/// Sorties possibles d'une session régionale.
/// L'orchestrateur MAPPE ces sorties vers les décisions V5 existantes
/// (DEC_REASSURE, DEC_MONITOR, avis médical, DEC_URGENT_REFERRAL) —
/// il n'en crée aucune nouvelle.
enum RadarSessionOutcome {
  /// Hard Stop V5 déclenché : priorité absolue, inchangée.
  hardStop,

  /// Un ou plusieurs drapeaux positifs sans Hard Stop :
  /// la décision reste ENTIÈREMENT celle du moteur V5.
  delegateToEngine,

  /// Diffus + trauma : orientation d'emblée (polytraumatisme),
  /// pas de questionnaire.
  immediateOrientation,

  /// Complétude régionale atteinte, tout négatif, clôture mécanique
  /// positive → DEC_REASSURE (réassurance positive).
  reassure,

  /// Complétude atteinte, tout négatif, mais clôture non atteinte ou
  /// région non rassurable (thoracique, diffus) → DEC_MONITOR.
  monitor,

  /// Diffus : DEC_MONITOR avec revoyure courte 7-10 jours
  /// + courrier au médecin traitant (« diffus inexpliqué = jamais
  /// rassuré seul en accès direct »).
  monitorWithShortFollowUpAndLetter,
}

/// État minimal que l'orchestrateur maintient pour appliquer la politique.
/// Les réponses, probabilités et Hard Stops restent dans V5 : cet état
/// ne fait que REFLÉTER ce que V5 a déjà décidé.
class RadarRegionalSessionState {
  final RadarClinicalRegion region;
  final Set<String> answeredQuestionIds;
  final Set<String> activeQuestionIds; // slots activés pour ce contexte
  final bool engineReportedHardStop; // reflet de V5
  final bool engineReportedAnyRedFlag; // reflet de V5
  final bool closureConfirmed; // au moins un item de clôture positif
  final bool traumaGateActive;

  const RadarRegionalSessionState({
    required this.region,
    required this.answeredQuestionIds,
    required this.activeQuestionIds,
    required this.engineReportedHardStop,
    required this.engineReportedAnyRedFlag,
    required this.closureConfirmed,
    required this.traumaGateActive,
  });

  /// Complétude régionale : toutes les questions ACTIVÉES sont répondues.
  /// Définition POSITIVE de l'arrêt — aucun arrêt probabiliste précoce
  /// (« suffisamment rassurant ») n'est autorisé en V1.
  bool get regionalCompletenessReached =>
      activeQuestionIds.difference(answeredQuestionIds).isEmpty;
}

/// Politique d'arrêt et de sortie.
///
/// Hiérarchie gravée (point Delphi n°10) :
/// 1. Sécurité urgente (Hard Stops V5)
/// 2. Complétude régionale
/// 3. Efficience du parcours
class RadarClinicalStopPolicy {
  const RadarClinicalStopPolicy();

  RadarSessionOutcome evaluate(
    RadarRegionalSessionState state,
    RadarClinicalPathwayDefinition pathway,
  ) {
    // 0. Diffus + trauma : orientation immédiate, avant toute question.
    if (pathway.traumaTriggersImmediateOrientation && state.traumaGateActive) {
      return RadarSessionOutcome.immediateOrientation;
    }

    // 1. Hard Stop V5 : priorité absolue, inconditionnelle.
    if (state.engineReportedHardStop) {
      return RadarSessionOutcome.hardStop;
    }

    // 2. Drapeau positif sans Hard Stop : V5 décide, l'orchestrateur
    //    ne filtre plus rien (le pathway peut être élargi par V5).
    if (state.engineReportedAnyRedFlag) {
      return RadarSessionOutcome.delegateToEngine;
    }

    // 3. Pas d'arrêt tant que la complétude régionale n'est pas atteinte.
    if (!state.regionalCompletenessReached) {
      // Sentinelle : la session continue. L'orchestrateur ne doit JAMAIS
      // interpréter cet état comme une sortie.
      throw StateError(
        'StopPolicy évaluée avant complétude régionale : '
        'interdit en V1 (pas d\'arrêt précoce).',
      );
    }

    // 4. Complétude atteinte, tout négatif.
    if (pathway.region == RadarClinicalRegion.diffuse) {
      return RadarSessionOutcome.monitorWithShortFollowUpAndLetter;
    }
    if (!pathway.reassureReachable) {
      // Thoracique en V1 : réassurance inatteignable (point Delphi n°9).
      return RadarSessionOutcome.monitor;
    }
    // Réassurance POSITIVE : absence de signes ne suffit pas,
    // il faut une explication mécanique cohérente confirmée.
    return state.closureConfirmed
        ? RadarSessionOutcome.reassure
        : RadarSessionOutcome.monitor;
  }
}
