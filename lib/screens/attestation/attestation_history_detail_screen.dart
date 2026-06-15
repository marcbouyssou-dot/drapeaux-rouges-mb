import 'package:flutter/material.dart';

import '../../models/attestation/attestation_history_item.dart';
import '../../services/patient_attestation_pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class AttestationHistoryDetailScreen extends StatelessWidget {
  const AttestationHistoryDetailScreen({super.key, required this.attestation});

  final AttestationHistoryItem attestation;

  Future<void> regeneratePdf() async {
    await PatientAttestationPdfService.exportPdf(attestation.toAttestation());
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
    final practitioner = attestation.practitioner;

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
                  text: attestation.displayPatient,
                ),
                buildInfoCard(
                  icon: Icons.badge_outlined,
                  title: 'Praticien',
                  text: practitioner.fullName.isEmpty
                      ? 'Praticien non renseigné'
                      : practitioner.fullName,
                ),
                buildInfoCard(
                  icon: Icons.event_outlined,
                  title: 'Date',
                  text: formatDate(attestation.generatedAt),
                ),
                buildInfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Lieu',
                  text: attestation.lieu.trim().isEmpty
                      ? 'Lieu non renseigné'
                      : attestation.lieu.trim(),
                ),
                buildInfoCard(
                  icon: attestation.hasSignature
                      ? Icons.draw_outlined
                      : Icons.edit_off_outlined,
                  title: 'Signature',
                  text: attestation.signatureStatus,
                ),
                if (attestation.consentConfirmed)
                  buildInfoCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Consentement',
                    text: 'Information comprise et signature acceptée',
                  ),
                buildContentCard(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: FilledButton.icon(
            onPressed: regeneratePdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Régénérer le PDF'),
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
          Expanded(
            child: Text(
              attestation.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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
          Text(
            attestation.pdfTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...attestation.displayBodyParagraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
