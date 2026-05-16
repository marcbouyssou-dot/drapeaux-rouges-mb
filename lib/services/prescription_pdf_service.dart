import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient_local.dart';

class PrescriptionPdfService {
  static Future<void> exportPrescriptionPdf({
    required PatientLocal patient,
    required String diagnostic,
    required String prescription,
    required String observations,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
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
                'Drapeaux Rouges — Prescription accès direct MK',
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
                        'Prescription de rééducation',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1D4ED8'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Accès direct en masso-kinésithérapie'),
                      pw.SizedBox(height: 12),
                      pw.Text('Date : ${_formatDate(now)}'),
                      pw.Text('Heure : ${_formatTime(now)}'),
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

            pw.SizedBox(height: 24),

            sectionTitle('Patient'),
            pw.SizedBox(height: 8),
            infoBox(
              children: [
                pw.Text('Nom : ${patient.nom.toUpperCase()}'),
                pw.Text('Prénom : ${patient.prenom}'),
                pw.Text('Date de naissance : ${patient.dateNaissance}'),
              ],
            ),

            pw.SizedBox(height: 22),

            sectionTitle('Motif / Diagnostic'),
            pw.SizedBox(height: 8),
            textBox(
              diagnostic.trim().isEmpty
                  ? 'Non renseigné'
                  : diagnostic.trim(),
            ),

            pw.SizedBox(height: 22),

            sectionTitle('Prescription'),
            pw.SizedBox(height: 8),
            textBox(
              prescription.trim().isEmpty
                  ? 'Non renseignée'
                  : prescription.trim(),
            ),

            pw.SizedBox(height: 22),

            sectionTitle('Observations'),
            pw.SizedBox(height: 8),
            textBox(
              observations.trim().isEmpty
                  ? 'Aucune observation renseignée'
                  : observations.trim(),
            ),

            pw.SizedBox(height: 24),

            sectionTitle('Mentions'),
            pw.SizedBox(height: 8),
            textBox(
              'Ce document constitue une aide documentaire dans le cadre de l’accès direct en masso-kinésithérapie.\n\n'
              'Il ne remplace pas un avis médical lorsque celui-ci est nécessaire. '
              'Les décisions cliniques restent sous la responsabilité du professionnel utilisateur.',
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
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
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(
          color: PdfColor.fromHex('#E2E8F0'),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static pw.Widget textBox(String text) {
    return pw.Container(
      width: double.infinity,
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
          fontSize: 11,
          lineSpacing: 4,
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}