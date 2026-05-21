import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';
import '../../widgets/design_system/clinical_list_item.dart';
import '../../widgets/design_system/clinical_page_header.dart';
import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          const ClinicalPageHeader(
            title: 'BDK',
            subtitle:
                'Choisissez un modèle de bilan diagnostique kinésithérapique.',
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),

              children: [
                ClinicalListItem(
                  title: 'BDK Lombalgie',
                  subtitle:
                      'Auto-remplissage depuis l’évaluation clinique.',
                  icon: Icons.back_hand_outlined,
                  color: AppColors.primaryBlue,
                  trailing: _autoBadge(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKDetailScreen(
                          title: 'BDK Lombalgie',
                        ),
                      ),
                    );
                  },
                ),

                ClinicalListItem(
                  title: 'BDK Cervicalgie',
                  subtitle:
                      'Tests et drapeaux déjà renseignés.',
                  icon: Icons.accessibility_new_outlined,
                  color: Colors.pink,
                  trailing: _autoBadge(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKDetailScreen(
                          title: 'BDK Cervicalgie',
                        ),
                      ),
                    );
                  },
                ),

                ClinicalListItem(
                  title: 'BDK Cheville',
                  subtitle:
                      'Entorse, instabilité, reprise fonctionnelle.',
                  icon: Icons.directions_walk_outlined,
                  color: Colors.green,
                  trailing: _autoBadge(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKDetailScreen(
                          title: 'BDK Cheville',
                        ),
                      ),
                    );
                  },
                ),

                ClinicalListItem(
                  title: 'BDK Respiratoire',
                  subtitle:
                      'Bilan respiratoire adulte.',
                  icon: Icons.air_outlined,
                  color: Colors.deepPurple,
                  trailing: _autoBadge(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKDetailScreen(
                          title: 'BDK Respiratoire',
                        ),
                      ),
                    );
                  },
                ),

                ClinicalListItem(
                  title: 'BDK Personne âgée',
                  subtitle:
                      'Fragilité, équilibre et prévention des chutes.',
                  icon: Icons.elderly_outlined,
                  color: AppColors.warningOrange,
                  trailing: _autoBadge(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKDetailScreen(
                          title: 'BDK Personne âgée',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _autoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        'AUTO',
        style: TextStyle(
          color: AppColors.successGreen,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}