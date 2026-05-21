import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';
import '../../widgets/design_system/clinical_list_item.dart';
import '../../widgets/design_system/clinical_page_header.dart';
import '../prescription_screen.dart';

class PrescriptionTypeScreen extends StatelessWidget {
  const PrescriptionTypeScreen({super.key});

  void _openPrescriptionScreen(
    BuildContext context,
    String type,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionScreen(
          initialPrescriptionType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ClinicalPageHeader(
            title: 'Prescription',
            subtitle:
                'Choisissez le type de prescription ou document clinique.',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                ClinicalListItem(
                  title: 'Rééducation',
                  subtitle: 'Prescription de séances de kinésithérapie.',
                  icon: Icons.accessibility_new_rounded,
                  color: AppColors.primaryBlue,
                  onTap: () => _openPrescriptionScreen(
                    context,
                    'Rééducation',
                  ),
                ),
                ClinicalListItem(
                  title: 'Matériel',
                  subtitle: 'Aides techniques, orthèses, matériel médical.',
                  icon: Icons.medical_services_outlined,
                  color: Colors.deepPurple,
                  onTap: () => _openPrescriptionScreen(
                    context,
                    'Matériel',
                  ),
                ),
                ClinicalListItem(
                  title: 'Examens',
                  subtitle: 'Bilans, examens complémentaires, imagerie.',
                  icon: Icons.biotech_outlined,
                  color: AppColors.warningOrange,
                  onTap: () => _openPrescriptionScreen(
                    context,
                    'Examens',
                  ),
                ),
                ClinicalListItem(
                  title: 'Conseils',
                  subtitle: 'Recommandations et conseils au patient.',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: Colors.teal,
                  onTap: () => _openPrescriptionScreen(
                    context,
                    'Conseils',
                  ),
                ),
                ClinicalListItem(
                  title: 'Autres',
                  subtitle: 'Document libre ou prescription personnalisée.',
                  icon: Icons.more_horiz_rounded,
                  color: Colors.blueGrey,
                  onTap: () => _openPrescriptionScreen(
                    context,
                    'Autres',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}