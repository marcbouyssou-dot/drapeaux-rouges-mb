import '../models/voice/voice_clinical_draft.dart';

class VoiceClinicalDraftService {
  const VoiceClinicalDraftService();

  VoiceClinicalDraft createEmptyDraft() {
    return const VoiceClinicalDraft(
      confidenceNote:
          'Fonctionnalité en préparation. Aucun traitement vocal actif.',
    );
  }

  VoiceClinicalDraft updateTranscript(
    VoiceClinicalDraft draft,
    String transcript,
  ) {
    return draft.copyWith(
      rawTranscript: transcript.trim(),
      confidenceNote:
          'Transcription saisie manuellement pour préparation technique uniquement.',
    );
  }

  VoiceClinicalDraft clearDraft() {
    return createEmptyDraft();
  }
}
