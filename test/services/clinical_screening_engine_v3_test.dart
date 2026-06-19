import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/services/clinical_screening_engine_v3.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalScreeningEngineV3', () {
    const engine = ClinicalScreeningEngineV3();
    final createdAt = DateTime(2026, 1, 1);

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

    test('escalates to medical advice from accumulated score', () {
      final session = engine.evaluate(
        sessionId: 'session-2',
        reason: 'Douleur progressive',
        createdAt: createdAt,
        flags: const [
          ClinicalFlag(
            id: 'flag-1',
            label: 'Douleur nocturne',
            category: ClinicalFlagCategory.musculoskeletal,
            level: ClinicalDecisionLevel.monitor,
            weight: 2,
          ),
          ClinicalFlag(
            id: 'flag-2',
            label: 'Fatigue inhabituelle',
            category: ClinicalFlagCategory.general,
            level: ClinicalDecisionLevel.monitor,
            weight: 2,
          ),
        ],
      );

      expect(session.score, 4);
      expect(session.decisionLevel, ClinicalDecisionLevel.medicalAdvice);
      expect(session.recommendedAction.requiresMedicalContact, isTrue);
      expect(session.recommendedAction.requiresEmergencyCall, isFalse);
      expect(session.recommendedAction.relatedFlagIds, ['flag-1', 'flag-2']);
    });

    test('emergency tag overrides lower score and lower declared level', () {
      final session = engine.evaluate(
        sessionId: 'session-3',
        reason: 'Cheville traumatique',
        createdAt: createdAt,
        flags: const [
          ClinicalFlag(
            id: 'open-fracture',
            label: 'Suspicion de fracture ouverte',
            category: ClinicalFlagCategory.musculoskeletal,
            level: ClinicalDecisionLevel.medicalAdvice,
            tags: ['fracture_ouverte'],
            weight: 1,
          ),
        ],
      );

      expect(session.score, 1);
      expect(session.decisionLevel, ClinicalDecisionLevel.emergency);
      expect(session.recommendedAction.requiresMedicalContact, isTrue);
      expect(session.recommendedAction.requiresEmergencyCall, isTrue);
      expect(
        session.recommendedAction.message,
        contains('15, le 112 ou le service d’urgence adapté'),
      );
    });

    test('vascular cluster escalates to urgent referral', () {
      final session = engine.evaluate(
        sessionId: 'session-4',
        reason: 'Suspicion TVP',
        createdAt: createdAt,
        flags: const [
          ClinicalFlag(
            id: 'wells-1',
            label: 'Douleur sur le trajet veineux profond',
            category: ClinicalFlagCategory.vascular,
            level: ClinicalDecisionLevel.monitor,
            tags: ['wells_tvp'],
            weight: 1,
          ),
          ClinicalFlag(
            id: 'wells-2',
            label: 'Oedème global du membre inférieur',
            category: ClinicalFlagCategory.vascular,
            level: ClinicalDecisionLevel.monitor,
            tags: ['wells_tvp'],
            weight: 1,
          ),
        ],
      );

      expect(session.score, 2);
      expect(session.decisionLevel, ClinicalDecisionLevel.urgentReferral);
      expect(session.recommendedAction.requiresMedicalContact, isTrue);
      expect(session.recommendedAction.requiresEmergencyCall, isFalse);
    });

    test('ignores absent flags and stores flags as an unmodifiable list', () {
      final session = engine.evaluate(
        sessionId: 'session-5',
        reason: 'Contrôle',
        createdAt: createdAt,
        flags: const [
          ClinicalFlag(
            id: 'absent-critical',
            label: 'Douleur thoracique absente',
            category: ClinicalFlagCategory.cardiovascular,
            level: ClinicalDecisionLevel.emergency,
            tags: ['douleur_thoracique_critique'],
            isPresent: false,
            weight: 10,
          ),
        ],
      );

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
