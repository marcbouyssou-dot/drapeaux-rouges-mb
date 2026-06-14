class VoiceClinicalDraft {
  const VoiceClinicalDraft({
    this.rawTranscript,
    this.extractedClinicalItems = const <String>[],
    this.suggestedRedFlags = const <String>[],
    this.confidenceNote,
  });

  final String? rawTranscript;
  final List<String> extractedClinicalItems;
  final List<String> suggestedRedFlags;
  final String? confidenceNote;

  bool get hasTranscript => rawTranscript?.trim().isNotEmpty ?? false;

  VoiceClinicalDraft copyWith({
    String? rawTranscript,
    List<String>? extractedClinicalItems,
    List<String>? suggestedRedFlags,
    String? confidenceNote,
  }) {
    return VoiceClinicalDraft(
      rawTranscript: rawTranscript ?? this.rawTranscript,
      extractedClinicalItems:
          extractedClinicalItems ?? this.extractedClinicalItems,
      suggestedRedFlags: suggestedRedFlags ?? this.suggestedRedFlags,
      confidenceNote: confidenceNote ?? this.confidenceNote,
    );
  }
}
