import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/prescription_model.dart';

class PrescriptionPdfService {
  static Future<void> generatePdf(
    PrescriptionModel prescription,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Prescription MK',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          buildSection(
            'Professionnel',
            prescription.professional,
          ),

          buildSection(
            'Patient',
            prescription.patient,
          ),

          buildSection(
            'Cadre clinique',
            prescription.clinicalContext,
          ),

          buildSection(
            'Prescription',
            prescription.prescription,
          ),

          buildSection(
            'Fréquence',
            prescription.frequency,
          ),

          buildSection(
            'Durée',
            prescription.duration,
          ),

          buildSection(
            'Nomenclature',
            prescription.nomenclature,
          ),

          pw.SizedBox(height: 30),

          pw.Text(
            'Document généré par Drapeaux Rouges',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }

  static pw.Widget buildSection(
    String title,
    String content,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            content,
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}