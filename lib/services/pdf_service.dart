import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/practitioner_profile.dart';

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
    bool printable = false,
    PractitionerProfile? practitioner,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final checkedRows = categories.entries.expand((entry) {
      return entry.value.where((item) => item['checked'] == true).map((item) {
        return [
          entry.key,
          item['title']?.toString() ?? '',
          item['severity']?.toString() ?? '',
        ];
      });
    }).toList();

    final primaryColor = printable
        ? PdfColors.black
        : PdfColor.fromHex('#1D4ED8');

    PdfColor riskPdfColor() {
      if (printable) return PdfColors.black;
      if (score >= 6) return PdfColor.fromHex('#7F1D1D');
      if (score >= 4) return PdfColors.red;
      if (score >= 2) return PdfColors.orange;
      return PdfColors.green;
    }

    final riskColor = riskPdfColor();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
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
            buildHeader(
              now: now,
              motif: motif,
              patientCode: patientCode,
              primaryColor: primaryColor,
              printable: printable,
              practitioner: practitioner,
            ),
            pw.SizedBox(height: 22),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: statBox(
                    title: 'Niveau de risque',
                    value: riskLevel,
                    color: riskColor,
                    printable: printable,
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: statBox(
                    title: 'Score',
                    value: '$score',
                    color: riskColor,
                    printable: printable,
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: statBox(
                    title: 'Drapeaux',
                    value: '$checkedCount',
                    color: riskColor,
                    printable: printable,
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
              color: riskColor,
              printable: printable,
            ),
            pw.SizedBox(height: 24),
            sectionTitle('Synthèse assistée'),
            pw.SizedBox(height: 8),
            neutralBox(aiSummary, printable: printable),
            pw.SizedBox(height: 24),
            sectionTitle('Drapeaux rouges cochés'),
            pw.SizedBox(height: 10),
            checkedRows.isEmpty
                ? neutralBox('Aucun drapeau rouge coché.', printable: printable)
                : pw.TableHelper.fromTextArray(
                    headers: const ['Catégorie', 'Drapeau rouge', 'Niveau'],
                    data: checkedRows,
                    headerDecoration: pw.BoxDecoration(
                      color: printable ? PdfColors.white : primaryColor,
                    ),
                    headerStyle: pw.TextStyle(
                      color: printable ? PdfColors.black : PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellPadding: const pw.EdgeInsets.all(8),
                    border: pw.TableBorder.all(
                      color: PdfColors.grey500,
                      width: 0.5,
                    ),
                  ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static pw.Widget buildHeader({
    required DateTime now,
    required String motif,
    required String patientCode,
    required PdfColor primaryColor,
    required bool printable,
    PractitionerProfile? practitioner,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: printable ? PdfColors.white : PdfColor.fromHex('#EEF4FF'),
        borderRadius: pw.BorderRadius.circular(16),
        border: printable
            ? pw.Border.all(color: PdfColors.grey700, width: 0.8)
            : null,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Synthèse clinique',
                  style: pw.TextStyle(
                    fontSize: 27,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Motif : $motif'),
                pw.Text('Date : ${formatDate(now)}'),
                pw.Text('Heure : ${formatTime(now)}'),
                pw.Text('Identifiant pseudonymisé : $patientCode'),
                if (practitioner != null) ...[
                  pw.SizedBox(height: 8),
                  ...practitionerLines(practitioner),
                ],
              ],
            ),
          ),
          pw.Container(
            width: 58,
            height: 58,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: printable ? PdfColors.white : primaryColor,
              borderRadius: pw.BorderRadius.circular(15),
              border: printable
                  ? pw.Border.all(color: PdfColors.black, width: 0.8)
                  : null,
            ),
            child: pw.Text(
              'MK',
              style: pw.TextStyle(
                color: printable ? PdfColors.black : PdfColors.white,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> practitionerLines(PractitionerProfile practitioner) {
    return [
      pw.Text(
        'Praticien : ${practitioner.professionLabel}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
      if (practitioner.fullName.isNotEmpty)
        pw.Text(practitioner.fullName, style: const pw.TextStyle(fontSize: 10)),
      if (practitioner.adresse.trim().isNotEmpty)
        pw.Text(
          practitioner.adresse.trim(),
          style: const pw.TextStyle(fontSize: 10),
        ),
      if (practitioner.email.trim().isNotEmpty)
        pw.Text(
          'Email : ${practitioner.email.trim()}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      if (practitioner.telephone.trim().isNotEmpty)
        pw.Text(
          'Téléphone : ${practitioner.telephone.trim()}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      if (practitioner.adeli.trim().isNotEmpty)
        pw.Text(
          'ADELI : ${practitioner.adeli.trim()}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      if (practitioner.rpps.trim().isNotEmpty)
        pw.Text(
          'RPPS : ${practitioner.rpps.trim()}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      if (practitioner.hasStructure)
        pw.Text(
          structureLine(practitioner),
          style: const pw.TextStyle(fontSize: 10),
        ),
    ];
  }

  static String structureLine(PractitionerProfile practitioner) {
    final name = practitioner.nomStructure.trim();
    if (name.isEmpty) return 'Structure d’exercice coordonné';

    return practitioner.exerciceCoordonne
        ? 'Structure coordonnée : $name'
        : 'Structure : $name';
  }

  static pw.Widget statBox({
    required String title,
    required String value,
    required PdfColor color,
    required bool printable,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: printable ? PdfColors.white : PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: printable ? PdfColors.grey700 : color,
          width: printable ? 0.8 : 1.2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
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
        color: PdfColors.black,
      ),
    );
  }

  static pw.Widget infoBox({
    required String title,
    required String text,
    required PdfColor color,
    required bool printable,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: printable ? PdfColors.white : PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: printable ? PdfColors.grey700 : color,
          width: printable ? 0.8 : 1.2,
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
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
          ),
        ],
      ),
    );
  }

  static pw.Widget neutralBox(String text, {required bool printable}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: printable ? PdfColors.white : PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: printable ? PdfColors.grey700 : PdfColor.fromHex('#E2E8F0'),
          width: printable ? 0.8 : 1,
        ),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
      ),
    );
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
