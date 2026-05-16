import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:share_plus/share_plus.dart';

class CsvService {
  static Future<void> exportCsv({
    required Map<String, List<Map<String, dynamic>>> categories,
    required int score,
    required String riskLevel,
    required String patientCode,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln(
      'Categorie;Titre;Severite;ScoreGlobal;RisqueGlobal;IdentifiantPseudonymise',
    );

    for (final entry in categories.entries) {
      for (final item in entry.value) {
        if (item['checked'] == true) {
          buffer.writeln(
            [
              _sanitize(entry.key),
              _sanitize(item['title']?.toString() ?? ''),
              _sanitize(item['severity']?.toString() ?? ''),
              score.toString(),
              _sanitize(riskLevel),
              _sanitize(patientCode),
            ].join(';'),
          );
        }
      }
    }

    final csvContent = buffer.toString();

    final bytes = Uint8List.fromList(
      utf8.encode(csvContent),
    );

    final fileName =
        'export_statistique_pseudonymise_${DateTime.now().millisecondsSinceEpoch}.csv';

    final file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: 'text/csv',
    );

    await Share.shareXFiles(
      [file],
      subject: 'Export statistique pseudonymisé',
      text:
          'Export statistique pseudonymisé. Ce fichier peut contenir des données de santé pseudonymisées. Ne pas partager publiquement.',
    );
  }

  static String _sanitize(String value) {
    return value
        .replaceAll(';', ',')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .trim();
  }
}