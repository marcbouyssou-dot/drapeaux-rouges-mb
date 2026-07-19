import 'package:flutter_test/flutter_test.dart';

// TODO(codex): adapter les imports au nom de package réel du projet.
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_repository.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_stop_policy.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_regional_clinical_orchestrator.dart';

void main() {
  group('Orchestrateur — déroulé de session', () {
    test('diffus + trauma = orientation d\'emblée, aucune question', () {
      final orch = RadarRegionalClinicalOrchestrator();
      final outcome = orch.startSession(
        region: RadarClinicalRegion.diffuse,
        gates: const {RadarContextGate.trauma},
      );
      expect(outcome, RadarSessionOutcome.immediateOrientation);
    });

    test('lombalgie simple : le parcours s\'épuise en <= 8 questions '
        'et termine en reassure si clôture confirmée', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(region: RadarClinicalRegion.lumbar, gates: const {});

      var count = 0;
      String? id;
      final asked = <String>[];
      while ((id = orch.nextQuestionId()) != null) {
        final questionId = id!;
        asked.add(questionId);
        orch.onQuestionAnswered(questionId);
        count++;
        expect(
          count,
          lessThanOrEqualTo(8),
          reason: 'boucle de sécurité — parcours trop long : $asked',
        );
      }
      expect(asked.first, 'v4_queue_cheval_001');

      final outcome = orch.evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: false,
        closureConfirmed: true,
      );
      expect(outcome, RadarSessionOutcome.reassure);
    });

    test('tout négatif SANS clôture mécanique = monitor, jamais reassure '
        '(réassurance positive)', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(region: RadarClinicalRegion.lumbar, gates: const {});
      String? id;
      while ((id = orch.nextQuestionId()) != null) {
        final questionId = id!;
        orch.onQuestionAnswered(questionId);
      }
      final outcome = orch.evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: false,
        closureConfirmed: false,
      );
      expect(outcome, RadarSessionOutcome.monitor);
    });

    test('Hard Stop V5 prioritaire sur tout, à tout moment', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(region: RadarClinicalRegion.lumbar, gates: const {});
      orch.onQuestionAnswered('v4_queue_cheval_001');
      final outcome = orch.evaluateOutcome(
        engineReportedHardStop: true,
        engineReportedAnyRedFlag: true,
        closureConfirmed: false,
      );
      expect(outcome, RadarSessionOutcome.hardStop);
    });

    test('flag rouge sans Hard Stop = délégation totale à V5', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(region: RadarClinicalRegion.lumbar, gates: const {});
      orch.onQuestionAnswered('v4_queue_cheval_001');
      final outcome = orch.evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: true,
        closureConfirmed: false,
      );
      expect(outcome, RadarSessionOutcome.delegateToEngine);
    });

    test('déclencheur révélé en cours de session rouvre une conditionnelle '
        '(hanche → composante lombo-pelvienne → queue de cheval)', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(
        region: RadarClinicalRegion.hipLowerLimbProximal,
        gates: const {},
      );
      final first = orch.nextQuestionId()!;
      orch.onQuestionAnswered(
        first,
        newTriggers: const {RadarClinicalTrigger.lumbopelvicComponent},
      );
      // Après réévaluation, queue de cheval doit apparaître dans le parcours.
      final remaining = <String>[];
      String? id;
      while ((id = orch.nextQuestionId()) != null) {
        final questionId = id!;
        remaining.add(questionId);
        orch.onQuestionAnswered(questionId);
      }
      expect(remaining, contains('v4_queue_cheval_001'));
    });

    test('diffus tout négatif = monitor + revoyure + courrier, '
        'jamais reassure', () {
      final orch = RadarRegionalClinicalOrchestrator();
      orch.startSession(region: RadarClinicalRegion.diffuse, gates: const {});
      String? id;
      while ((id = orch.nextQuestionId()) != null) {
        final questionId = id!;
        orch.onQuestionAnswered(questionId);
      }
      final outcome = orch.evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: false,
        closureConfirmed: false,
      );
      expect(outcome, RadarSessionOutcome.monitorWithShortFollowUpAndLetter);
    });
  });

  group('StopPolicy — interdiction de l\'arrêt précoce', () {
    test('évaluer avant complétude régionale lève une StateError', () {
      final repo = RadarClinicalPathwayRepository();
      final pathway = repo.pathwayFor(RadarClinicalRegion.lumbar);
      const policy = RadarClinicalStopPolicy();
      final state = RadarRegionalSessionState(
        region: RadarClinicalRegion.lumbar,
        answeredQuestionIds: const {'v4_queue_cheval_001'},
        activeQuestionIds: pathway
            .activeSlots(const {}, const {})
            .map((s) => s.questionId)
            .toSet(),
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: false,
        closureConfirmed: false,
        traumaGateActive: false,
      );
      expect(() => policy.evaluate(state, pathway), throwsA(isA<StateError>()));
    });
  });

  // ------------------------------------------------------------------
  // TODO(codex) — tests d'intégration à écrire APRÈS câblage V5,
  //               dans un fichier séparé, sans modifier V5 :
  // - CAS_01 rejoué via l'orchestrateur : décision routine, <= 8 questions.
  // - CAS_FN V7 rejoués via l'orchestrateur : restent NON rassurés
  //   (le raccourcissement ne doit dégrader AUCUN faux négatif connu).
  // - Hard Stop queue de cheval détecté via l'orchestrateur en lombaire.
  // - Hard Stop AAA détecté en lombaire quand la condition est active.
  // - Yellow flags seuls ne produisent jamais rouge (inchangé).
  // ------------------------------------------------------------------
}
