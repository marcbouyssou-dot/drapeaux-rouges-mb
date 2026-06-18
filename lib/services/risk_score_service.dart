import 'package:flutter/material.dart';

class RiskScoreService {
  static String normalizeSeverity(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e');

    if (normalized == 'critique') return 'Critique';
    if (normalized == 'eleve') return 'Élevé';
    return 'Modéré';
  }

  static int severityPoints(String severity) {
    final normalized = normalizeSeverity(severity);

    if (normalized == 'Critique') return 3;
    if (normalized == 'Élevé') return 2;
    return 1;
  }

  static int computeScore(List<Map<String, dynamic>> items) {
    int total = 0;

    for (final item in items) {
      if (item['checked'] == true) {
        total += severityPoints(item['severity']?.toString() ?? '');
      }
    }

    return total;
  }

  static int computeCheckedCount(List<Map<String, dynamic>> items) {
    return items.where((item) => item['checked'] == true).length;
  }

  static int computeGlobalScore(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    int total = 0;

    for (final items in categories.values) {
      total += computeScore(items);
    }

    return total;
  }

  static int computeGlobalCheckedCount(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    int total = 0;

    for (final items in categories.values) {
      total += computeCheckedCount(items);
    }

    return total;
  }

  static String riskLevelFromScore(int score) {
    if (score >= 6) return 'Risque critique';
    if (score >= 4) return 'Risque élevé';
    if (score >= 2) return 'Risque modéré';
    return 'Risque faible';
  }

  static Color riskColorFromScore(int score) {
    if (score >= 6) return const Color(0xFF7F1D1D);
    if (score >= 4) return const Color(0xFFDC2626);
    if (score >= 2) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  static List<Map<String, dynamic>> checkedFlagsFromItems(
    List<Map<String, dynamic>> items,
  ) {
    return items.where((item) => item['checked'] == true).map((item) {
      return {
        'title': item['title']?.toString() ?? 'Item sans titre',
        'severity': normalizeSeverity(item['severity']?.toString() ?? ''),
        'tags': item['tags'] ?? [],
      };
    }).toList();
  }

  static List<Map<String, dynamic>> checkedFlagsFromCategories(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    final checkedFlags = <Map<String, dynamic>>[];

    for (final entry in categories.entries) {
      for (final item in entry.value) {
        if (item['checked'] == true) {
          checkedFlags.add({
            'category': entry.key,
            'title': item['title']?.toString() ?? 'Item sans titre',
            'severity': normalizeSeverity(item['severity']?.toString() ?? ''),
            'tags': item['tags'] ?? [],
          });
        }
      }
    }

    return checkedFlags;
  }
}
