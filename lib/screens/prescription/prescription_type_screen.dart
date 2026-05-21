import 'package:flutter/material.dart';

import '../prescription_screen.dart';

class PrescriptionTypeScreen extends StatelessWidget {
  const PrescriptionTypeScreen({super.key});

  void openPrescriptionScreen(
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
    final items = [
      _PrescriptionItem(
        title: 'Rééducation',
        subtitle: 'Prescription de séances de kinésithérapie.',
        icon: Icons.accessibility_new_rounded,
        color: const Color(0xFF2563EB),
      ),
      _PrescriptionItem(
        title: 'Matériel',
        subtitle: 'Orthèses, aides techniques et matériel médical.',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _PrescriptionItem(
        title: 'Examens',
        subtitle: 'Bilans, imagerie et examens complémentaires.',
        icon: Icons.biotech_outlined,
        color: const Color(0xFFF97316),
      ),
      _PrescriptionItem(
        title: 'Conseils',
        subtitle: 'Recommandations et conseils au patient.',
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF0F766E),
      ),
      _PrescriptionItem(
        title: 'Autres',
        subtitle: 'Prescription libre et document personnalisé.',
        icon: Icons.more_horiz_rounded,
        color: const Color(0xFF64748B),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 120),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];

            return _PrescriptionTypeCard(
              item: item,
              onTap: () {
                openPrescriptionScreen(
                  context,
                  item.title,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PrescriptionItem {
  const _PrescriptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _PrescriptionTypeCard extends StatelessWidget {
  const _PrescriptionTypeCard({
    required this.item,
    required this.onTap,
  });

  final _PrescriptionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}