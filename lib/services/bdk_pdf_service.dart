import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';
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
    PractitionerProfile? practitioner,
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
            if (practitioner != null) ...[
              _practitionerBlock(practitioner),
              pw.SizedBox(height: 18),
            ],
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

  static pw.Widget _practitionerBlock(PractitionerProfile practitioner) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            practitioner.professionLabel,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          if (practitioner.fullName.isNotEmpty)
            pw.Text(
              practitioner.fullName,
              style: const pw.TextStyle(fontSize: 10),
            ),
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
              _structureLine(practitioner),
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  static String _structureLine(PractitionerProfile practitioner) {
    final name = practitioner.nomStructure.trim();
    if (name.isEmpty) return 'Structure d’exercice coordonné';

    return practitioner.exerciceCoordonne
        ? 'Structure coordonnée : $name'
        : 'Structure : $name';
  }
}
