import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient_local.dart';
import 'rgpd_local_service.dart';

class BdkPdfService {
  static Future<void> exportBdkPdf({
    required String title,
    required PatientLocal? patient,
    required String motif,
    required String contexte,
    required String antecedents,
    required String evaluation,
    required String tests,
    required String limitations,
    required String diagnostic,
    required String vigilance,
    required String objectifs,
    required String planTraitement,
    required String criteresReevaluation,
    required String syntheseClinique,
  }) async {
    final pdf = pw.Document();
    final regularFont = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        ),
        build: (context) {
          return [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Patient : ${RgpdLocalService.patientDisplayName(patient)}',
            ),
            if (patient != null)
              pw.Text('Identifiant : ${patient.anonymousId}'),
            pw.SizedBox(height: 24),
            _section('Motif', motif),
            _section('Contexte', contexte),
            _section('Antécédents utiles', antecedents),
            _section('Évaluation clinique', evaluation),
            _section('Tests cliniques', tests),
            _section('Limitations fonctionnelles', limitations),
            _section('Diagnostic kinésithérapique', diagnostic),
            _section('Points de vigilance', vigilance),
            _section('Objectifs thérapeutiques', objectifs),
            _section('Plan de traitement', planTraitement),
            _section('Critères de réévaluation', criteresReevaluation),
            _section('Synthèse clinique', syntheseClinique),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static pw.Widget _section(String title, String content) {
    final text = content.trim().isEmpty ? 'Non renseigné.' : content.trim();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            text,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
          ),
        ],
      ),
    );
  }
}
