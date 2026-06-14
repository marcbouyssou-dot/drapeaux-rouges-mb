import 'package:drapeaux_rouges_mb/services/voice_clinical_draft_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceClinicalDraftService', () {
    const service = VoiceClinicalDraftService();

    test('creates an empty draft', () {
      final draft = service.createEmptyDraft();

      expect(draft.rawTranscript, isNull);
      expect(draft.extractedClinicalItems, isEmpty);
      expect(draft.suggestedRedFlags, isEmpty);
      expect(draft.hasTranscript, isFalse);
      expect(draft.confidenceNote, contains('préparation'));
    });

    test('updates transcript without extracting clinical data', () {
      final draft = service.createEmptyDraft();

      final updated = service.updateTranscript(
        draft,
        '  douleur inhabituelle rapportée  ',
      );

      expect(updated.rawTranscript, 'douleur inhabituelle rapportée');
      expect(updated.hasTranscript, isTrue);
      expect(updated.extractedClinicalItems, isEmpty);
      expect(updated.suggestedRedFlags, isEmpty);
      expect(updated.confidenceNote, contains('préparation technique'));
    });

    test('clears the draft', () {
      final draft = service.updateTranscript(
        service.createEmptyDraft(),
        'transcription temporaire',
      );

      final cleared = service.clearDraft();

      expect(draft.hasTranscript, isTrue);
      expect(cleared.rawTranscript, isNull);
      expect(cleared.hasTranscript, isFalse);
      expect(cleared.extractedClinicalItems, isEmpty);
      expect(cleared.suggestedRedFlags, isEmpty);
    });
  });
}
