class ClinicalAiService {
  static String generateClinicalSummary({
    required Map<String, List<Map<String, dynamic>>> categories,
    required int score,
    required int checkedCount,
  }) {
    final List<String> detectedCategories = [];

    categories.forEach((category, items) {
      final hasChecked = items.any(
        (item) => item['checked'] == true,
      );

      if (hasChecked) {
        detectedCategories.add(category);
      }
    });

    final List<String> messages = [];

    if (detectedCategories.contains('Cardiovasculaire') &&
        detectedCategories.contains('Respiratoire')) {
      messages.add(
        'Association de drapeaux rouges cardio-respiratoires.',
      );
    }

    if (detectedCategories.contains('Neurologique')) {
      messages.add(
        'Presence de signes neurologiques necessitant une vigilance renforcee.',
      );
    }

    if (detectedCategories.contains('Sante mentale')) {
      messages.add(
        'Presence de signes psychiques ou comportementaux a evaluer avec prudence.',
      );
    }

    if (detectedCategories.contains('Infectieux')) {
      messages.add(
        'Presence de signes infectieux pouvant necessiter une evaluation rapide.',
      );
    }

    if (score >= 9) {
      messages.add(
        'Accumulation importante de drapeaux rouges critiques.',
      );
    }

    if (checkedCount == 0) {
      return 'Aucun drapeau rouge majeur coche dans cette evaluation.';
    }

    if (messages.isEmpty) {
      messages.add(
        'Presence de plusieurs elements necessitant une evaluation clinique contextualisee.',
      );
    }

    messages.add(
      'Cette synthese constitue une aide au reperage et ne remplace pas une evaluation medicale professionnelle.',
    );

    return messages.join('\n\n');
  }
}