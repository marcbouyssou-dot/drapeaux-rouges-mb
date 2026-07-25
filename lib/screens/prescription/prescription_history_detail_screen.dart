import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_surface_card.dart';
import '../../models/prescription_model.dart';
import '../../services/prescription_pdf_service.dart';

class PrescriptionHistoryDetailScreen extends StatelessWidget {
  const PrescriptionHistoryDetailScreen({
    super.key,
    required this.prescription,
  });

  final PrescriptionModel prescription;

  Future<void> exportPdf() async {
    await PrescriptionPdfService.exportPrescriptionPdf(
      patient: prescription.patientLocal,
      practitioner: prescription.practitioner,
      prescriptionType: prescription.displayType,
      prescriptionContent: prescription.prescription,
      justificatifImageBytes: justificatifImageBytes,
    );
  }

  Uint8List? get justificatifImageBytes {
    final raw = prescription.justificatifImageBase64?.trim() ?? '';
    if (raw.isEmpty) return null;

    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final hasJustificatif = justificatifImageBytes != null;

    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RadarLayout.workflowWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  120,
                ),
                children: [
                  buildHeader(context),
                  const SizedBox(height: RadarSpacing.xxl),
                  buildInfoCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Patient',
                    text: prescription.displayPatient,
                  ),
                  buildInfoCard(
                    icon: Icons.medical_services_outlined,
                    title: 'Type',
                    text: prescription.displayType,
                  ),
                  buildInfoCard(
                    icon: Icons.event_outlined,
                    title: 'Date',
                    text: formatDate(prescription.createdAt),
                  ),
                  buildContentCard(),
                  buildInfoCard(
                    icon: hasJustificatif
                        ? Icons.attach_file_rounded
                        : Icons.attachment_outlined,
                    title: 'Justificatif joint',
                    text: hasJustificatif
                        ? 'Justificatif disponible pour réexport PDF.'
                        : 'Aucun justificatif joint à cette prescription.',
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RadarSpacing.xl,
              RadarSpacing.sm,
              RadarSpacing.xl,
              RadarSpacing.xl,
            ),
            child: FilledButton.icon(
              onPressed: exportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Exporter le PDF'),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return RadarSurfaceCard(
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Retour',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: RadarColors.surfaceMuted,
              foregroundColor: RadarColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadarRadius.small),
              ),
            ),
          ),
          const SizedBox(width: RadarSpacing.lg),
          const Expanded(
            child: Text(
              'Prescription historisée',
              style: RadarTextStyles.question,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return RadarSurfaceCard(
      margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
      padding: const EdgeInsets.all(RadarSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: RadarColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(icon, color: RadarColors.primary, size: 20),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RadarTextStyles.caption),
                const SizedBox(height: RadarSpacing.xs),
                Text(
                  text,
                  style: RadarTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContentCard() {
    return RadarSurfaceCard(
      margin: const EdgeInsets.only(bottom: RadarSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contenu', style: RadarTextStyles.caption),
          const SizedBox(height: RadarSpacing.md),
          Text(
            prescription.prescription.trim().isEmpty
                ? 'Contenu non renseigné'
                : prescription.prescription.trim(),
            style: RadarTextStyles.secondary.copyWith(
              color: RadarColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
