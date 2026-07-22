import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import 'prescription_type_screen.dart';

class PrescriptionEntryScreen extends StatelessWidget {
  const PrescriptionEntryScreen({super.key});

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
                  _premiumHeader(),
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

  Widget _premiumHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: RadarColors.slate.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(RadarRadius.card),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: RadarColors.slate,
            size: 28,
          ),
        ),
        const SizedBox(height: RadarSpacing.lg),
        const Text('Prescription', style: RadarTextStyles.screenTitle),
        const SizedBox(height: RadarSpacing.sm),
        const Text(
          'Documents cliniques personnalisés, patient lié et export PDF.',
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
            MaterialPageRoute(builder: (_) => const PrescriptionTypeScreen()),
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
                      color: RadarColors.indigo.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(RadarRadius.card),
                    ),
                    child: const Icon(
                      Icons.edit_document,
                      color: RadarColors.indigo,
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
              const Text(
                'Créer une prescription',
                style: RadarTextStyles.question,
              ),
              const SizedBox(height: RadarSpacing.sm),
              const Text(
                'Choisissez un type, renseignez le contenu clinique puis exportez un PDF lisible.',
                style: RadarTextStyles.body,
              ),
              const SizedBox(height: RadarSpacing.cardGap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadarSpacing.lg,
                  vertical: RadarSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: RadarColors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(RadarRadius.pill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Appuyer pour choisir le type',
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
            icon: Icons.person_outline_rounded,
            title: 'Patient',
            text: 'Le document PDF est lié au patient actif.',
            color: RadarColors.primary,
          ),
          _WorkflowCard(
            icon: Icons.library_books_outlined,
            title: 'Modèles',
            text: 'Templates rapides adaptés au type choisi.',
            color: RadarColors.indigo,
          ),
          _WorkflowCard(
            icon: Icons.picture_as_pdf_outlined,
            title: 'PDF',
            text: 'Export sobre, clair et prêt à imprimer.',
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
            Icons.medical_information_outlined,
            color: RadarColors.slate,
            size: 22,
          ),
          SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Text(
              'La prescription vérifie le patient actif, les informations professionnelles et le contenu avant export.',
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
