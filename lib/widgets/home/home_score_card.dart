import 'package:flutter/material.dart';

class HomeScoreCard extends StatelessWidget {
  const HomeScoreCard({
    super.key,
    required this.score,
    required this.checkedCount,
    required this.hasPatient,
    required this.patientDisplayName,
    required this.onTap,
  });

  final int score;
  final int checkedCount;
  final bool hasPatient;
  final String patientDisplayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final riskPercent = (score * 10).clamp(0, 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 370),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.topRight,
              radius: 1.25,
              colors: [Color(0xFF16254A), Color(0xFF081A34), Color(0xFF030B18)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                blurRadius: 60,
                spreadRadius: 8,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: const Color(0xFFE91E63).withValues(alpha: 0.14),
                blurRadius: 50,
                spreadRadius: 2,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF020617).withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'DRAPEAUX ROUGES DÉTECTÉS',
                      style: TextStyle(
                        color: Color(0xFF7D8AA0),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.38),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$riskPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'RISQUE',
                          style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    checkedCount == 0 ? '0' : '$checkedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      checkedCount <= 1
                          ? 'signal critique'
                          : 'signaux critiques',
                      style: const TextStyle(
                        color: Color(0xFFDDE7F3),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                hasPatient
                    ? '$patientDisplayName · Évaluation en cours'
                    : 'Patient non renseigné · Prêt à évaluer',
                style: const TextStyle(
                  color: Color(0xFFB8C5D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: const Color(0xFFEF4444),
                      value: checkedCount == 0 ? 'À évaluer' : 'Critique',
                      label: 'NIVEAU DE RISQUE',
                    ),
                  ),
                  const HomeMetricDivider(),
                  const Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: Color(0xFFF59E0B),
                      value: 'Réf. requise',
                      label: 'STATUT CLINIQUE',
                    ),
                  ),
                  const HomeMetricDivider(),
                  const Expanded(
                    child: HomeDecisionIndicator(
                      dotColor: Color(0xFF38BDF8),
                      value: 'Médecin',
                      label: 'ORIENTATION',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Commencer le dépistage clinique',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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

class HomeDecisionIndicator extends StatelessWidget {
  const HomeDecisionIndicator({
    super.key,
    required this.dotColor,
    required this.value,
    required this.label,
  });

  final Color dotColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      ],
    );
  }
}

class HomeMetricDivider extends StatelessWidget {
  const HomeMetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.17),
    );
  }
}
