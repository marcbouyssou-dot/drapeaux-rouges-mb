import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/medical_letter/medical_letter.dart';
import 'pdf_font_helper.dart';

class MedicalLetterPdfService {
  static Future<void> exportPdf(MedicalLetter letter) async {
    final bytes = await buildPdfBytes(letter);

    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<Uint8List> buildPdfBytes(MedicalLetter letter) async {
    final signatureImage = _signatureImage(letter.practitioner.signatureBase64);
    final theme = await PdfFontHelper.unicodeTheme();

    try {
      return await _buildDocument(letter, signatureImage, theme).save();
    } catch (_) {
      if (signatureImage == null) rethrow;

      return _buildDocument(letter, null, theme).save();
    }
  }

  static pw.Document _buildDocument(
    MedicalLetter letter,
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
            _practitionerHeader(letter),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                letter.template.pdfTitle,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 22),
            _identityBlock(letter),
            pw.SizedBox(height: 18),
            _subjectBlock(letter),
            pw.SizedBox(height: 22),
            ...letter.bodyParagraphs.map(_paragraph),
            pw.SizedBox(height: 22),
            _regulatoryNote(),
            pw.SizedBox(height: 24),
            _placeAndDate(letter),
            pw.SizedBox(height: 28),
            _practitionerSignature(letter, signatureImage),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _practitionerHeader(MedicalLetter letter) {
    final practitioner = letter.practitioner;

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
            letter.practitionerFullName,
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
          if (letter.practitionerIdentifier.isNotEmpty)
            pw.Text(
              letter.practitionerIdentifier,
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

  static pw.Widget _identityBlock(MedicalLetter letter) {
    final birthDate = letter.patientBirthDate.trim().isEmpty
        ? 'Non renseignée'
        : letter.patientBirthDate.trim();
    final doctorDetails = letter.treatingDoctorDetails;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _line('Patient : ${letter.patientFullName}'),
          _line('Date de naissance : $birthDate'),
          _line('Médecin traitant : ${letter.treatingDoctorName}'),
          if (doctorDetails.isNotEmpty) _line(doctorDetails),
          _line('Type de courrier : ${letter.template.title}'),
        ],
      ),
    );
  }

  static pw.Widget _subjectBlock(MedicalLetter letter) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
      ),
      child: pw.Text(
        'Objet : ${letter.effectiveSubject}',
        style: pw.TextStyle(fontSize: 11.5, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _regulatoryNote() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.7),
      ),
      child: pw.Text(
        'Mention de prudence : ce courrier est une aide documentaire clinique. Il ne constitue pas un diagnostic automatisé et ne remplace pas l’avis médical.',
        style: const pw.TextStyle(fontSize: 10.2, lineSpacing: 2),
      ),
    );
  }

  static pw.Widget _placeAndDate(MedicalLetter letter) {
    final city = letter.effectiveCity;

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        city.isEmpty
            ? 'Fait le ${letter.formattedDate}'
            : 'Fait à $city, le ${letter.formattedDate}',
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }

  static pw.Widget _practitionerSignature(
    MedicalLetter letter,
    pw.MemoryImage? signatureImage,
  ) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Signature du praticien :',
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
          pw.SizedBox(height: 8),
          pw.Text(
            letter.practitionerFullName,
            style: const pw.TextStyle(fontSize: 10.5),
          ),
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
