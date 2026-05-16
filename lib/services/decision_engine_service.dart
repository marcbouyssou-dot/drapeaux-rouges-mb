class DecisionEngineService {
  static String decisionTitle({
    required int score,
    required String selectedCategory,
    required Map<String, List<Map<String, dynamic>>> categories,
  }) {
    if (_hasPulmonaryEmbolismSigns(categories)) {
      return 'Orientation urgente recommandée';
    }

    if (_hasCervicalVascularSuspicion(categories)) {
      return 'Suspicion neurovasculaire cervicale';
    }

    if (_hasCriticalFractureOrLuxation(categories)) {
      return 'Orientation urgente recommandée';
    }

    if (_hasPositiveOttawa(categories)) {
      return 'Critères d’Ottawa positifs';
    }

    if (_hasWellsSuspicion(categories)) {
      return 'Suspicion de TVP';
    }

    if (score >= 6) return 'Orientation urgente recommandée';
    if (score >= 4) return 'Avis médical rapide recommandé';
    if (score >= 2) return 'Vigilance clinique renforcée';

    return 'Prise en charge possible avec surveillance';
  }

  static String decisionMessage({
    required int score,
    required String selectedCategory,
    required Map<String, List<Map<String, dynamic>>> categories,
  }) {
    if (_hasPulmonaryEmbolismSigns(categories)) {
      return 'Présence de signes pouvant évoquer une complication cardio-respiratoire ou embolique. Une orientation médicale urgente est recommandée.';
    }

    if (_hasCervicalVascularSuspicion(categories)) {
      return 'Plusieurs signes compatibles avec une atteinte neurovasculaire cervicale sont présents. Un avis médical urgent est recommandé.';
    }

    if (_hasCriticalFractureOrLuxation(categories)) {
      return 'Suspicion de fracture ouverte, luxation ou déformation évidente. Une orientation médicale urgente est recommandée.';
    }

    if (_hasPositiveOttawa(categories)) {
      return 'Un ou plusieurs critères d’Ottawa sont positifs. Une radiographie est recommandée selon le contexte clinique.';
    }

    if (_hasWellsSuspicion(categories)) {
      return 'Plusieurs critères de Wells TVP sont présents. Un avis médical rapide est recommandé pour évaluation complémentaire.';
    }

    if (score >= 6) {
      return 'Plusieurs signes d’alerte importants sont présents. Une orientation médicale urgente doit être envisagée.';
    }

    if (score >= 4) {
      return 'Des signes d’alerte significatifs sont présents. Un avis médical rapide est recommandé.';
    }

    if (score >= 2) {
      return 'Une surveillance clinique renforcée est recommandée.';
    }

    return 'Aucun signe critique majeur identifié actuellement.';
  }

  static bool _hasPositiveOttawa(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final items = categories['Entorse de cheville'] ?? [];

    return items.any((item) {
      final checked = item['checked'] == true;
      return checked && _hasTagOrText(item, 'ottawa', 'ottawa positif');
    });
  }

  static bool _hasWellsSuspicion(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final items = categories['TVP / Vasculaire'] ?? [];

    final wellsChecked = items.where((item) {
      final checked = item['checked'] == true;
      return checked && _hasTagOrText(item, 'wells_tvp', 'wells tvp');
    }).length;

    return wellsChecked >= 2;
  }

  static bool _hasPulmonaryEmbolismSigns(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final items = categories['TVP / Vasculaire'] ?? [];

    return items.any((item) {
      final checked = item['checked'] == true;

      return checked &&
          (_hasTag(item, 'embolie_pulmonaire') ||
              _textContains(item, 'dyspnée brutale') ||
              _textContains(item, 'dyspnee brutale') ||
              _textContains(item, 'douleur thoracique') ||
              _textContains(item, 'tachycardie'));
    });
  }

  static bool _hasCriticalFractureOrLuxation(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    for (final items in categories.values) {
      final found = items.any((item) {
        final checked = item['checked'] == true;

        return checked &&
            (_hasTag(item, 'fracture_ouverte') ||
                _hasTag(item, 'luxation') ||
                _hasTag(item, 'deformation') ||
                _textContains(item, 'fracture ouverte') ||
                _textContains(item, 'luxation') ||
                _textContains(item, 'déformation évidente') ||
                _textContains(item, 'deformation evidente'));
      });

      if (found) return true;
    }

    return false;
  }

  static bool _hasCervicalVascularSuspicion(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final items = categories['Cervicalgie'] ?? [];

    final checkedDangerSigns = items.where((item) {
      final checked = item['checked'] == true;

      return checked &&
          (_hasTag(item, 'neurovasculaire_cervical') ||
              _hasTag(item, '5d') ||
              _hasTag(item, '3n') ||
              _textContains(item, '5d') ||
              _textContains(item, '3n') ||
              _textContains(item, 'céphalée') ||
              _textContains(item, 'cephalee') ||
              _textContains(item, 'neurologique'));
    }).length;

    return checkedDangerSigns >= 2;
  }

  static bool _hasTagOrText(
    Map<String, dynamic> item,
    String tag,
    String text,
  ) {
    return _hasTag(item, tag) || _textContains(item, text);
  }

  static bool _hasTag(Map<String, dynamic> item, String tag) {
    final rawTags = item['tags'];

    if (rawTags is! List) return false;

    return rawTags.map((value) => value.toString()).contains(tag);
  }

  static bool _textContains(Map<String, dynamic> item, String value) {
    final title = item['title']?.toString().toLowerCase() ?? '';
    final searched = value.toLowerCase();

    return title.contains(searched);
  }
}