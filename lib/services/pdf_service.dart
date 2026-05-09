import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> exportPdf({
    required Map<String, List<Map<String, dynamic>>> categories,
    required int score,
    required int checkedCount,
    required String riskLevel,
    required String patientCode,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final checkedRows = categories.entries.expand((entry) {
      return entry.value
          .where((item) => item['checked'] == true)
          .map((item) => [
                entry.key,
                item['title'],
                item['severity'],
              ]);
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
        ),
        build: (context) => [
          pw.Text(
            'Synthese clinique MB',
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1D4ED8'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Date : ${now.day}/${now.month}/${now.year}'),
          pw.Text('Heure : ${now.hour}:${now.minute.toString().padLeft(2, '0')}'),
          pw.Text('Code patient : $patientCode'),
          pw.SizedBox(height: 20),
          pw.Text('Niveau de risque : $riskLevel'),
          pw.Text('Score clinique : $score'),
          pw.Text('Drapeaux coches : $checkedCount'),
          pw.SizedBox(height: 20),
          pw.Text(
            'Drapeaux rouges coches',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          checkedRows.isEmpty
              ? pw.Text('Aucun drapeau rouge coche.')
              : pw.TableHelper.fromTextArray(
                  headers: ['Categorie', 'Drapeau rouge', 'Niveau'],
                  data: checkedRows,
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1D4ED8'),
                  ),
                  headerStyle: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellPadding: const pw.EdgeInsets.all(8),
                ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Mention de prudence',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Ce document constitue une aide clinique. Il ne remplace pas une evaluation medicale professionnelle.',
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'RGPD',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Ne pas saisir de donnees nominatives. Utiliser uniquement un identifiant pseudonymise.',
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}