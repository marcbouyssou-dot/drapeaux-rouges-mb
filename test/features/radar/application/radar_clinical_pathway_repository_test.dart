import 'package:flutter_test/flutter_test.dart';

// TODO(codex): adapter les imports au nom de package réel du projet.
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_repository.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';

/// Invariants de sécurité de la matrice V0.1.
/// Ces tests protègent le CONTENU clinique : toute modification de la
/// matrice qui les casse doit provenir d'un tour de Delphi consolidé.
void main() {
  final repo = RadarClinicalPathwayRepository();

  group('Statut expérimental', () {
    test('la version et le mode expérimental sont explicites', () {
      expect(kRadarPathwayMatrixVersion, '0.1-experimental');
      expect(kRadarPathwayClinicalValidationStatus, 'NON VALIDÉE');
      expect(RadarClinicalOperatingMode.experimental.name, 'experimental');
    });
  });

  group('Compatibilité catalogue V4', () {
    test('tous les IDs Radar existent dans le catalogue V4 réel', () {
      final catalogIds = ClinicalScreeningQuestionnaireV4.questionIds;
      final radarIds = repo.all
          .expand((pathway) => pathway.slots)
          .map((slot) => slot.questionId)
          .toSet();

      expect(catalogIds, containsAll(radarIds));
      expect(
        RadarClinicalPathwayRepository.screeningCatalogIds,
        everyElement(isIn(catalogIds)),
      );
    });
  });

  group('Socle universel — plancher de sensibilité', () {
    test('les 3 questions universelles figurent dans les 9 pathways, '
        'sans condition d\'activation', () {
      const universals = {
        'v4_oncologic_context_001',
        'v4_infectious_fragility_001',
        'v4_neurologic_deficit_001',
      };
      for (final pathway in repo.all) {
        for (final id in universals) {
          final slot = pathway.slots.where((s) => s.questionId == id).toList();
          expect(
            slot,
            hasLength(1),
            reason: '$id manquant en ${pathway.region}',
          );
          expect(
            slot.single.activation.isSatisfied(const {}, const {}),
            isTrue,
            reason:
                '$id ne doit porter AUCUNE condition '
                'en ${pathway.region}',
          );
        }
      }
    });
  });

  group('Hard-stops régionaux en tête de parcours', () {
    test('queue de cheval est en position 1 du pathway lombaire', () {
      final active = repo
          .pathwayFor(RadarClinicalRegion.lumbar)
          .activeSlots(const {}, const {});
      expect(active.first.questionId, 'v4_queue_cheval_001');
    });

    test('cervico-vasculaire est en position 1 du pathway cervical', () {
      final active = repo
          .pathwayFor(RadarClinicalRegion.cervical)
          .activeSlots(const {}, const {});
      expect(active.first.questionId, 'v4_cervical_vascular_001');
    });

    test('fracture ouverte pré-empte tout si porte trauma', () {
      for (final region in RadarClinicalRegion.values) {
        if (region == RadarClinicalRegion.diffuse) continue; // orientation
        final active = repo.pathwayFor(region).activeSlots(const {
          RadarContextGate.trauma,
        }, const {});
        expect(
          active.first.questionId,
          'v4_fracture_ouverte_001',
          reason: 'position 0 attendue en ${region.name}',
        );
      }
    });
  });

  group('Exclusions votées — confiance du terrain', () {
    test('aucune question cervicale en lombalgie simple', () {
      final ids = repo
          .pathwayFor(RadarClinicalRegion.lumbar)
          .activeSlots(const {}, const {})
          .map((s) => s.questionId);
      expect(ids, isNot(contains('v4_cervical_vascular_001')));
    });

    test('aucune question TVP en lombalgie', () {
      final ids = repo
          .pathwayFor(RadarClinicalRegion.lumbar)
          .activeSlots(const {}, const {})
          .map((s) => s.questionId);
      expect(ids, isNot(contains('v4_vascular_tvp_001')));
    });

    test('aucune question thoracique en cervicalgie sans déclencheur', () {
      final ids = repo
          .pathwayFor(RadarClinicalRegion.cervical)
          .activeSlots(const {}, const {})
          .map((s) => s.questionId);
      expect(ids, isNot(contains('v4_cardiorespiratory_001')));
      expect(ids, isNot(contains('v4_embolie_pulmonaire_001')));
    });

    test('les yellow flags sont absents de tous les pathways', () {
      const psycho = [
        'v4_psychosocial_catastrophizing_001',
        'v4_psychosocial_fear_movement_001',
        'v4_psychosocial_anxiety_001',
        'v4_psychosocial_disproportionate_impact_001',
      ];
      for (final pathway in repo.all) {
        final ids = pathway.slots.map((s) => s.questionId);
        for (final p in psycho) {
          expect(
            ids,
            isNot(contains(p)),
            reason:
                '$p interdit en ${pathway.region} '
                '(module pronostic séparé)',
          );
        }
      }
    });
  });

  group('Conditionnelles — activation par portes et déclencheurs', () {
    test('AAA activé en lombaire par âge/fragilité OU FDR cardiovasculaires,'
        ' absent sinon', () {
      final pathway = repo.pathwayFor(RadarClinicalRegion.lumbar);
      final young = pathway.activeSlots(const {}, const {});
      expect(
        young.map((s) => s.questionId),
        isNot(contains('v4_aaa_vascular_abdominal_001')),
      );

      final older = pathway.activeSlots(const {
        RadarContextGate.ageOrBoneFragility,
      }, const {});
      expect(
        older.map((s) => s.questionId),
        contains('v4_aaa_vascular_abdominal_001'),
      );

      final fdr = pathway.activeSlots(const {}, const {
        RadarClinicalTrigger.cardiovascularRiskFactors,
      });
      expect(
        fdr.map((s) => s.questionId),
        contains('v4_aaa_vascular_abdominal_001'),
      );
    });

    test(
      'queue de cheval rouverte en hanche par composante lombo-pelvienne',
      () {
        final pathway = repo.pathwayFor(
          RadarClinicalRegion.hipLowerLimbProximal,
        );
        final without = pathway.activeSlots(const {}, const {});
        expect(
          without.map((s) => s.questionId),
          isNot(contains('v4_queue_cheval_001')),
        );

        final withComponent = pathway.activeSlots(const {}, const {
          RadarClinicalTrigger.lumbopelvicComponent,
        });
        expect(
          withComponent.map((s) => s.questionId),
          contains('v4_queue_cheval_001'),
        );
      },
    );
  });

  group('Cible de brièveté — cas simples', () {
    test('CAS_01 régional : lombalgie simple < 50 ans sans trauma '
        '= 7 questions maximum', () {
      final active = repo
          .pathwayFor(RadarClinicalRegion.lumbar)
          .activeSlots(const {}, const {});
      // 1 queue de cheval + 3 socle + 3 clôture = 7 (au lieu de 19).
      expect(active.length, lessThanOrEqualTo(8));
      expect(active.length, greaterThanOrEqualTo(5));
    });

    test('membre distal simple : 4 à 7 questions', () {
      for (final region in [
        RadarClinicalRegion.upperLimbDistal,
        RadarClinicalRegion.ankleFoot,
      ]) {
        final active = repo.pathwayFor(region).activeSlots(const {}, const {});
        expect(active.length, inInclusiveRange(4, 7), reason: region.name);
      }
    });
  });

  group('Régions non rassurables en V1', () {
    test('thoracique et diffus : reassureReachable = false', () {
      expect(
        repo.pathwayFor(RadarClinicalRegion.thoracic).reassureReachable,
        isFalse,
      );
      expect(
        repo.pathwayFor(RadarClinicalRegion.diffuse).reassureReachable,
        isFalse,
      );
      // Toutes les autres régions restent rassurables.
      for (final p in repo.all) {
        if (p.region != RadarClinicalRegion.thoracic &&
            p.region != RadarClinicalRegion.diffuse) {
          expect(p.reassureReachable, isTrue, reason: p.region.name);
        }
      }
    });

    test('diffus : aucune clôture mécanique dans le pathway', () {
      final ids = repo
          .pathwayFor(RadarClinicalRegion.diffuse)
          .slots
          .map((s) => s.questionId);
      expect(ids, isNot(contains('v4_mechanical_pattern_001')));
      expect(ids, isNot(contains('v4_mechanical_overload_001')));
      expect(ids, isNot(contains('v4_known_stable_mechanical_episode_001')));
    });
  });
}
