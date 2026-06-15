import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/attestation/patient_attestation.dart';
import 'pdf_font_helper.dart';

class PatientAttestationPdfService {
  static Future<void> exportPdf(PatientAttestation attestation) async {
    final bytes = await buildPdfBytes(attestation);

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<Uint8List> buildPdfBytes(PatientAttestation attestation) async {
    final signatureImage = _signatureImage(attestation.signatureBase64);
    final theme = await PdfFontHelper.unicodeTheme();

    try {
      return await _buildDocument(attestation, signatureImage, theme).save();
    } catch (_) {
      if (signatureImage == null) rethrow;

      return _buildDocument(attestation, null, theme).save();
    }
  }

  static pw.Document _buildDocument(
    PatientAttestation attestation,
    pw.MemoryImage? signatureImage,
    pw.ThemeData theme,
  ) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 38, 42, 38),
        theme: theme,
        build: (context) {
          return [
            _practitionerHeader(attestation),
            pw.SizedBox(height: 26),
            pw.Center(
              child: pw.Text(
                attestation.template.pdfTitle,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 26),
            _identityBlock(attestation),
            pw.SizedBox(height: 24),
            ...attestation.bodyParagraphs.map(_paragraph),
            pw.SizedBox(height: 28),
            _placeAndDate(attestation),
            if (attestation.consentConfirmed) ...[
              pw.SizedBox(height: 16),
              _consentMention(attestation),
            ],
            pw.SizedBox(height: 34),
            _patientSignature(signatureImage),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _practitionerHeader(PatientAttestation attestation) {
    final practitioner = attestation.practitioner;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            practitioner.professionLabel,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            attestation.practitionerFullName,
            style: const pw.TextStyle(fontSize: 10.5),
          ),
          if (practitioner.adresse.trim().isNotEmpty)
            pw.Text(
              practitioner.adresse.trim(),
              style: const pw.TextStyle(fontSize: 10.5),
            ),
          if (practitioner.email.trim().isNotEmpty)
            pw.Text(
              'Email : ${practitioner.email.trim()}',
              style: const pw.TextStyle(fontSize: 10.5),
            ),
          if (practitioner.telephone.trim().isNotEmpty)
            pw.Text(
              'Téléphone : ${practitioner.telephone.trim()}',
              style: const pw.TextStyle(fontSize: 10.5),
            ),
          if (attestation.practitionerIdentifier.isNotEmpty)
            pw.Text(
              attestation.practitionerIdentifier,
              style: const pw.TextStyle(fontSize: 10.5),
            ),
          if (practitioner.practiceStructureLine.isNotEmpty)
            pw.Text(
              practitioner.practiceStructureLine,
              style: const pw.TextStyle(fontSize: 10.5),
            ),
        ],
      ),
    );
  }

  static pw.Widget _identityBlock(PatientAttestation attestation) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _line('Patient : ${attestation.patientFullName}'),
          _line(
            'Date de naissance : ${attestation.patientBirthDate.isEmpty ? 'Non renseignée' : attestation.patientBirthDate}',
          ),
          _line('Modèle : ${attestation.template.title}'),
        ],
      ),
    );
  }

  static pw.Widget _placeAndDate(PatientAttestation attestation) {
    final city = attestation.effectiveCity.isEmpty
        ? ''
        : attestation.effectiveCity;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        city.isEmpty
            ? 'Fait le ${attestation.formattedDate}'
            : 'Fait à $city, le ${attestation.formattedDate}',
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }

  static pw.Widget _consentMention(PatientAttestation attestation) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
      ),
      child: pw.Text(
        'Consentement patient confirmé le ${attestation.formattedDate} : le patient confirme avoir reçu l’information, l’avoir comprise et accepte de signer cette attestation.',
        style: const pw.TextStyle(fontSize: 10.5, lineSpacing: 2),
      ),
    );
  }

  static pw.Widget _patientSignature(pw.MemoryImage? signatureImage) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Signature du patient :',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          if (signatureImage != null)
            pw.Container(
              width: 190,
              height: 78,
              alignment: pw.Alignment.center,
              child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
            )
          else ...[
            pw.SizedBox(height: 58),
            pw.Container(width: 190, height: 1, color: PdfColors.grey700),
          ],
        ],
      ),
    );
  }

  static pw.Widget _paragraph(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.justify,
        style: const pw.TextStyle(fontSize: 12, lineSpacing: 3),
      ),
    );
  }

  static pw.Widget _line(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10.5)),
    );
  }

  static pw.MemoryImage? _signatureImage(String signatureBase64) {
    if (signatureBase64.trim().isEmpty) return null;

    try {
      return pw.MemoryImage(base64Decode(signatureBase64));
    } catch (_) {
      return null;
    }
  }
}
