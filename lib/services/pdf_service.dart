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
    required String motif,
    required String decisionTitle,
    required String decisionMessage,
    required String aiSummary,
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

    PdfColor riskPdfColor() {
      if (score >= 6) return PdfColor.fromHex('#7F1D1D');
      if (score >= 4) return PdfColors.red;
      if (score >= 2) return PdfColors.orange;
      return PdfColors.green;
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(30),
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
        ),

        footer: (context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Drapeaux Rouges — Document clinique local',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}/${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },

        build: (context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(22),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#EEF4FF'),
                borderRadius: pw.BorderRadius.circular(18),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Synthèse clinique',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1D4ED8'),
                        ),
                      ),

                      pw.SizedBox(height: 6),

                      pw.Text('Drapeaux Rouges'),

                      pw.SizedBox(height: 10),

                      pw.Text('Motif : $motif'),

                      pw.Text(
                        'Date : ${now.day}/${now.month}/${now.year}',
                      ),

                      pw.Text(
                        'Heure : ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                      ),

                      pw.Text(
                        'Patient / identifiant local : $patientCode',
                      ),
                    ],
                  ),

                  pw.Container(
                    width: 64,
                    height: 64,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#1D4ED8'),
                      borderRadius: pw.BorderRadius.circular(18),
                    ),
                    child: pw.Text(
                      'MK',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 22),

            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FEF3C7'),
                borderRadius: pw.BorderRadius.circular(14),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#F59E0B'),
                ),
              ),
              child: pw.Text(
                'Document clinique local — non destiné aux statistiques anonymisées.',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#92400E'),
                ),
              ),
            ),

            pw.SizedBox(height: 24),

            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: statBox(
                    title: 'Niveau de risque',
                    value: riskLevel,
                    color: riskPdfColor(),
                  ),
                ),

                pw.SizedBox(width: 12),

                pw.Expanded(
                  child: statBox(
                    title: 'Score',
                    value: '$score',
                    color: riskPdfColor(),
                  ),
                ),

                pw.SizedBox(width: 12),

                pw.Expanded(
                  child: statBox(
                    title: 'Drapeaux',
                    value: '$checkedCount',
                    color: riskPdfColor(),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            sectionTitle('Décision clinique'),

            pw.SizedBox(height: 8),

            infoBox(
              title: decisionTitle,
              text: decisionMessage,
              color: riskPdfColor(),
            ),

            pw.SizedBox(height: 24),

            sectionTitle('Synthèse assistée'),

            pw.SizedBox(height: 8),

            neutralBox(aiSummary),

            pw.SizedBox(height: 24),

            sectionTitle('Drapeaux rouges cochés'),

            pw.SizedBox(height: 10),

            checkedRows.isEmpty
                ? neutralBox('Aucun drapeau rouge coché.')
                : pw.TableHelper.fromTextArray(
                    headers: [
                      'Catégorie',
                      'Drapeau rouge',
                      'Niveau',
                    ],
                    data: checkedRows,
                    headerDecoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#1D4ED8'),
                    ),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellPadding: const pw.EdgeInsets.all(8),
                    border: pw.TableBorder.all(
                      color: PdfColor.fromHex('#CBD5E1'),
                      width: 0.5,
                    ),
                  ),

            pw.SizedBox(height: 24),

            sectionTitle('Mentions légales'),

            pw.SizedBox(height: 8),

            neutralBox(
              'Cette application constitue une aide au repérage clinique. '
              'Elle ne remplace pas un diagnostic médical ni une évaluation médicale professionnelle.\n\n'
              'Les décisions cliniques restent sous la responsabilité du professionnel utilisateur.\n\n'
              'Les exports statistiques doivent être anonymisés.',
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget statBox({
    required String title,
    required String value,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(
          color: color,
          width: 1.2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#0F172A'),
      ),
    );
  }

  static pw.Widget infoBox({
    required String title,
    required String text,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: color,
          width: 1.2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 10,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget neutralBox(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: PdfColor.fromHex('#E2E8F0'),
        ),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 10,
          lineSpacing: 4,
        ),
      ),
    );
  }
}