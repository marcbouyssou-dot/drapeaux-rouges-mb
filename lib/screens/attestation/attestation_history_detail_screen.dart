import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_destructive_confirmation_dialog.dart';
import '../../features/radar/presentation/widgets/radar_page_header.dart';
import '../../features/radar/presentation/widgets/radar_surface_card.dart';
import '../../models/attestation/attestation_history_item.dart';
import '../../services/attestation_history_service.dart';
import '../../services/patient_attestation_pdf_service.dart';

class AttestationHistoryDetailScreen extends StatelessWidget {
  const AttestationHistoryDetailScreen({super.key, required this.attestation});

  final AttestationHistoryItem attestation;

  Future<void> regeneratePdf() async {
    await PatientAttestationPdfService.exportPdf(attestation.toAttestation());
  }

  Future<void> deleteAttestation(BuildContext context) async {
    final confirmed = await showRadarDestructiveConfirmationDialog(
      context,
      title: 'Supprimer cette attestation ?',
      message:
          'Cette action supprimera définitivement cette attestation de l’historique local.',
      confirmLabel: 'Supprimer',
    );

    if (!confirmed || !context.mounted) return;

    await AttestationHistoryService.deleteById(attestation.id);

    if (!context.mounted) return;
    Navigator.pop(context, true);
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
            padding: const EdgeInsets.fromLTRB(
              RadarSpacing.xl,
              RadarSpacing.sm,
              RadarSpacing.xl,
              RadarSpacing.xl,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => deleteAttestation(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RadarColors.clinicalDanger,
                      side: const BorderSide(color: RadarColors.clinicalDanger),
                    ),
                  ),
                ),
                const SizedBox(width: RadarSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: regeneratePdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Régénérer le PDF'),
                  ),
                ),
              ],
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
          RadarPageBackButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: Text(
              attestation.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
          Text(
            attestation.pdfTitle,
            style: RadarTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: RadarSpacing.md),
          ...attestation.displayBodyParagraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: RadarSpacing.sm),
              child: Text(
                paragraph,
                style: RadarTextStyles.secondary.copyWith(
                  color: RadarColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
