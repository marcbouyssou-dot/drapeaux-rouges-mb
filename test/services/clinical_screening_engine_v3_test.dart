import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
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
    });

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
          tags: ['cancer'],
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
            tags: ['cancer'],
          ),
          flag(
            id: 'weight-loss',
            layer: ClinicalScreeningLayer.systemic,
            tags: ['perte_poids'],
          ),
          flag(
            id: 'night-pain',
            layer: ClinicalScreeningLayer.systemic,
            tags: ['douleur_nocturne'],
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
          tags: ['fievre'],
        ),
        flag(
          id: 'immunosuppression',
          layer: ClinicalScreeningLayer.systemic,
          tags: ['immunodepression'],
        ),
      ]);

      expect(session.score, 2);
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
          tags: ['douleur_thoracique'],
        ),
        flag(
          id: 'dyspnea',
          category: ClinicalFlagCategory.respiratory,
          layer: ClinicalScreeningLayer.systemic,
          tags: ['dyspnee'],
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
            tags: ['traumatisme'],
          ),
          flag(
            id: 'steroids',
            layer: ClinicalScreeningLayer.systemic,
            tags: ['corticotherapie_prolongee'],
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
          tags: ['wells_tvp'],
        ),
        flag(
          id: 'wells-2',
          category: ClinicalFlagCategory.vascular,
          tags: ['wells_tvp'],
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
          level: ClinicalDecisionLevel.emergency,
          layer: ClinicalScreeningLayer.immediateDanger,
          tags: ['EMBOLIE_PULMONAIRE'],
        ),
      ]);

      expect(session.score, 1);
      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.recommendedAction.requiresEmergencyCall, isTrue);
      expect(session.traces.single.ruleId, 'immediateDanger');
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
            tags: ['cancer'],
          ),
          flag(
            id: 'weight-loss',
            label: 'perte de poids inexpliquée',
            layer: ClinicalScreeningLayer.systemic,
            tags: ['perte_poids'],
          ),
        ]);

        final text = session.exportReasoningText();

        expect(text, contains('Décision : Avis médical impératif rapide.'));
        expect(text, contains('Règle déclenchée : Cluster oncologique.'));
        expect(text, contains('antécédent de cancer'));
        expect(text, contains('perte de poids inexpliquée'));
        expect(text, contains('Conduite proposée :'));
        expect(session.reasoningSummary, text);
      },
    );
  });
}
