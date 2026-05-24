import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../../widgets/design_system/clinical_big_action_button.dart';

class EvaluationEntryScreen extends StatefulWidget {
  const EvaluationEntryScreen({super.key});

  @override
  State<EvaluationEntryScreen> createState() => _EvaluationEntryScreenState();
}

class _EvaluationEntryScreenState extends State<EvaluationEntryScreen> {
  bool showEvaluation = false;

  void _startEvaluation() {
    setState(() => showEvaluation = true);
  }

  @override
  Widget build(BuildContext context) {
    if (showEvaluation) return const HomeScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const _Header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    child: Column(
                      children: [
                        _HeroCard(onStart: _startEvaluation),
                        const SizedBox(height: 14),
                        const _ShortcutRow(),
                        const SizedBox(height: 14),
                        const _RiskLegend(),
                        const SizedBox(height: 14),
                        const Text(
                          'Outil d’aide clinique · Ne remplace pas le diagnostic médical',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E6DD8), Color(0xFF1552B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Évaluation clinique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Accès direct · Sécurisation clinique',
                  style: TextStyle(
                    color: Color(0xFFBFD7FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SecureBadge(),
        ],
      ),
    );
  }
}

class _SecureBadge extends StatelessWidget {
  const _SecureBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            'Sécurisé',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 322),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'OUTIL DE SÉCURISATION CLINIQUE',
                  style: TextStyle(
                    color: Color(0xFFFFB8D4),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ),
              _FlagIcon(),
            ],
          ),
          const SizedBox(height: 46),
          const Text(
            'DRAPEAUX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Évaluer les signes d’alerte',
            style: TextStyle(
              color: Color(0xFFFFE4EF),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: ClinicalBigActionButton(
              title: 'Commencer l’évaluation',
              icon: Icons.arrow_forward_rounded,
              colors: const [
                Color(0xFFFF7AAA),
                Color(0xFFE91E63),
              ],
              shadowColor: Colors.white,
              onTap: onStart,
              diameter: 92,
              iconSize: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  const _FlagIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: const Icon(
        Icons.flag_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ShortcutTile(icon: Icons.history_rounded, label: 'Historique')),
        SizedBox(width: 1),
        Expanded(child: _ShortcutTile(icon: Icons.description_outlined, label: 'Prescription')),
        SizedBox(width: 1),
        Expanded(child: _ShortcutTile(icon: Icons.assignment_outlined, label: 'BDK')),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskLegend extends StatelessWidget {
  const _RiskLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NIVEAUX DE RISQUE',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _RiskChip('Faible', Color(0xFFE8F7ED), Color(0xFF16A34A))),
              SizedBox(width: 7),
              Expanded(child: _RiskChip('Modéré', Color(0xFFFFF1DE), Color(0xFFF97316))),
              SizedBox(width: 7),
              Expanded(child: _RiskChip('Élevé', Color(0xFFFFE4EC), Color(0xFFE11D48))),
              SizedBox(width: 7),
              Expanded(child: _RiskChip('Critique', Color(0xFF7F1D1D), Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip(this.label, this.background, this.color);

  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}