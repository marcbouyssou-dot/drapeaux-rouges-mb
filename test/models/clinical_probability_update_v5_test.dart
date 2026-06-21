import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_catalog.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalProbabilityUpdateCatalogV5', () {
    test('contains autonomous qualitative probability updates', () {
      expect(ClinicalProbabilityUpdateCatalogV5.updates, isNotEmpty);
      expect(
        ClinicalProbabilityUpdateCatalogV5.updateIds.length,
        ClinicalProbabilityUpdateCatalogV5.updates.length,
      );
    });

    test('update ids are stable and unique', () {
      for (final update in ClinicalProbabilityUpdateCatalogV5.updates) {
        expect(update.id, startsWith('v5_probability_update_'));
      }
    });

    test('each update references a question or a flag', () {
      for (final update in ClinicalProbabilityUpdateCatalogV5.updates) {
        expect(
          update.triggerQuestionId != null || update.triggerFlagId != null,
          isTrue,
          reason: update.id,
        );
      }
    });

    test('hypothesis ids reference existing V5 hypotheses', () {
      expect(
        ClinicalHypothesisCatalogV5.hypothesisIds,
        containsAll(ClinicalProbabilityUpdateCatalogV5.hypothesisIds),
      );
    });

    test('trigger question ids reference existing V4 questions', () {
      expect(
        ClinicalScreeningQuestionnaireV4.questionIds,
        containsAll(ClinicalProbabilityUpdateCatalogV5.triggerQuestionIds),
      );
    });

    test('trigger flag ids reference existing V3 catalog flags', () {
      final catalogFlagIds = ClinicalScreeningCatalog.flagDefinitions
          .map((definition) => definition.id)
          .toSet();

      expect(
        catalogFlagIds,
        containsAll(ClinicalProbabilityUpdateCatalogV5.triggerFlagIds),
      );
    });

    test('each update has a clinical rationale', () {
      for (final update in ClinicalProbabilityUpdateCatalogV5.updates) {
        expect(update.clinicalRationale.trim(), isNotEmpty, reason: update.id);
      }
    });

    test('positive impacts do not lower qualitative probability', () {
      for (final update in ClinicalProbabilityUpdateCatalogV5.updates) {
        if (update.impact == ClinicalProbabilityImpactV5.increase ||
            update.impact == ClinicalProbabilityImpactV5.strongIncrease) {
          expect(
            _rank(update.updatedProbability),
            greaterThanOrEqualTo(_rank(update.priorProbability)),
            reason: update.id,
          );
        }
      }
    });

    test('strong increases produce high or very high probability', () {
      for (final update in ClinicalProbabilityUpdateCatalogV5.updates.where(
        (update) => update.impact == ClinicalProbabilityImpactV5.strongIncrease,
      )) {
        expect(
          {
            ClinicalQualitativeProbabilityV5.high,
            ClinicalQualitativeProbabilityV5.veryHigh,
          },
          contains(update.updatedProbability),
          reason: update.id,
        );
      }
    });

    test('core hypotheses have probability updates', () {
      expect(
        ClinicalProbabilityUpdateCatalogV5.hypothesisIds,
        containsAll({
          'v5_hypothesis_queue_cheval',
          'v5_hypothesis_embolie_pulmonaire',
          'v5_hypothesis_fracture_ouverte',
          'v5_hypothesis_pathologie_oncologique',
          'v5_hypothesis_infection_systemique_fragile',
          'v5_hypothesis_atteinte_neurologique_progressive',
          'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
          'v5_hypothesis_fracture_fragilite',
          'v5_hypothesis_tvp',
        }),
      );
    });

    test('cauda equina update reaches very high probability', () {
      final updates = ClinicalProbabilityUpdateCatalogV5.updatesForHypothesis(
        'v5_hypothesis_queue_cheval',
      );

      expect(updates, hasLength(1));
      expect(
        updates.single.updatedProbability,
        ClinicalQualitativeProbabilityV5.veryHigh,
      );
    });

    test('cardiorespiratory update reaches very high probability', () {
      final updates = ClinicalProbabilityUpdateCatalogV5.updatesForHypothesis(
        'v5_hypothesis_syndrome_cardiorespiratoire_aigu',
      );

      expect(updates, hasLength(1));
      expect(
        updates.single.updatedProbability,
        ClinicalQualitativeProbabilityV5.veryHigh,
      );
    });

    test('vascular update remains qualitative and non numeric', () {
      final updates = ClinicalProbabilityUpdateCatalogV5.updatesForHypothesis(
        'v5_hypothesis_tvp',
      );

      expect(updates, hasLength(1));
      expect(
        updates.single.priorProbability,
        isA<ClinicalQualitativeProbabilityV5>(),
      );
      expect(
        updates.single.updatedProbability,
        ClinicalQualitativeProbabilityV5.high,
      );
    });
  });
}

int _rank(ClinicalQualitativeProbabilityV5 probability) {
  return ClinicalQualitativeProbabilityV5.values.indexOf(probability);
}
