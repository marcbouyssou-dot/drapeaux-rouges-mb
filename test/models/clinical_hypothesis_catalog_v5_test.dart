import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hypothesis_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_catalog.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalHypothesisCatalogV5', () {
    test('contains autonomous diagnostic hypotheses', () {
      expect(ClinicalHypothesisCatalogV5.hypotheses, isNotEmpty);
      expect(
        ClinicalHypothesisCatalogV5.hypothesisIds.length,
        ClinicalHypothesisCatalogV5.hypotheses.length,
      );
    });

    test('hypothesis ids are stable and unique', () {
      for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses) {
        expect(hypothesis.id, startsWith('v5_hypothesis_'));
      }
    });

    test('each hypothesis has clinical metadata', () {
      for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses) {
        expect(hypothesis.title.trim(), isNotEmpty, reason: hypothesis.id);
        expect(
          hypothesis.clinicalDescription.trim(),
          isNotEmpty,
          reason: hypothesis.id,
        );
        expect(
          hypothesis.associatedClusterIds,
          isNotEmpty,
          reason: hypothesis.id,
        );
        expect(hypothesis.associatedFlagIds, isNotEmpty, reason: hypothesis.id);
        expect(hypothesis.scientificSources, isNotEmpty, reason: hypothesis.id);
        expect(hypothesis.validationCaseIds, isNotEmpty, reason: hypothesis.id);
      }
    });

    test('associated flags reference existing V3 catalog flags', () {
      final catalogFlagIds = ClinicalScreeningCatalog.flagDefinitions
          .map((definition) => definition.id)
          .toSet();

      expect(
        catalogFlagIds,
        containsAll(ClinicalHypothesisCatalogV5.associatedFlagIds),
      );
    });

    test('associated clusters reference V4 rules or V5 hard stop clusters', () {
      final knownClusterIds = {
        ...ClinicalScreeningQuestionnaireV4.referencedRuleIds,
        ...ClinicalHardStopCatalogV5.clusterIds,
      };

      expect(
        knownClusterIds,
        containsAll(ClinicalHypothesisCatalogV5.associatedClusterIds),
      );
    });

    test('target decision levels remain clinically meaningful', () {
      for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses) {
        expect(
          {
            ClinicalDecisionLevel.medicalAdvice,
            ClinicalDecisionLevel.urgentReferral,
            ClinicalDecisionLevel.emergency,
          },
          contains(hypothesis.targetDecisionLevel),
          reason: hypothesis.id,
        );
      }
    });

    test('life threatening hypotheses target emergency', () {
      final lifeThreatening = ClinicalHypothesisCatalogV5.hypotheses.where(
        (hypothesis) =>
            hypothesis.severity ==
            ClinicalHypothesisSeverityV5.potentiallyLifeThreatening,
      );

      for (final hypothesis in lifeThreatening) {
        expect(
          hypothesis.targetDecisionLevel,
          ClinicalDecisionLevel.emergency,
          reason: hypothesis.id,
        );
      }
    });

    test('major validation cases are represented', () {
      expect(
        ClinicalHypothesisCatalogV5.validationCaseIds,
        containsAll({
          'HS_CAUDA_001',
          'HS_CARDIO_001',
          'HS_ONCO_001',
          'HS_TVP_001',
        }),
      );
    });

    test('core diagnostic hypotheses are represented', () {
      expect(
        ClinicalHypothesisCatalogV5.hypothesisIds,
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

    test('hypothesesForCluster filters hypotheses by cluster', () {
      final vascularHypotheses =
          ClinicalHypothesisCatalogV5.hypothesesForCluster('vascularCluster');

      expect(vascularHypotheses, hasLength(1));
      expect(vascularHypotheses.single.id, 'v5_hypothesis_tvp');
    });
  });
}
