import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import 'bdk_type_screen.dart';

class BDKEntryScreen extends StatelessWidget {
  const BDKEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xxl,
                ),
                children: [
                  _premiumHeader(context),
                  const SizedBox(height: RadarSpacing.xxl),
                  _startCard(context),
                  const SizedBox(height: RadarSpacing.xl),
                  _workflowCards(),
                  const SizedBox(height: RadarSpacing.xl),
                  _infoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _premiumHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: RadarColors.indigo.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(RadarRadius.card),
          ),
          child: const Icon(
            Icons.assignment_rounded,
            color: RadarColors.indigo,
            size: 28,
          ),
        ),
        const SizedBox(height: RadarSpacing.lg),
        const Text('BDK', style: RadarTextStyles.screenTitle),
        const SizedBox(height: RadarSpacing.sm),
        const Text(
          'Bilan diagnostique kinésithérapique structuré, synthèse clinique et export PDF.',
          style: RadarTextStyles.secondary,
        ),
      ],
    );
  }

  Widget _startCard(BuildContext context) {
    return Material(
      color: RadarColors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(RadarRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadarRadius.card),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BDKTypeScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(RadarSpacing.xl),
          decoration: BoxDecoration(
            color: RadarColors.surface,
            borderRadius: BorderRadius.circular(RadarRadius.card),
            boxShadow: RadarShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: RadarColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(RadarRadius.card),
                    ),
                    child: const Icon(
                      Icons.playlist_add_check_circle_outlined,
                      color: RadarColors.primary,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: RadarColors.textMuted,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: RadarSpacing.cardGap),
              const Text('Commencer un BDK', style: RadarTextStyles.question),
              const SizedBox(height: RadarSpacing.sm),
              const Text(
                'Choisissez le type de bilan, complétez les sections cliniques puis exportez le PDF.',
                style: RadarTextStyles.body,
              ),
              const SizedBox(height: RadarSpacing.cardGap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadarSpacing.lg,
                  vertical: RadarSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: RadarColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(RadarRadius.pill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Appuyer pour choisir le bilan',
                      style: RadarTextStyles.action,
                    ),
                    SizedBox(width: RadarSpacing.xs),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: RadarColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workflowCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _WorkflowCard(
            icon: Icons.fact_check_outlined,
            title: 'Structuré',
            text: 'Motif, évaluation, diagnostic et plan de soin.',
            color: RadarColors.primary,
          ),
          _WorkflowCard(
            icon: Icons.auto_awesome,
            title: 'Synthèse',
            text: 'Résumé clinique généré depuis les champs saisis.',
            color: RadarColors.indigo,
          ),
          _WorkflowCard(
            icon: Icons.picture_as_pdf_outlined,
            title: 'PDF',
            text: 'Export prêt à archiver ou partager selon le workflow.',
            color: RadarColors.slate,
          ),
        ];

        if (constraints.maxWidth >= 620) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: card == cards.last ? 0 : RadarSpacing.lg,
                      ),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: EdgeInsets.only(
                    bottom: card == cards.last ? 0 : RadarSpacing.lg,
                  ),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            color: RadarColors.slate,
            size: 22,
          ),
          SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Text(
              'Le BDK reste localement structuré dans la session en cours. Les actions PDF et réinitialisation sont disponibles dans le détail.',
              style: RadarTextStyles.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RadarSpacing.xs),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
