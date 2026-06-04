import 'package:flutter/material.dart';

class HomeRiskLegendCard extends StatelessWidget {
  const HomeRiskLegendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NIVEAUX DE RISQUE',
            style: TextStyle(
              color: Color(0xFFB7C5D8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              HomeRiskChip('Faible', Color(0xFF16A34A), false),
              HomeRiskChip('Modéré', Color(0xFFF97316), false),
              HomeRiskChip('Élevé', Color(0xFFEF4444), false),
              HomeRiskChip('Critique', Color(0xFF7F0000), true),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeRiskChip extends StatelessWidget {
  const HomeRiskChip(this.label, this.color, this.active, {super.key});

  final String label;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color : Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: active ? 1 : 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFF6B6B) : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFFF6B6B) : const Color(0xFF475569),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFooterNote extends StatelessWidget {
  const HomeFooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Outil d’aide clinique · Ne remplace pas le diagnostic médical',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF334155),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class HomeDesktopInfoNote extends StatelessWidget {
  const HomeDesktopInfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF2563EB),
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Outil d’aide au raisonnement clinique. Les données de santé doivent rester protégées. Cette application ne remplace pas une évaluation médicale professionnelle.',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
