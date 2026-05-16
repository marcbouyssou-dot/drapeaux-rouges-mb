import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';

import 'local_database_service.dart';

class GlobalStatisticsCsvService {
  static Future<void> exportGlobalStatisticsCsv() async {
    final evaluations = await LocalDatabaseService.getEvaluations();

    final buffer = StringBuffer();

    buffer.writeln(
      [
        'PatientPseudonymise',
        'MoisEvaluation',
        'Motif',
        'ScoreGlobal',
        'RisqueGlobal',
        'NombreDrapeaux',
        'Severites',
        'Tags',
      ].join(';'),
    );

    for (final evaluation in evaluations) {
      final patientAnonymousId =
          evaluation['patientAnonymousId']?.toString() ?? 'non_renseigne';

      final dateMonth = _monthOnly(evaluation['date']?.toString());

      final motif = evaluation['motif']?.toString() ?? '';
      final score = evaluation['score']?.toString() ?? '';
      final riskLevel = evaluation['riskLevel']?.toString() ?? '';
      final checkedCount = evaluation['checkedCount']?.toString() ?? '';

      final checkedFlags = _checkedFlags(evaluation);

      final severities = checkedFlags
          .map((flag) => flag['severity']?.toString() ?? '')
          .where((value) => value.isNotEmpty)
          .toSet()
          .join('|');

      final tags = checkedFlags
          .expand((flag) {
            final rawTags = flag['tags'];
            if (rawTags is List) {
              return rawTags.map((tag) => tag.toString());
            }
            return <String>[];
          })
          .where((value) => value.isNotEmpty)
          .toSet()
          .join('|');

      buffer.writeln(
        [
          _sanitize(patientAnonymousId),
          _sanitize(dateMonth),
          _sanitize(motif),
          _sanitize(score),
          _sanitize(riskLevel),
          _sanitize(checkedCount),
          _sanitize(severities),
          _sanitize(tags),
        ].join(';'),
      );
    }

    final bytes = Uint8List.fromList(
      utf8.encode(buffer.toString()),
    );

    final fileName =
        'statistiques_globales_pseudonymisees_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: 'text/csv',
    );

    await Share.shareXFiles(
      [file],
      subject: 'Statistiques globales pseudonymisées',
      text:
          'Export statistique global pseudonymisé. Ce fichier ne contient ni nom, ni prénom, ni date de naissance complète.',
    );
  }

  static List<Map<String, dynamic>> _checkedFlags(
    Map<String, dynamic> evaluation,
  ) {
    final raw = evaluation['checkedFlags'];

    if (raw is! List) return [];

    return raw.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  static String _monthOnly(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(rawDate);

    if (date == null) {
      return '';
    }

    final month = date.month.toString().padLeft(2, '0');

    return '${date.year}-$month';
  }

  static String _sanitize(String value) {
    return value
        .replaceAll(';', ',')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();
  }
}