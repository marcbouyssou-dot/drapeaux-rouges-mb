import 'package:flutter/material.dart';

import '../prescription_screen.dart';

class PrescriptionTypeScreen extends StatelessWidget {
  const PrescriptionTypeScreen({super.key});

  void openPrescriptionScreen(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionScreen(initialPrescriptionType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _PrescriptionItem(
        title: 'Rééducation',
        icon: Icons.accessibility_new_rounded,
        color: Color(0xFF2563EB),
      ),
      _PrescriptionItem(
        title: 'Matériel',
        icon: Icons.medical_services_outlined,
        color: Color(0xFF7C3AED),
      ),
      _PrescriptionItem(
        title: 'Examens',
        icon: Icons.biotech_outlined,
        color: Color(0xFFF97316),
      ),
      _PrescriptionItem(
        title: 'Conseils',
        icon: Icons.chat_bubble_outline_rounded,
        color: Color(0xFF0F766E),
      ),
      _PrescriptionItem(
        title: 'Autres',
        icon: Icons.more_horiz_rounded,
        color: Color(0xFF64748B),
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
                const _BackButtonTile(),
                const SizedBox(height: 12),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PrescriptionTypeCard(
                      item: item,
                      onTap: () {
                        openPrescriptionScreen(context, item.title);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const _PrescriptionInfoBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButtonTile extends StatelessWidget {
  const _BackButtonTile();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back_rounded),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _PrescriptionItem {
  const _PrescriptionItem({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _PrescriptionTypeCard extends StatelessWidget {
  const _PrescriptionTypeCard({required this.item, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
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

class _PrescriptionInfoBanner extends StatelessWidget {
  const _PrescriptionInfoBanner();

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
          Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF7C3AED)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prescriptions exportables en PDF.',
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
