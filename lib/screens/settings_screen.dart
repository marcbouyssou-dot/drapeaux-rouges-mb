import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            150,
          ),

          children: [
            const AppHeader(),

            const SizedBox(height: 20),

            buildTitle(),

            const SizedBox(height: 22),

            buildHeroCard(),

            const SizedBox(height: 24),

            buildSectionLabel('CONFIDENTIALITÉ'),

            const SizedBox(height: 12),

            settingCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Confidentialité RGPD',
              subtitle:
                  'Données nominatives conservées localement.',
            ),

            settingCard(
              icon:
                  Icons.shield_outlined,
              title: 'Protection des données',
              subtitle:
                  'Aucune transmission automatique.',
            ),

            settingCard(
              icon:
                  Icons.cloud_outlined,
              title:
                  'Sauvegarde locale',
              subtitle:
                  'Exporter / importer les données.',
            ),

            const SizedBox(height: 26),

            buildSectionLabel(
              'PARAMÈTRES CLINIQUES',
            ),

            const SizedBox(height: 12),

            settingCard(
              icon: Icons
                  .medical_information_outlined,
              title: 'Usage clinique',
              subtitle:
                  'Aide au raisonnement clinique.',
            ),

            settingCard(
              icon:
                  Icons.picture_as_pdf_outlined,
              title: 'Exports PDF',
              subtitle:
                  'Documents cliniques et synthèses.',
            ),

            settingCard(
              icon:
                  Icons.analytics_outlined,
              title: 'Statistiques',
              subtitle:
                  'Analyse locale des évaluations.',
            ),

            const SizedBox(height: 26),

            buildSectionLabel(
              'ASSISTANCE',
            ),

            const SizedBox(height: 12),

            settingCard(
              icon:
                  Icons.help_outline_rounded,
              title: 'FAQ',
              subtitle:
                  'Questions fréquentes.',
            ),

            settingCard(
              icon:
                  Icons.mail_outline_rounded,
              title: 'Contact',
              subtitle:
                  'Support et assistance.',
            ),

            const SizedBox(height: 30),

            buildVersionCard(),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Réglages',
          style:
              AppTextStyles.pageTitle,
        ),

        SizedBox(height: 4),

        Text(
          'Configuration de l’application',
          style:
              AppTextStyles.pageSubtitle,
        ),
      ],
    );
  }

  Widget buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),

        borderRadius:
            BorderRadius.circular(32),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 68,
            width: 68,

            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.10),

              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),

            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(width: 18),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Configuration',
                  style: TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 15,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Paramètres de l’application',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight
                            .w900,
                    letterSpacing:
                        -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionLabel(
    String text,
  ) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 13,
        fontWeight:
            FontWeight.w900,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        border: Border.all(
          color:
              const Color(0xFFE2E8F0),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),

        leading: Container(
          height: 52,
          width: 52,

          decoration: BoxDecoration(
            color:
                const Color(
              0xFFEAF2FF,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: Icon(
            icon,
            color:
                const Color(
              0xFF2563EB,
            ),
            size: 28,
          ),
        ),

        title: Text(
          title,
          style:
              AppTextStyles.cardTitle,
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 4,
          ),

          child: Text(
            subtitle,
            style: AppTextStyles
                .cardSubtitle,
          ),
        ),

        trailing: Container(
          height: 38,
          width: 38,

          decoration: BoxDecoration(
            color:
                const Color(
              0xFFF8FAFC,
            ),

            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),

          child: const Icon(
            Icons
                .chevron_right_rounded,
            color:
                Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFFEAF2FF),
            Color(0xFFF8FAFC),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        border: Border.all(
          color:
              const Color(0xFFBFDBFE),
        ),
      ),

      child: const Column(
        children: [
          Icon(
            Icons.verified_rounded,
            color:
                Color(0xFF2563EB),
            size: 34,
          ),

          SizedBox(height: 12),

          Text(
            'Drapeaux Rouges',
            style: TextStyle(
              color:
                  Color(0xFF0F172A),
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Version 1.0.0',
            style: TextStyle(
              color:
                  Color(0xFF64748B),
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}