import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_catalog.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_question_v4.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalHardStopCatalogV5 consistency', () {
    test('each trigger question id exists in the V4 questionnaire', () {
      expect(
        ClinicalScreeningQuestionnaireV4.questionIds,
        containsAll(ClinicalHardStopCatalogV5.triggeringQuestionIds),
      );
    });

    test('each trigger flag id is covered by at least one V4 question', () {
      for (final rule in ClinicalHardStopCatalogV5.rules) {
        for (final flagId in rule.triggeringFlagIds) {
          expect(
            _v4QuestionsCoverFlag(flagId),
            isTrue,
            reason: '${rule.id} references $flagId',
          );
        }
      }
    });

    test('each validation case id is not empty', () {
      for (final rule in ClinicalHardStopCatalogV5.rules) {
        expect(rule.validationCaseId.trim(), isNotEmpty, reason: rule.id);
      }
    });

    test('each emergency hard stop has at least two triggers', () {
      for (final rule in ClinicalHardStopCatalogV5.rules.where(_isEmergency)) {
        final triggerCount =
            rule.triggeringQuestionIds.length + rule.triggeringFlagIds.length;

        expect(triggerCount, greaterThanOrEqualTo(2), reason: rule.id);
      }
    });

    test('validation cases reference existing V5 hard stops', () {
      for (final validationCase in _clinicalValidationCases) {
        expect(
          ClinicalHardStopCatalogV5.hardStopIds,
          contains(validationCase.hardStopRuleId),
          reason: validationCase.id,
        );
      }
    });

    test('HS_CAUDA_001 triggers emergency', () {
      expect(_decisionForValidationCase('HS_CAUDA_001'), isEmergencyDecision);
    });

    test('HS_CARDIO_001 triggers emergency', () {
      expect(_decisionForValidationCase('HS_CARDIO_001'), isEmergencyDecision);
    });

    test('HS_ONCO_001 triggers urgent referral', () {
      expect(_decisionForValidationCase('HS_ONCO_001'), isUrgentReferral);
    });

    test('HS_TVP_001 triggers urgent referral', () {
      expect(_decisionForValidationCase('HS_TVP_001'), isUrgentReferral);
    });
  });
}

const isEmergencyDecision = ClinicalDecisionLevel.emergency;
const isUrgentReferral = ClinicalDecisionLevel.urgentReferral;

const _clinicalValidationCases = [
  _ClinicalHardStopValidationCase(
    id: 'HS_CAUDA_001',
    hardStopRuleId: 'v5_hard_stop_queue_cheval',
    expectedDecisionLevel: ClinicalDecisionLevel.emergency,
  ),
  _ClinicalHardStopValidationCase(
    id: 'HS_CARDIO_001',
    hardStopRuleId: 'v5_hard_stop_cardiorespiratoire',
    expectedDecisionLevel: ClinicalDecisionLevel.emergency,
  ),
  _ClinicalHardStopValidationCase(
    id: 'HS_ONCO_001',
    hardStopRuleId: 'v5_hard_stop_oncologique',
    expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
  ),
  _ClinicalHardStopValidationCase(
    id: 'HS_TVP_001',
    hardStopRuleId: 'v5_hard_stop_vasculaire_tvp',
    expectedDecisionLevel: ClinicalDecisionLevel.urgentReferral,
  ),
];

bool _isEmergency(ClinicalHardStopRuleV5 rule) {
  return rule.expectedDecisionLevel == ClinicalDecisionLevel.emergency;
}

bool _v4QuestionsCoverFlag(String flagId) {
  final flagDefinition = _flagDefinitionById(flagId);

  return ClinicalScreeningQuestionnaireV4.questions.any((question) {
    if (question.associatedFlagId == flagId) {
      return true;
    }

    if (flagDefinition == null) {
      return false;
    }

    return _sharesTag(question, flagDefinition.tags);
  });
}

ClinicalDecisionLevel _decisionForValidationCase(String validationCaseId) {
  final validationCase = _clinicalValidationCases.singleWhere(
    (validationCase) => validationCase.id == validationCaseId,
  );
  final rule = ClinicalHardStopCatalogV5.rules.singleWhere(
    (rule) => rule.id == validationCase.hardStopRuleId,
  );

  expect(
    rule.expectedDecisionLevel,
    validationCase.expectedDecisionLevel,
    reason: validationCase.id,
  );

  return rule.expectedDecisionLevel;
}

ClinicalFlagDefinition? _flagDefinitionById(String flagId) {
  for (final flagDefinition in ClinicalScreeningCatalog.flagDefinitions) {
    if (flagDefinition.id == flagId) {
      return flagDefinition;
    }
  }

  return null;
}

bool _sharesTag(ClinicalScreeningQuestionV4 question, List<String> flagTags) {
  return question.tags.any(flagTags.contains);
}

class _ClinicalHardStopValidationCase {
  final String id;
  final String hardStopRuleId;
  final ClinicalDecisionLevel expectedDecisionLevel;

  const _ClinicalHardStopValidationCase({
    required this.id,
    required this.hardStopRuleId,
    required this.expectedDecisionLevel,
  });
}
