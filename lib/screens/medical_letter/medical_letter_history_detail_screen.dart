import 'package:flutter/material.dart';

import '../../models/medical_letter/medical_letter_history_item.dart';
import '../../services/medical_letter_pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

class MedicalLetterHistoryDetailScreen extends StatelessWidget {
  const MedicalLetterHistoryDetailScreen({super.key, required this.letter});

  final MedicalLetterHistoryItem letter;

  Future<void> regeneratePdf() async {
    await MedicalLetterPdfService.exportPdf(letter.toLetter());
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
    final practitioner = letter.practitioner;

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
                  text: letter.displayPatient,
                ),
                buildInfoCard(
                  icon: Icons.local_hospital_outlined,
                  title: 'Médecin traitant',
                  text: letter.patientMedecinNom.trim().isEmpty
                      ? 'Médecin traitant non renseigné'
                      : letter.patientMedecinNom.trim(),
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
                  text: formatDate(letter.generatedAt),
                ),
                buildInfoCard(
                  icon: Icons.location_on_outlined,
                  title: 'Lieu',
                  text: letter.lieu.trim().isEmpty
                      ? 'Lieu non renseigné'
                      : letter.lieu.trim(),
                ),
                buildInfoCard(
                  icon: letter.hasPractitionerSignature
                      ? Icons.draw_outlined
                      : Icons.edit_off_outlined,
                  title: 'Signature',
                  text: letter.practitionerSignatureStatus,
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
              letter.title,
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
            letter.pdfTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Objet : ${letter.subject.trim().isEmpty ? 'Non renseigné' : letter.subject.trim()}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...letter.displayBodyParagraphs.map(
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
