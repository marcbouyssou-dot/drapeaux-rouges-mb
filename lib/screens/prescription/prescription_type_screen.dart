import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_page_header.dart';
import '../attestation/attestation_type_screen.dart';
import '../medical_letter/medical_letter_type_screen.dart';
import '../prescription_screen.dart';

class PrescriptionTypeScreen extends StatelessWidget {
  const PrescriptionTypeScreen({super.key});

  void openPrescriptionScreen(BuildContext context, String type) {
    if (type == 'Attestations') {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const AttestationTypeScreen()),
      );
      return;
    }

    if (type == 'Courriers médicaux') {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const MedicalLetterTypeScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => PrescriptionScreen(initialPrescriptionType: type),
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
              constraints: const BoxConstraints(
                maxWidth: RadarLayout.workflowWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xxl,
                ),
                children: [
                  RadarPageHeader(
                    title: 'Documents',
                    subtitle:
                        'Créer un document clinique et préparer un export PDF.',
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: RadarSpacing.xxl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 480) {
                        return GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: RadarSpacing.lg,
                          mainAxisSpacing: RadarSpacing.lg,
                          childAspectRatio: 2.6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: prescriptionTypeOptions
                              .map(
                                (item) => _PrescriptionTypeCard(
                                  item: item,
                                  onTap: () => openPrescriptionScreen(
                                    context,
                                    item.title,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return Column(
                        children: prescriptionTypeOptions
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: RadarSpacing.lg,
                                ),
                                child: _PrescriptionTypeCard(
                                  item: item,
                                  onTap: () => openPrescriptionScreen(
                                    context,
                                    item.title,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
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

class PrescriptionTypeOption {
  const PrescriptionTypeOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
}

const prescriptionTypeOptions = [
  PrescriptionTypeOption(
    id: 'reeducation',
    title: 'Rééducation',
    icon: Icons.accessibility_new_rounded,
    color: RadarColors.primary,
  ),
  PrescriptionTypeOption(
    id: 'materiel',
    title: 'Matériel',
    icon: Icons.medical_services_outlined,
    color: RadarColors.indigo,
  ),
  PrescriptionTypeOption(
    id: 'examens',
    title: 'Examens',
    icon: Icons.biotech_outlined,
    color: RadarColors.clinicalWarning,
  ),
  PrescriptionTypeOption(
    id: 'conseils',
    title: 'Conseils',
    icon: Icons.chat_bubble_outline_rounded,
    color: RadarColors.clinicalSuccess,
  ),
  PrescriptionTypeOption(
    id: 'attestations',
    title: 'Attestations',
    icon: Icons.assignment_turned_in_outlined,
    color: RadarColors.clinicalAction,
  ),
  PrescriptionTypeOption(
    id: 'courriers_medicaux',
    title: 'Courriers médicaux',
    icon: Icons.mark_email_read_outlined,
    color: RadarColors.slate,
  ),
  PrescriptionTypeOption(
    id: 'autres',
    title: 'Autres',
    icon: Icons.more_horiz_rounded,
    color: RadarColors.neutralGrey,
  ),
];

class _PrescriptionTypeCard extends StatelessWidget {
  const _PrescriptionTypeCard({required this.item, required this.onTap});

  final PrescriptionTypeOption item;
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
          padding: const EdgeInsets.all(RadarSpacing.lg),
          decoration: BoxDecoration(
            color: RadarColors.surface,
            borderRadius: BorderRadius.circular(RadarRadius.card),
            boxShadow: RadarShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: compact ? 44 : 50,
                width: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: compact ? 23 : 26,
                ),
              ),
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question.copyWith(
                    color: item.color,
                    fontSize: compact ? 16 : 18,
                  ),
                ),
              ),
              const SizedBox(width: RadarSpacing.xs),
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
