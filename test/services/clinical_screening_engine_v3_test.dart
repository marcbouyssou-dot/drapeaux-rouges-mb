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
      ClinicalFlagCategory category = ClinicalFlagCategory.general,
      ClinicalDecisionLevel level = ClinicalDecisionLevel.monitor,
      ClinicalScreeningLayer layer = ClinicalScreeningLayer.regional,
      List<String> tags = const [],
      int weight = 1,
      bool isPresent = true,
    }) {
      return ClinicalFlag(
        id: id,
        label: id,
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
        ]);

        expect(session.score, 3);
        expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
        expect(
          session.recommendedAction.title,
          'Avis médical impératif rapide',
        );
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
    });

    test('urgent referral level produces urgent referral', () {
      final session = evaluate([
        flag(
          id: 'urgent-clinical-flag',
          level: ClinicalDecisionLevel.urgentReferral,
          layer: ClinicalScreeningLayer.immediateDanger,
        ),
      ]);

      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.recommendedAction.title, 'Avis médical impératif rapide');
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
    });
  });
}
