class DecisionEngineService {
  static String decisionTitle({
    required int score,
    required String selectedCategory,
    required Map<String, List<Map<String, dynamic>>> categories,
  }) {
    if (_hasCervicalVascularSuspicion(selectedCategory, categories)) {
      return 'Suspicion neurovasculaire cervicale';
    }
    if (_hasPulmonaryEmbolismSigns(selectedCategory, categories)) {
      return 'Orientation urgente recommandee';
    }

    if (_hasCriticalFractureOrLuxation(selectedCategory, categories)) {
      return 'Orientation urgente recommandee';
    }

    if (_hasPositiveOttawa(selectedCategory, categories)) {
      return 'Criteres d Ottawa positifs';
    }

    if (_hasWellsSuspicion(selectedCategory, categories)) {
      return 'Suspicion de TVP';
    }

    if (score >= 6) return 'Orientation urgente recommandee';
    if (score >= 4) return 'Avis medical rapide recommande';
    if (score >= 2) return 'Vigilance clinique renforcee';
    return 'Prise en charge possible avec surveillance';
  }

  static String decisionMessage({
    required int score,
    required String selectedCategory,
    required Map<String, List<Map<String, dynamic>>> categories,
  }) {
    if (_hasCervicalVascularSuspicion(selectedCategory, categories)) {
    return 'Plusieurs signes compatibles avec une atteinte neurovasculaire cervicale sont presents. Un avis medical urgent est recommande.';
    }
    if (_hasPulmonaryEmbolismSigns(selectedCategory, categories)) {
      return 'Presence de signes pouvant evoquer une complication cardio-respiratoire. Une orientation medicale urgente est recommandee.';
    }

    if (_hasCriticalFractureOrLuxation(selectedCategory, categories)) {
      return 'Suspicion de fracture ouverte, luxation ou deformation evidente. Une orientation medicale urgente est recommandee.';
    }

    if (_hasPositiveOttawa(selectedCategory, categories)) {
      return 'Un ou plusieurs criteres d Ottawa sont positifs. Une radiographie est recommandee selon le contexte clinique.';
    }

    if (_hasWellsSuspicion(selectedCategory, categories)) {
      return 'Plusieurs criteres de Wells TVP sont presents. Un avis medical rapide est recommande pour evaluation complementaire.';
    }

    if (score >= 6) {
      return 'Plusieurs signes d alerte importants sont presents. Une orientation medicale urgente doit etre envisagee.';
    }

    if (score >= 4) {
      return 'Des signes d alerte significatifs sont presents. Un avis medical rapide est recommande.';
    }

    if (score >= 2) {
      return 'Une surveillance clinique renforcee est recommandee.';
    }

    return 'Aucun signe critique majeur identifie actuellement.';
  }

  static bool _hasPositiveOttawa(
    String selectedCategory,
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    if (selectedCategory != 'Entorse de cheville') return false;

    final items = categories[selectedCategory] ?? [];

    return items.any((item) {
      final title = item['title'].toString().toLowerCase();
      final checked = item['checked'] == true;

      return checked && title.contains('ottawa positif');
    });
  }

  static bool _hasWellsSuspicion(
    String selectedCategory,
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    if (selectedCategory != 'TVP / Vasculaire') return false;

    final items = categories[selectedCategory] ?? [];

    final wellsChecked = items.where((item) {
      final title = item['title'].toString().toLowerCase();
      final checked = item['checked'] == true;

      return checked && title.contains('wells tvp');
    }).length;

    return wellsChecked >= 2;
  }

  static bool _hasPulmonaryEmbolismSigns(
    String selectedCategory,
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    if (selectedCategory != 'TVP / Vasculaire') return false;

    final items = categories[selectedCategory] ?? [];

    return items.any((item) {
      final title = item['title'].toString().toLowerCase();
      final checked = item['checked'] == true;

      return checked &&
          (title.contains('dyspnee brutale') ||
              title.contains('douleur thoracique') ||
              title.contains('tachycardie'));
    });
  }

  static bool _hasCriticalFractureOrLuxation(
    String selectedCategory,
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final items = categories[selectedCategory] ?? [];

    return items.any((item) {
      final title = item['title'].toString().toLowerCase();
      final checked = item['checked'] == true;

      return checked &&
          (title.contains('fracture ouverte') ||
              title.contains('luxation') ||
              title.contains('deformation evidente'));
    });
  }
  static bool _hasCervicalVascularSuspicion(
  String selectedCategory,
  Map<String, List<Map<String, dynamic>>> categories,
) {
  if (selectedCategory != 'Cervicalgie') return false;

  final items = categories[selectedCategory] ?? [];

  final checkedDangerSigns = items.where((item) {
    final checked = item['checked'] == true;
    final title = item['title'].toString().toLowerCase();

    return checked &&
        (title.contains('5d') ||
            title.contains('3n') ||
            title.contains('céphalée') ||
            title.contains('neurologique'));
  }).length;

  return checkedDangerSigns >= 2;
}
}