import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_catalog.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_rule_version.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_tags.dart';
import 'package:drapeaux_rouges_mb/services/clinical_screening_engine_v3.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalScreeningEngineV3', () {
    const engine = ClinicalScreeningEngineV3();
    final createdAt = DateTime(2026, 1, 1);

    ClinicalScreeningSession evaluate(List<ClinicalFlag> flags) {
      return engine.evaluate(
        sessionId: 'session-test',
        reason: 'Bilan clinique',
        createdAt: createdAt,
        flags: flags,
      );
    }

    ClinicalFlag flag({
      required String id,
      String? label,
      ClinicalFlagCategory category = ClinicalFlagCategory.general,
      ClinicalDecisionLevel level = ClinicalDecisionLevel.monitor,
      ClinicalScreeningLayer layer = ClinicalScreeningLayer.regional,
      List<String> tags = const [],
      int weight = 1,
      bool isPresent = true,
    }) {
      return ClinicalFlag(
        id: id,
        label: label ?? id,
        category: category,
        level: level,
        layer: layer,
        tags: tags,
        weight: weight,
        isPresent: isPresent,
      );
    }

    test('returns routine action when no clinical flag is present', () {
      final session = engine.evaluate(
        sessionId: 'session-1',
        patientId: 'patient-1',
        reason: 'Bilan initial',
        createdAt: createdAt,
        flags: const [],
      );

      expect(session.id, 'session-1');
      expect(session.patientId, 'patient-1');
      expect(session.reason, 'Bilan initial');
      expect(session.createdAt, createdAt);
      expect(session.score, 0);
      expect(session.presentFlags, isEmpty);
      expect(session.hasPresentFlags, isFalse);
      expect(session.decisionLevel, ClinicalDecisionLevel.routine);
      expect(session.recommendedAction.title, 'Prise en charge habituelle');
      expect(session.recommendedAction.requiresMedicalContact, isFalse);
      expect(session.recommendedAction.requiresEmergencyCall, isFalse);
      expect(session.traces, hasLength(1));
      expect(session.traces.single.ruleId, 'routine');
      expect(session.traces.single.causalFlagIds, isEmpty);
      expect(session.engineVersion, ClinicalScreeningRuleVersion.engineVersion);
      expect(
        session.rulesetVersion,
        ClinicalScreeningRuleVersion.rulesetVersion,
      );
      expect(session.rulesetDate, ClinicalScreeningRuleVersion.rulesetDate);
      expect(
        session.clinicalStatus,
        ClinicalScreeningRuleVersion.clinicalStatus,
      );
      expect(
        session.traces.single.rulesetVersion,
        ClinicalScreeningRuleVersion.rulesetVersion,
      );
    });

    test('version values are stable and centralized', () {
      expect(
        ClinicalScreeningRuleVersion.engineName,
        'ClinicalScreeningEngineV3',
      );
      expect(ClinicalScreeningRuleVersion.engineVersion, '3.0.0');
      expect(ClinicalScreeningRuleVersion.rulesetVersion, '2026.06-v1');
      expect(ClinicalScreeningRuleVersion.rulesetDate, '2026-06-19');
      expect(
        ClinicalScreeningRuleVersion.clinicalStatus,
        'experimental_not_clinically_validated',
      );
    });

    test('clinical catalog is not empty', () {
      expect(ClinicalScreeningCatalog.flagDefinitions, isNotEmpty);
      expect(ClinicalScreeningCatalog.tagDefinitions, isNotEmpty);
      expect(ClinicalScreeningCatalog.ruleDefinitions, isNotEmpty);
    });

    test('all critical tags exist in the catalog', () {
      expect(
        ClinicalScreeningCatalog.tags,
        containsAll(ClinicalScreeningTags.criticalEmergency),
      );

      final criticalCatalogTags = ClinicalScreeningCatalog.tagDefinitions
          .where((definition) => definition.isCritical)
          .map((definition) => definition.tag)
          .toSet();

      expect(
        criticalCatalogTags,
        containsAll(ClinicalScreeningTags.criticalEmergency),
      );
    });

    test('all main rule definitions exist in the catalog', () {
      expect(
        ClinicalScreeningCatalog.ruleIds,
        containsAll({
          'routine',
          'immediateDanger',
          'oncologicCluster',
          'infectiousCluster',
          'neurologicCluster',
          'cardiorespiratoryCluster',
          'fractureRiskCluster',
          'vascularCluster',
          'systemicConcern',
          'yellowFlagsOnly',
          'highestFlagLevel',
          'scoreEscalation',
        }),
      );
    });

    test('each catalog rule has a non-empty clinical rationale', () {
      for (final rule in ClinicalScreeningCatalog.ruleDefinitions) {
        expect(rule.clinicalRationale.trim(), isNotEmpty, reason: rule.ruleId);
      }
    });

    test('each catalog flag has a non-empty suggested question', () {
      for (final flag in ClinicalScreeningCatalog.flagDefinitions) {
        expect(flag.suggestedQuestion.trim(), isNotEmpty, reason: flag.id);
      }
    });

    test(
      'catalog rule ids match rule ids emitted by ClinicalScreeningEngineV3',
      () {
        final emittedRuleIds = <String>{
          evaluate(const []).traces.single.ruleId,
          evaluate([
            flag(id: 'critical', tags: [ClinicalScreeningTags.urgenceVitale]),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'cancer',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.cancer],
            ),
            flag(
              id: 'weight-loss',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.pertePoids],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'fever',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.fievre],
            ),
            flag(
              id: 'immunosuppression',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.immunodepression],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'neuro',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.deficitMoteurProgressif],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'chest-pain',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.douleurThoracique],
            ),
            flag(
              id: 'dyspnea',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.dyspnee],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(id: 'trauma', tags: [ClinicalScreeningTags.traumatisme]),
            flag(
              id: 'osteoporosis',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.osteoporose],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'wells-a',
              category: ClinicalFlagCategory.vascular,
              tags: [ClinicalScreeningTags.wellsTvp],
            ),
            flag(
              id: 'wells-b',
              category: ClinicalFlagCategory.vascular,
              tags: [ClinicalScreeningTags.wellsTvp],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(
              id: 'systemic',
              layer: ClinicalScreeningLayer.systemic,
              tags: [ClinicalScreeningTags.cancer],
            ),
          ]).traces.single.ruleId,
          evaluate([
            flag(id: 'yellow', layer: ClinicalScreeningLayer.yellowFlag),
          ]).traces.single.ruleId,
          evaluate([
            flag(id: 'intrinsic', level: ClinicalDecisionLevel.urgentReferral),
          ]).traces.single.ruleId,
          evaluate([
            flag(id: 'score-a', weight: 2),
            flag(id: 'score-b', weight: 2),
          ]).traces.single.ruleId,
        };

        expect(ClinicalScreeningCatalog.ruleIds, containsAll(emittedRuleIds));
      },
    );

    test('yellow flags alone with high score never exceed monitor', () {
      final session = evaluate([
        flag(
          id: 'fear-avoidance',
          layer: ClinicalScreeningLayer.yellowFlag,
          weight: 4,
        ),
        flag(
          id: 'catastrophizing',
          layer: ClinicalScreeningLayer.yellowFlag,
          weight: 4,
        ),
      ]);

      expect(session.score, 8);
      expect(session.decisionLevel, ClinicalDecisionLevel.monitor);
      expect(session.recommendedAction.title, 'Surveillance renforcée');
      expect(session.traces.single.ruleId, 'yellowFlagsOnly');
      expect(session.traces.single.causalFlagIds, [
        'fear-avoidance',
        'catastrophizing',
      ]);
    });

    test('cancer alone is documented as medical advice', () {
      final session = evaluate([
        flag(
          id: 'cancer-history',
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.cancer],
        ),
      ]);

      expect(session.score, 1);
      expect(session.decisionLevel, ClinicalDecisionLevel.medicalAdvice);
      expect(session.recommendedAction.title, 'Avis médical recommandé');
      expect(session.traces.single.ruleId, 'systemicConcern');
    });

    test(
      'cancer with weight loss and night pain escalates to urgent referral',
      () {
        final session = evaluate([
          flag(
            id: 'cancer-history',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.cancer],
          ),
          flag(
            id: 'weight-loss',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.pertePoids],
          ),
          flag(
            id: 'night-pain',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.douleurNocturne],
          ),
          flag(
            id: 'unrelated',
            layer: ClinicalScreeningLayer.regional,
            tags: ['not_causal'],
          ),
        ]);

        expect(session.score, 4);
        expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
        expect(
          session.recommendedAction.title,
          'Avis médical impératif rapide',
        );
        expect(session.traces.single.ruleId, 'oncologicCluster');
        expect(
          session.traces.single.rulesetVersion,
          ClinicalScreeningRuleVersion.rulesetVersion,
        );
        expect(session.traces.single.causalFlagIds, [
          'cancer-history',
          'weight-loss',
          'night-pain',
        ]);
      },
    );

    test('fever with immunosuppression escalates to urgent referral', () {
      final session = evaluate([
        flag(
          id: 'fever',
          category: ClinicalFlagCategory.infectious,
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.fievre],
        ),
        flag(
          id: 'immunosuppression',
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.immunodepression],
        ),
        flag(
          id: 'non-causal',
          layer: ClinicalScreeningLayer.regional,
          tags: ['not_causal'],
        ),
      ]);

      expect(session.score, 3);
      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.traces.single.ruleId, 'infectiousCluster');
      expect(session.traces.single.causalFlagIds, [
        'fever',
        'immunosuppression',
      ]);
    });

    test('chest pain with dyspnea escalates to emergency', () {
      final session = evaluate([
        flag(
          id: 'chest-pain',
          category: ClinicalFlagCategory.cardiovascular,
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.douleurThoracique],
        ),
        flag(
          id: 'dyspnea',
          category: ClinicalFlagCategory.respiratory,
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.dyspnee],
        ),
      ]);

      expect(session.score, 2);
      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.recommendedAction.requiresEmergencyCall, isTrue);
      expect(session.recommendedAction.title, 'Urgence immédiate');
      expect(session.traces.single.ruleId, 'cardiorespiratoryCluster');
      expect(
        session.traces.single.decisionLevel,
        ClinicalDecisionLevel.emergency,
      );
      expect(session.traces.single.causalFlagIds, ['chest-pain', 'dyspnea']);
    });

    test(
      'trauma with prolonged corticosteroids escalates to urgent referral',
      () {
        final session = evaluate([
          flag(
            id: 'trauma',
            category: ClinicalFlagCategory.musculoskeletal,
            layer: ClinicalScreeningLayer.regional,
            tags: [ClinicalScreeningTags.traumatisme],
          ),
          flag(
            id: 'steroids',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.corticotherapieProlongee],
          ),
        ]);

        expect(session.score, 2);
        expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
        expect(session.traces.single.ruleId, 'fractureRiskCluster');
      },
    );

    test('vascular cluster keeps two vascular concerns as urgent referral', () {
      final session = evaluate([
        flag(
          id: 'wells-1',
          category: ClinicalFlagCategory.vascular,
          tags: [ClinicalScreeningTags.wellsTvp],
        ),
        flag(
          id: 'wells-2',
          category: ClinicalFlagCategory.vascular,
          tags: [ClinicalScreeningTags.wellsTvp],
        ),
      ]);

      expect(session.score, 2);
      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.recommendedAction.requiresMedicalContact, isTrue);
      expect(session.recommendedAction.requiresEmergencyCall, isFalse);
      expect(session.traces.single.ruleId, 'vascularCluster');
    });

    test('score thresholds 1, 2, 3, 4, 5, 6 are applied', () {
      final cases = <int, ClinicalDecisionLevel>{
        1: ClinicalDecisionLevel.monitor,
        2: ClinicalDecisionLevel.monitor,
        3: ClinicalDecisionLevel.monitor,
        4: ClinicalDecisionLevel.medicalAdvice,
        5: ClinicalDecisionLevel.medicalAdvice,
        6: ClinicalDecisionLevel.urgentReferral,
      };

      for (final entry in cases.entries) {
        final session = evaluate([
          flag(id: 'score-${entry.key}', weight: entry.key),
        ]);

        expect(
          session.decisionLevel,
          entry.value,
          reason: 'score ${entry.key}',
        );
      }
    });

    test('uppercase critical tag is detected correctly', () {
      final session = evaluate([
        flag(
          id: 'pulmonary-embolism',
          level: ClinicalDecisionLevel.monitor,
          tags: ['EMBOLIE_PULMONAIRE'],
        ),
      ]);

      expect(session.score, 1);
      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.recommendedAction.requiresEmergencyCall, isTrue);
      expect(session.traces.single.ruleId, 'immediateDanger');
    });

    test('isolated critical tags produce emergency despite monitor level', () {
      final cases = <String, String>{
        'queue-cheval': ClinicalScreeningTags.queueCheval,
        'open-fracture': ClinicalScreeningTags.fractureOuverte,
        'pulmonary-embolism': ClinicalScreeningTags.emboliePulmonaire,
        'critical-chest-pain': ClinicalScreeningTags.douleurThoraciqueCritique,
        'vital-emergency': ClinicalScreeningTags.urgenceVitale,
      };

      for (final entry in cases.entries) {
        final session = evaluate([
          flag(
            id: entry.key,
            level: ClinicalDecisionLevel.monitor,
            tags: [entry.value],
          ),
        ]);

        expect(
          session.decisionLevel,
          ClinicalDecisionLevel.emergency,
          reason: entry.value,
        );
        expect(session.traces.single.ruleId, 'immediateDanger');
      }
    });

    test('explicit neurologic cluster produces urgent referral', () {
      final session = evaluate([
        flag(
          id: 'progressive-motor-deficit',
          category: ClinicalFlagCategory.neurological,
          layer: ClinicalScreeningLayer.systemic,
          tags: [ClinicalScreeningTags.deficitMoteurProgressif],
        ),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.traces.single.ruleId, 'neurologicCluster');
      expect(session.traces.single.causalFlagIds, [
        'progressive-motor-deficit',
      ]);
    });

    test(
      'isolated non-critical chest pain does not produce emergency by default',
      () {
        final session = evaluate([
          flag(
            id: 'isolated-chest-pain',
            category: ClinicalFlagCategory.cardiovascular,
            level: ClinicalDecisionLevel.monitor,
            tags: [ClinicalScreeningTags.douleurThoracique],
          ),
        ]);

        expect(session.decisionLevel, ClinicalDecisionLevel.monitor);
        expect(session.traces.single.ruleId, 'highestFlagLevel');
      },
    );

    test('yellow flag with red flag keeps red flag priority', () {
      final session = evaluate([
        flag(
          id: 'yellow-context',
          layer: ClinicalScreeningLayer.yellowFlag,
          weight: 6,
        ),
        flag(
          id: 'critical-red-flag',
          level: ClinicalDecisionLevel.monitor,
          tags: [ClinicalScreeningTags.urgenceVitale],
        ),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.traces.single.ruleId, 'immediateDanger');
      expect(session.traces.single.causalFlagIds, ['critical-red-flag']);
    });

    test('emergency level without critical tag produces emergency', () {
      final session = evaluate([
        flag(
          id: 'clinical-emergency',
          level: ClinicalDecisionLevel.emergency,
          layer: ClinicalScreeningLayer.immediateDanger,
        ),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.traces.single.ruleId, 'immediateDanger');
    });

    test('urgent referral immediate danger level produces urgent referral', () {
      final session = evaluate([
        flag(
          id: 'urgent-clinical-flag',
          level: ClinicalDecisionLevel.urgentReferral,
          layer: ClinicalScreeningLayer.immediateDanger,
        ),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.recommendedAction.title, 'Avis médical impératif rapide');
      expect(session.traces.single.ruleId, 'immediateDanger');
    });

    test(
      'single severe vascular flag uses intrinsic urgent referral level',
      () {
        final session = evaluate([
          flag(
            id: 'single-severe-vascular',
            category: ClinicalFlagCategory.vascular,
            level: ClinicalDecisionLevel.urgentReferral,
            tags: [ClinicalScreeningTags.vasculaire],
          ),
        ]);

        expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
        expect(session.traces.single.ruleId, 'highestFlagLevel');
        expect(session.traces.single.causalFlagIds, ['single-severe-vascular']);
      },
    );

    test('score escalation produces scoreEscalation trace', () {
      final session = evaluate([
        flag(id: 'score-a', weight: 2),
        flag(id: 'score-b', weight: 2),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.medicalAdvice);
      expect(session.traces.single.ruleId, 'scoreEscalation');
      expect(session.traces.single.causalFlagIds, ['score-a', 'score-b']);
    });

    test('highest flag level produces highestFlagLevel trace', () {
      final session = evaluate([
        flag(
          id: 'regional-urgent',
          category: ClinicalFlagCategory.musculoskeletal,
          level: ClinicalDecisionLevel.urgentReferral,
          layer: ClinicalScreeningLayer.regional,
        ),
        flag(id: 'context', weight: 1),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.traces.single.ruleId, 'highestFlagLevel');
      expect(session.traces.single.causalFlagIds, ['regional-urgent']);
    });

    test('ignores absent flags and stores flags as an unmodifiable list', () {
      final session = evaluate([
        flag(
          id: 'absent-critical',
          category: ClinicalFlagCategory.cardiovascular,
          level: ClinicalDecisionLevel.emergency,
          layer: ClinicalScreeningLayer.immediateDanger,
          tags: ['douleur_thoracique_critique'],
          isPresent: false,
          weight: 10,
        ),
      ]);

      expect(session.score, 0);
      expect(session.presentFlags, isEmpty);
      expect(session.decisionLevel, ClinicalDecisionLevel.routine);
      expect(
        () => session.flags.add(
          const ClinicalFlag(
            id: 'new-flag',
            label: 'Nouveau signe',
            category: ClinicalFlagCategory.other,
            level: ClinicalDecisionLevel.monitor,
          ),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => session.traces.add(
          ClinicalReasoningTrace(
            ruleId: 'test',
            title: 'Test',
            rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
            layer: ClinicalScreeningLayer.regional,
            decisionLevel: ClinicalDecisionLevel.monitor,
            causalFlagIds: const [],
            explanation: 'Test',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test(
      'exportReasoningText contains decision, triggered rule and causal flags',
      () {
        final session = evaluate([
          flag(
            id: 'cancer-history',
            label: 'antécédent de cancer',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.cancer],
          ),
          flag(
            id: 'weight-loss',
            label: 'perte de poids inexpliquée',
            layer: ClinicalScreeningLayer.systemic,
            tags: [ClinicalScreeningTags.pertePoids],
          ),
        ]);

        final text = session.exportReasoningText();

        expect(text, contains('Décision : Avis médical impératif rapide.'));
        expect(text, contains('Règle déclenchée : Cluster oncologique.'));
        expect(text, contains('antécédent de cancer'));
        expect(text, contains('perte de poids inexpliquée'));
        expect(text, contains('Conduite proposée :'));
        expect(text, contains('Moteur : ClinicalScreeningEngineV3'));
        expect(text, contains('Version moteur : 3.0.0'));
        expect(text, contains('Version règles : 2026.06-v1'));
        expect(
          text,
          contains('Statut clinique : expérimental, non validé cliniquement'),
        );
        expect(session.reasoningSummary, text);
      },
    );

    test('empty session export also contains version metadata', () {
      final session = evaluate(const []);
      final text = session.exportReasoningText();

      expect(session.traces.single.ruleId, 'routine');
      expect(session.engineName, ClinicalScreeningRuleVersion.engineName);
      expect(session.engineVersion, ClinicalScreeningRuleVersion.engineVersion);
      expect(
        session.rulesetVersion,
        ClinicalScreeningRuleVersion.rulesetVersion,
      );
      expect(session.rulesetDate, ClinicalScreeningRuleVersion.rulesetDate);
      expect(
        session.clinicalStatus,
        ClinicalScreeningRuleVersion.clinicalStatus,
      );
      expect(text, contains('Version moteur : 3.0.0'));
      expect(text, contains('Version règles : 2026.06-v1'));
    });
  });
}
