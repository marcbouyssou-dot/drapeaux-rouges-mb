import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../models/bdk_history_item.dart';
import '../../services/bdk_pdf_service.dart';

class BdkHistoryDetailScreen extends StatelessWidget {
  const BdkHistoryDetailScreen({super.key, required this.item});

  final BdkHistoryItem item;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} à $hour:$minute';
  }

  Future<void> _regeneratePdf(BuildContext context) async {
    try {
      await BdkPdfService.exportBdkPdf(
        title: item.title,
        patient: item.patient,
        motif: item.motif,
        contexte: item.contexte,
        antecedents: item.antecedents,
        evaluation: item.evaluation,
        tests: item.tests,
        limitations: item.limitations,
        diagnostic: item.diagnostic,
        vigilance: item.vigilance,
        objectifs: item.objectifs,
        planTraitement: item.planTraitement,
        criteresReevaluation: item.criteresReevaluation,
        syntheseClinique: item.syntheseClinique,
        practitioner: item.practitioner,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le PDF n’a pas pu être généré. Veuillez réessayer.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = <(String, String)>[
      ('Motif de consultation', item.motif),
      ('Contexte', item.contexte),
      ('Antécédents', item.antecedents),
      ('Évaluation clinique', item.evaluation),
      ('Tests et mesures', item.tests),
      ('Limitations fonctionnelles', item.limitations),
      ('Diagnostic kinésithérapique', item.diagnostic),
      ('Vigilance', item.vigilance),
      ('Objectifs', item.objectifs),
      ('Plan de traitement', item.planTraitement),
      ('Critères de réévaluation', item.criteresReevaluation),
      ('Synthèse clinique', item.syntheseClinique),
    ];

    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        appBar: AppBar(
          title: const Text('BDK historique'),
          actions: [
            IconButton(
              tooltip: 'Régénérer le PDF',
              onPressed: () => _regeneratePdf(context),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: RadarLayout.formWidth),
            child: ListView(
              padding: const EdgeInsets.all(RadarSpacing.xl),
              children: [
                Container(
                  padding: const EdgeInsets.all(RadarSpacing.lg),
                  decoration: BoxDecoration(
                    color: RadarColors.surface,
                    borderRadius: BorderRadius.circular(RadarRadius.card),
                    boxShadow: RadarShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayPatient,
                        style: RadarTextStyles.contextTitle,
                      ),
                      const SizedBox(height: RadarSpacing.xs),
                      Text(item.title, style: RadarTextStyles.secondary),
                      const SizedBox(height: RadarSpacing.md),
                      Text(
                        'Créé le ${_formatDate(item.generatedAt)}',
                        style: RadarTextStyles.caption,
                      ),
                      Text(
                        'Dernière modification ${_formatDate(item.updatedAt)}',
                        style: RadarTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RadarSpacing.lg),
                ...sections
                    .where((section) => section.$2.trim().isNotEmpty)
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
                        child: Container(
                          padding: const EdgeInsets.all(RadarSpacing.lg),
                          decoration: BoxDecoration(
                            color: RadarColors.surface,
                            borderRadius: BorderRadius.circular(
                              RadarRadius.card,
                            ),
                            boxShadow: RadarShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.$1,
                                style: RadarTextStyles.contextTitle.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: RadarSpacing.sm),
                              Text(
                                section.$2,
                                style: RadarTextStyles.secondary.copyWith(
                                  color: RadarColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
