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

    PdfColor riskPdfColor() {
      if (score >= 9) return PdfColor.fromHex('#7F1D1D');
      if (score >= 6) return PdfColors.red;
      if (score >= 3) return PdfColors.orange;
      return PdfColors.green;
    }

    String conclusion() {
      if (score >= 9) {
        return 'Presence de signes critiques multiples. Une evaluation medicale urgente est recommandee selon le contexte clinique.';
      }

      if (score >= 6) {
        return 'Presence de plusieurs signes d alerte importants. Une evaluation medicale rapide est recommandee.';
      }

      if (score >= 3) {
        return 'Presence de signes necessitant une vigilance clinique renforcee.';
      }

      return 'Aucun signe critique majeur identifie dans cette grille.';
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
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.8,
                ),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Drapeaux rouges MB - Aide au reperage clinique',
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
            ),
          );
        },
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(22),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#EEF4FF'),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Synthese clinique',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1D4ED8'),
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Drapeaux rouges MB',
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: PdfColor.fromHex('#334155'),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Date : ${now.day}/${now.month}/${now.year}'),
                    pw.Text(
                      'Heure : ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                    ),
                    pw.Text('Code patient : $patientCode'),
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
                    'MB',
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

          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(18),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(16),
                    border: pw.Border.all(
                      color: riskPdfColor(),
                      width: 2,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Niveau de risque',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        riskLevel,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: riskPdfColor(),
                        ),
                      ),
                    ],
                  ),
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

          sectionTitle('Drapeaux rouges coches'),

          pw.SizedBox(height: 10),

          checkedRows.isEmpty
              ? pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8FAFC'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text('Aucun drapeau rouge coche.'),
                )
              : pw.TableHelper.fromTextArray(
                  headers: ['Categorie', 'Drapeau rouge', 'Niveau'],
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

          sectionTitle('Conclusion clinique'),

          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(
                color: PdfColor.fromHex('#E2E8F0'),
              ),
            ),
            child: pw.Text(
              conclusion(),
              style: const pw.TextStyle(
                fontSize: 11,
                lineSpacing: 4,
              ),
            ),
          ),

          pw.SizedBox(height: 22),

          sectionTitle('Mentions legales et RGPD'),

          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FFF7ED'),
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(
                color: PdfColor.fromHex('#FED7AA'),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Mention de prudence',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#9A3412'),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Ce document constitue une aide clinique. Il ne remplace pas une evaluation medicale professionnelle.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'RGPD',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#9A3412'),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Ne pas saisir de donnees nominatives. Utiliser uniquement un identifiant pseudonymise. Les exports sont sous la responsabilite de l utilisateur professionnel.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Editeur : MB',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#334155'),
              ),
            ),
          ),
        ],
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
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
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
              fontSize: 24,
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
}