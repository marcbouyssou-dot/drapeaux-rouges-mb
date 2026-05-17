import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';

class PrescriptionPdfService {
  static Future<void> exportPrescriptionPdf({
    required PatientLocal patient,
    required PractitionerProfile practitioner,
    required String pathologie,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 36),
        theme: pw.ThemeData.withFont(
          base: baseFont,
          bold: boldFont,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _practitionerBlock(practitioner),
              pw.SizedBox(height: 28),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Le ${_formatDate(now)}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.SizedBox(height: 30),
              _sectionTitle('Patient'),
              pw.SizedBox(height: 8),
              _simpleLine('Nom : ${patient.nom.toUpperCase()}'),
              _simpleLine('Prénom : ${patient.prenom}'),
              _simpleLine('Date de naissance : ${patient.dateNaissance}'),
              pw.SizedBox(height: 36),
              pw.Center(
                child: pw.Text(
                  'Prescription de rééducation',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 34),
              pw.Text(
                'Rééducation pour :',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey700,
                    width: 0.8,
                  ),
                ),
                child: pw.Text(
                  pathologie.trim().isEmpty
                      ? 'Pathologie non renseignée'
                      : pathologie.trim(),
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Signature et cachet',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 54),
                    pw.Container(
                      width: 180,
                      height: 1,
                      color: PdfColors.grey700,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
    );
  }

  static pw.Widget _practitionerBlock(PractitionerProfile practitioner) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Masseur-kinésithérapeute',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          practitioner.fullName.isEmpty
              ? 'Nom et prénom non renseignés'
              : practitioner.fullName,
          style: const pw.TextStyle(fontSize: 11),
        ),
        if (practitioner.adresse.trim().isNotEmpty)
          pw.Text(
            practitioner.adresse.trim(),
            style: const pw.TextStyle(fontSize: 11),
          ),
        if (practitioner.adeli.trim().isNotEmpty)
          pw.Text(
            'ADELI : ${practitioner.adeli.trim()}',
            style: const pw.TextStyle(fontSize: 11),
          ),
        if (practitioner.rpps.trim().isNotEmpty)
          pw.Text(
            'RPPS : ${practitioner.rpps.trim()}',
            style: const pw.TextStyle(fontSize: 11),
          ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.Widget _simpleLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}