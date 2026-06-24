import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_catalog.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalHardStopCatalogV5', () {
    test('contains autonomous hard stop rules', () {
      expect(ClinicalHardStopCatalogV5.rules, isNotEmpty);
      expect(ClinicalHardStopCatalogV5.hardStopIds.length, greaterThan(0));
    });

    test('hard stop ids are stable and unique', () {
      expect(
        ClinicalHardStopCatalogV5.hardStopIds.length,
        ClinicalHardStopCatalogV5.rules.length,
      );

      for (final rule in ClinicalHardStopCatalogV5.rules) {
        expect(rule.id, startsWith('v5_hard_stop_'));
      }
    });

    test('each hard stop has clinical content and validation metadata', () {
      for (final rule in ClinicalHardStopCatalogV5.rules) {
        expect(rule.title.trim(), isNotEmpty, reason: rule.id);
        expect(rule.clinicalDescription.trim(), isNotEmpty, reason: rule.id);
        expect(rule.clinicalRationale.trim(), isNotEmpty, reason: rule.id);
        expect(rule.validationCaseId.trim(), isNotEmpty, reason: rule.id);
        expect(rule.triggeringQuestionIds, isNotEmpty, reason: rule.id);
        expect(rule.triggeringFlagIds, isNotEmpty, reason: rule.id);
        expect(rule.scientificSources, isNotEmpty, reason: rule.id);
      }
    });

    test('triggering question ids reference existing V4 questions', () {
      expect(
        ClinicalScreeningQuestionnaireV4.questionIds,
        containsAll(ClinicalHardStopCatalogV5.triggeringQuestionIds),
      );
    });

    test('triggering flag ids reference existing V3 catalog flags', () {
      final catalogFlagIds = ClinicalScreeningCatalog.flagDefinitions
          .map((definition) => definition.id)
          .toSet();

      expect(
        catalogFlagIds,
        containsAll(ClinicalHardStopCatalogV5.triggeringFlagIds),
      );
    });

    test('clusters reference known V4 rule ids', () {
      expect(
        ClinicalScreeningQuestionnaireV4.referencedRuleIds,
        containsAll(ClinicalHardStopCatalogV5.clusterIds),
      );
    });

    test('expected decision levels are hard-stop compatible', () {
      for (final rule in ClinicalHardStopCatalogV5.rules) {
        expect(
          {
            ClinicalDecisionLevel.urgentReferral,
            ClinicalDecisionLevel.emergency,
          },
          contains(rule.expectedDecisionLevel),
          reason: rule.id,
        );
      }
    });

    test('hard stop states are explicit and clinically compatible', () {
      final cauda = ClinicalHardStopCatalogV5.ruleById(
        'v5_hard_stop_queue_cheval',
      );
      final cervical = ClinicalHardStopCatalogV5.ruleById(
        'v5_hard_stop_cervical_vasculaire',
      );
      final aaa = ClinicalHardStopCatalogV5.ruleById(
        'v5_hard_stop_aaa_vasculaire_abdominal',
      );

      expect(cauda?.state, ClinicalHardStopStateV5.confirmed);
      expect(cervical?.state, ClinicalHardStopStateV5.suspected);
      expect(aaa?.state, ClinicalHardStopStateV5.suspected);

      for (final rule in ClinicalHardStopCatalogV5.rules.where(
        (rule) => rule.state == ClinicalHardStopStateV5.confirmed,
      )) {
        expect(
          {
            ClinicalDecisionLevel.urgentReferral,
            ClinicalDecisionLevel.emergency,
          },
          contains(rule.expectedDecisionLevel),
          reason: rule.id,
        );
      }
    });

    test('universal immediate danger hard stops are represented', () {
      expect(
        ClinicalHardStopCatalogV5.hardStopIds,
        containsAll({
          'v5_hard_stop_queue_cheval',
          'v5_hard_stop_embolie_pulmonaire',
          'v5_hard_stop_fracture_ouverte',
          'v5_hard_stop_cardiorespiratoire',
        }),
      );
    });

    test('rulesForCluster filters hard stops by cluster', () {
      final vascularRules = ClinicalHardStopCatalogV5.rulesForCluster(
        'vascularCluster',
      );

      expect(vascularRules, hasLength(1));
      expect(vascularRules.single.id, 'v5_hard_stop_vasculaire_tvp');
    });
  });
}
