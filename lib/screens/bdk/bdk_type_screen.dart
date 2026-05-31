import 'package:flutter/material.dart';

import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BDKItem(
        title: 'BDK Lombalgie',
        icon: Icons.back_hand_outlined,
        color: Color(0xFF2563EB),
      ),
      _BDKItem(
        title: 'BDK Cervicalgie',
        icon: Icons.accessibility_new_outlined,
        color: Color(0xFFDB2777),
      ),
      _BDKItem(
        title: 'BDK Cheville',
        icon: Icons.directions_walk_outlined,
        color: Color(0xFF16A34A),
      ),
      _BDKItem(
        title: 'BDK Respiratoire',
        icon: Icons.air_outlined,
        color: Color(0xFF7C3AED),
      ),
      _BDKItem(
        title: 'BDK Personne âgée',
        icon: Icons.elderly_outlined,
        color: Color(0xFFF97316),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              children: [
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BDKTypeCard(
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
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const _BDKInfoBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BDKItem {
  const _BDKItem({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
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
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
                  color: item.color.withValues(alpha: 0.10),
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
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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

class _BDKInfoBanner extends StatelessWidget {
  const _BDKInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF16A34A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'BDK structurés avec synthèse clinique et export PDF.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}