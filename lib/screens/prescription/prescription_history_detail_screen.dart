import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/prescription_model.dart';
import '../../services/prescription_pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                120,
              ),
              children: [
                buildHeader(context),
                const SizedBox(height: AppSpacing.md),
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
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: FilledButton.icon(
            onPressed: exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Exporter le PDF'),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.medicalBlue, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevated,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.textOnDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Prescription historisée',
              style: TextStyle(
                color: AppColors.textOnDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contenu',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prescription.prescription.trim().isEmpty
                ? 'Contenu non renseigné'
                : prescription.prescription.trim(),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
