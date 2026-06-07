import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient_local.dart';
import '../models/practitioner_profile.dart';

class PrescriptionPdfService {
  static Future<void> exportPrescriptionPdf({
    required PatientLocal patient,
    required PractitionerProfile practitioner,
    required String prescriptionType,
    required String prescriptionContent,
    File? justificatifImage,
    Uint8List? justificatifImageBytes,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final baseFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final pw.MemoryImage? justificatifPdfImage = justificatifImage != null
        ? pw.MemoryImage(justificatifImage.readAsBytesSync())
        : justificatifImageBytes != null
        ? pw.MemoryImage(justificatifImageBytes)
        : null;
    final signaturePdfImage = _signatureImage(practitioner);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 36),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        build: (context) {
          return [
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
                _documentTitle(prescriptionType),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 30),

            _sectionTitle('Type'),
            pw.SizedBox(height: 8),
            _boxedText(prescriptionType),

            pw.SizedBox(height: 20),

            _sectionTitle(_contentTitle(prescriptionType)),
            pw.SizedBox(height: 8),
            _boxedText(
              prescriptionContent.trim().isEmpty
                  ? 'Contenu non renseigné'
                  : prescriptionContent.trim(),
            ),

            pw.SizedBox(height: 22),

            _regulatoryNote(prescriptionType),

            if (justificatifPdfImage != null) ...[
              pw.SizedBox(height: 28),
              _sectionTitle('Justificatif clinique joint'),
              pw.SizedBox(height: 12),
              pw.Container(
                height: 220,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Image(justificatifPdfImage, fit: pw.BoxFit.contain),
              ),
            ],

            pw.SizedBox(height: 40),

            _signatureBlock(signaturePdfImage),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  static String _documentTitle(String type) {
    switch (type) {
      case 'Matériel':
        return 'Prescription de matériel / dispositif médical';
      case 'Examens':
        return 'Orientation / examen à envisager';
      case 'Conseils':
        return 'Conseils associés';
      case 'Autres':
        return 'Prescription / recommandation';
      case 'Rééducation':
      default:
        return 'Prescription de rééducation';
    }
  }

  static String _contentTitle(String type) {
    switch (type) {
      case 'Matériel':
        return 'Matériel / dispositif médical';
      case 'Examens':
        return 'Examen ou orientation à envisager';
      case 'Conseils':
        return 'Conseils';
      case 'Autres':
        return 'Contenu';
      case 'Rééducation':
      default:
        return 'Rééducation pour';
    }
  }

  static pw.Widget _boxedText(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 0.8),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 14)),
    );
  }

  static pw.Widget _regulatoryNote(String type) {
    final text = type == 'Examens'
        ? 'Mention : ce document constitue une orientation ou un examen à envisager selon le contexte clinique. Il ne remplace pas un avis médical lorsque celui-ci est nécessaire.'
        : 'Mention : prescription ou recommandation établie dans le cadre des compétences et conditions réglementaires du masseur-kinésithérapeute.';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _practitionerBlock(PractitionerProfile practitioner) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          practitioner.professionLabel,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
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
        if (practitioner.email.trim().isNotEmpty)
          pw.Text(
            'Email : ${practitioner.email.trim()}',
            style: const pw.TextStyle(fontSize: 11),
          ),
        if (practitioner.telephone.trim().isNotEmpty)
          pw.Text(
            'Téléphone : ${practitioner.telephone.trim()}',
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
        if (practitioner.hasStructure)
          pw.Text(
            _structureLine(practitioner),
            style: const pw.TextStyle(fontSize: 11),
          ),
      ],
    );
  }

  static pw.MemoryImage? _signatureImage(PractitionerProfile practitioner) {
    if (!practitioner.hasSignature) return null;

    try {
      return pw.MemoryImage(base64Decode(practitioner.signatureBase64));
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _signatureBlock(pw.MemoryImage? signaturePdfImage) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Signature et cachet',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 10),
          if (signaturePdfImage != null)
            pw.Container(
              width: 180,
              height: 72,
              alignment: pw.Alignment.center,
              child: pw.Image(signaturePdfImage, fit: pw.BoxFit.contain),
            )
          else ...[
            pw.SizedBox(height: 54),
            pw.Container(width: 180, height: 1, color: PdfColors.grey700),
          ],
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

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _simpleLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
