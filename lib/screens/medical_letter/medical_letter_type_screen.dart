import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../models/medical_letter/medical_letter_template.dart';
import 'medical_letter_screen.dart';

class MedicalLetterTypeScreen extends StatelessWidget {
  const MedicalLetterTypeScreen({super.key});

  void openLetter(BuildContext context, MedicalLetterTemplate template) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => MedicalLetterScreen(template: template),
      ),
    );
  }

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      tooltip: 'Retour',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: RadarColors.surface,
                        foregroundColor: RadarColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            RadarRadius.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RadarSpacing.xl),
                  const Text(
                    'Courriers médicaux',
                    style: RadarTextStyles.screenTitle,
                  ),
                  const SizedBox(height: RadarSpacing.sm),
                  const Text(
                    'Choisir un modèle et générer un courrier clinique.',
                    style: RadarTextStyles.secondary,
                  ),
                  const SizedBox(height: RadarSpacing.xxl),
                  ...medicalLetterTemplates.map(
                    (template) => Padding(
                      padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
                      child: _MedicalLetterTypeCard(
                        template: template,
                        onTap: () => openLetter(context, template),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicalLetterTypeCard extends StatelessWidget {
  const _MedicalLetterTypeCard({required this.template, required this.onTap});

  final MedicalLetterTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RadarRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        child: Container(
          padding: const EdgeInsets.all(RadarSpacing.xl),
          decoration: BoxDecoration(
            color: RadarColors.surface,
            borderRadius: BorderRadius.circular(RadarRadius.card),
            boxShadow: RadarShadows.card,
          ),
          child: Row(
            children: [
              Container(
                height: compact ? 44 : 50,
                width: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: compact ? 23 : 26,
                ),
              ),
              const SizedBox(width: RadarSpacing.lg),
              Expanded(
                child: Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question.copyWith(
                    color: template.color,
                    fontSize: compact ? 15.5 : 18,
                  ),
                ),
              ),
              const SizedBox(width: RadarSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: RadarColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
