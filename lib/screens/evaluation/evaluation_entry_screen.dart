import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../patient_consent_screen.dart';
import '../bdk/bdk_type_screen.dart';
import '../prescription/prescription_type_screen.dart';
import '../../widgets/design_system/clinical_big_action_button.dart';
import '../../widgets/design_system/clinical_responsive_page.dart';

class EvaluationEntryScreen extends StatefulWidget {
  const EvaluationEntryScreen({super.key});

  @override
  State<EvaluationEntryScreen> createState() => _EvaluationEntryScreenState();
}

class _EvaluationEntryScreenState extends State<EvaluationEntryScreen> {
  void _openDrapeauxRouges() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _openPatient() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const PatientConsentScreen()));
  }

  void _openPrescription() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const PrescriptionTypeScreen()));
  }

  void _openBdk() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => const BDKTypeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ClinicalResponsivePage(
      backgroundColor: const Color(0xFFEFF4FA),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return Column(
            children: [
              _Header(compact: !isWide),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 22 : 16,
                    isWide ? 16 : 10,
                    isWide ? 22 : 16,
                    110,
                  ),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _HeroCard(onStart: _openDrapeauxRouges),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _ShortcutRow(
                                    onPatient: _openPatient,
                                    onPrescription: _openPrescription,
                                    onBdk: _openBdk,
                                  ),
                                  const SizedBox(height: 14),
                                  const _RiskLegend(),
                                  const SizedBox(height: 14),
                                  const _FooterNote(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _HeroCard(onStart: _openDrapeauxRouges),
                            const SizedBox(height: 10),
                            _ShortcutRow(
                              onPatient: _openPatient,
                              onPrescription: _openPrescription,
                              onBdk: _openBdk,
                            ),
                            const SizedBox(height: 10),
                            const _RiskLegend(),
                            const SizedBox(height: 10),
                            const _FooterNote(),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 68 : 108,
      padding: EdgeInsets.fromLTRB(
        20,
        compact ? 10 : 22,
        20,
        compact ? 10 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E6DD8), Color(0xFF1552B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
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
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Accès direct · Sécurisation clinique',
                    style: TextStyle(
                      color: Color(0xFFBFD7FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 210 : 322),
      padding: EdgeInsets.all(compact ? 18 : 26),
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
          SizedBox(height: compact ? 22 : 46),
          Text(
            'DRAPEAUX',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 34 : 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.8,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            const Text(
              'Évaluer les signes d’alerte',
              style: TextStyle(
                color: Color(0xFFFFE4EF),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          SizedBox(height: compact ? 18 : 28),
          Center(
            child: ClinicalBigActionButton(
              title: 'Commencer l’évaluation',
              icon: Icons.arrow_forward_rounded,
              colors: const [Color(0xFFFF7AAA), Color(0xFFE91E63)],
              shadowColor: Colors.white,
              onTap: onStart,
              diameter: compact ? 76 : 92,
              iconSize: compact ? 34 : 42,
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
      child: const Icon(Icons.flag_outlined, color: Colors.white, size: 30),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.onPatient,
    required this.onPrescription,
    required this.onBdk,
  });

  final VoidCallback onPatient;
  final VoidCallback onPrescription;
  final VoidCallback onBdk;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      return Column(
        children: [
          _ShortcutTile(
            icon: Icons.person_outline_rounded,
            label: 'Patient',
            onTap: onPatient,
          ),
          const SizedBox(height: 10),
          _ShortcutTile(
            icon: Icons.description_outlined,
            label: 'Prescription',
            onTap: onPrescription,
          ),
          const SizedBox(height: 10),
          _ShortcutTile(
            icon: Icons.assignment_outlined,
            label: 'BDK',
            onTap: onBdk,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _ShortcutTile(
            icon: Icons.person_outline_rounded,
            label: 'Patient',
            onTap: onPatient,
          ),
        ),
        const SizedBox(width: 1),
        Expanded(
          child: _ShortcutTile(
            icon: Icons.description_outlined,
            label: 'Prescription',
            onTap: onPrescription,
          ),
        ),
        const SizedBox(width: 1),
        Expanded(
          child: _ShortcutTile(
            icon: Icons.assignment_outlined,
            label: 'BDK',
            onTap: onBdk,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(isWide ? 18 : 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isWide ? 18 : 0),
        child: Container(
          height: isWide ? 78 : 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isWide ? 18 : 0),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: isWide
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              SizedBox(width: isWide ? 18 : 0),
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
              ),
              SizedBox(width: isWide ? 12 : 0),
              if (isWide)
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 47),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
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
              Expanded(
                child: _RiskChip(
                  'Faible',
                  Color(0xFFE8F7ED),
                  Color(0xFF16A34A),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _RiskChip(
                  'Modéré',
                  Color(0xFFFFF1DE),
                  Color(0xFFF97316),
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _RiskChip('Élevé', Color(0xFFFFE4EC), Color(0xFFE11D48)),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _RiskChip('Critique', Color(0xFF7F1D1D), Colors.white),
              ),
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

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Outil d’aide clinique · Ne remplace pas le diagnostic médical',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
