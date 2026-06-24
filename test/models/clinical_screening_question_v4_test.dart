import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_question_v4.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_questionnaire_v4.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_script_v7.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalScreeningQuestionnaireV4', () {
    test('contains clinical questions and sources', () {
      expect(ClinicalScreeningQuestionnaireV4.questions, isNotEmpty);
      expect(ClinicalScreeningQuestionnaireV4.sources, isNotEmpty);
    });

    test('each question has stable identifiers and clinical metadata', () {
      for (final question in ClinicalScreeningQuestionnaireV4.questions) {
        expect(question.id.trim(), isNotEmpty);
        expect(question.text.trim(), isNotEmpty);
        expect(question.clinicalIntent.trim(), isNotEmpty);
        expect(question.associatedFlagId.trim(), isNotEmpty);
        expect(question.clusterId.trim(), isNotEmpty);
        expect(question.ruleId.trim(), isNotEmpty);
        expect(question.targetResponseTime.inSeconds, greaterThan(0));
        expect(question.tags, isNotEmpty);
        expect(question.scientificSources, isNotEmpty);
      }
    });

    test('question ids are unique', () {
      expect(
        ClinicalScreeningQuestionnaireV4.questionIds.length,
        ClinicalScreeningQuestionnaireV4.questions.length,
      );
    });

    test('questions expose explicit V7 clinical scripts', () {
      final scriptIds = ClinicalScreeningQuestionnaireV4.questions
          .map((question) => question.scriptId)
          .whereType<String>()
          .toSet();

      expect(
        ClinicalScriptIdsV7.all,
        containsAll({
          ClinicalScriptIdsV7.oncologique,
          ClinicalScriptIdsV7.infectieux,
          ClinicalScriptIdsV7.fracture,
          ClinicalScriptIdsV7.neurologique,
          ClinicalScriptIdsV7.queueDeCheval,
          ClinicalScriptIdsV7.vasculaire,
          ClinicalScriptIdsV7.cervicalVasculaire,
          ClinicalScriptIdsV7.aaaVasculaireAbdominal,
        }),
      );
      expect(
        scriptIds,
        containsAll({
          ClinicalScriptIdsV7.oncologique,
          ClinicalScriptIdsV7.infectieux,
          ClinicalScriptIdsV7.fracture,
          ClinicalScriptIdsV7.neurologique,
          ClinicalScriptIdsV7.queueDeCheval,
          ClinicalScriptIdsV7.vasculaire,
          ClinicalScriptIdsV7.cervicalVasculaire,
          ClinicalScriptIdsV7.aaaVasculaireAbdominal,
        }),
      );
      expect(
        ClinicalScriptIdsV7.all,
        containsAll({
          ClinicalScriptIdsV7.mecanique,
          ClinicalScriptIdsV7.psychosocial,
        }),
      );
    });

    test('psychosocial questions expose stable V7 levels', () {
      final psychosocialQuestions = ClinicalScreeningQuestionnaireV4.questions
          .where(
            (question) => question.scriptId == ClinicalScriptIdsV7.psychosocial,
          )
          .toList();

      expect(psychosocialQuestions, isNotEmpty);
      expect(
        psychosocialQuestions.map((question) => question.psychosocialLevel),
        containsAll(ClinicalPsychosocialLevelsV7.all),
      );
      expect(
        psychosocialQuestions.every(
          (question) =>
              question.potentialDecisionLevel ==
                  ClinicalDecisionLevel.routine &&
              question.ruleId == 'yellowFlagsOnly',
        ),
        isTrue,
      );
    });

    test('questions reference existing V3 catalog flags and rules', () {
      expect(
        ClinicalScreeningQuestionnaireV4.catalogFlagIds,
        containsAll(ClinicalScreeningQuestionnaireV4.referencedFlagIds),
      );
      expect(
        ClinicalScreeningQuestionnaireV4.catalogRuleIds,
        containsAll(ClinicalScreeningQuestionnaireV4.referencedRuleIds),
      );
    });

    test('covers the main V3 clinical clusters', () {
      expect(
        ClinicalScreeningQuestionnaireV4.referencedRuleIds,
        containsAll({
          'immediateDanger',
          'oncologicCluster',
          'infectiousCluster',
          'neurologicCluster',
          'cardiorespiratoryCluster',
          'fractureRiskCluster',
          'vascularCluster',
        }),
      );
    });

    test('questionsForRule filters by rule id', () {
      final questions = ClinicalScreeningQuestionnaireV4.questionsForRule(
        'oncologicCluster',
      );

      expect(questions, isNotEmpty);
      expect(
        questions.every((question) => question.ruleId == 'oncologicCluster'),
        isTrue,
      );
    });

    test('urgent questions expose appropriate potential decision levels', () {
      final emergencyQuestions = ClinicalScreeningQuestionnaireV4.questions
          .where(
            (question) =>
                question.potentialDecisionLevel ==
                ClinicalDecisionLevel.emergency,
          )
          .toList();

      expect(emergencyQuestions, isNotEmpty);
      expect(
        emergencyQuestions.every(
          (question) =>
              question.layer == ClinicalScreeningLayer.immediateDanger ||
              question.ruleId == 'cardiorespiratoryCluster',
        ),
        isTrue,
      );
    });

    test('supports explicit scientific evidence levels', () {
      expect(
        ClinicalScreeningQuestionnaireV4.questions.map(
          (question) => question.evidenceLevel,
        ),
        contains(ClinicalEvidenceLevel.clinicalGuideline),
      );
      expect(
        ClinicalScreeningQuestionnaireV4.questions.map(
          (question) => question.evidenceLevel,
        ),
        contains(ClinicalEvidenceLevel.validatedClinicalRule),
      );
    });
  });
}
