import 'package:share_plus/share_plus.dart';

class CsvService {
  static void exportCsv({
    required Map<String, List<Map<String, dynamic>>> categories,
    required int score,
    required String riskLevel,
    required String patientCode,
  }) {
    String csv = 'Categorie;Titre;Severite;Score;Risque;Patient\n';

    for (final entry in categories.entries) {
      for (final item in entry.value) {
        if (item['checked'] == true) {
          csv += '${entry.key};${item['title']};${item['severity']};$score;$riskLevel;$patientCode\n';
        }
      }
    }

    Share.share(csv);
  }
}