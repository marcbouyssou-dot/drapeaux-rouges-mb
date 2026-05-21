import 'package:flutter/material.dart';

import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BDKItem(
        title: 'BDK Lombalgie',
        subtitle: 'Auto-remplissage depuis l’évaluation clinique.',
        icon: Icons.back_hand_outlined,
        color: const Color(0xFF2563EB),
      ),
      _BDKItem(
        title: 'BDK Cervicalgie',
        subtitle: 'Tests et drapeaux déjà renseignés.',
        icon: Icons.accessibility_new_outlined,
        color: const Color(0xFFDB2777),
      ),
      _BDKItem(
        title: 'BDK Cheville',
        subtitle: 'Entorse, instabilité, reprise fonctionnelle.',
        icon: Icons.directions_walk_outlined,
        color: const Color(0xFF16A34A),
      ),
      _BDKItem(
        title: 'BDK Respiratoire',
        subtitle: 'Bilan respiratoire adulte.',
        icon: Icons.air_outlined,
        color: const Color(0xFF7C3AED),
      ),
      _BDKItem(
        title: 'BDK Personne âgée',
        subtitle: 'Fragilité, équilibre et prévention des chutes.',
        icon: Icons.elderly_outlined,
        color: const Color(0xFFF97316),
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

            return _BDKTypeCard(
              item: item,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BDKDetailScreen(
                      title: item.title,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BDKItem {
  const _BDKItem({
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

class _BDKTypeCard extends StatelessWidget {
  const _BDKTypeCard({
    required this.item,
    required this.onTap,
  });

  final _BDKItem item;
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
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                height: 52,
                width: 52,
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
              _autoBadge(),
              const SizedBox(width: 8),
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

  Widget _autoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'AUTO',
        style: TextStyle(
          color: Color(0xFF16A34A),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}