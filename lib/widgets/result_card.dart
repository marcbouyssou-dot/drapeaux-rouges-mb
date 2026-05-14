import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String riskLevel;
  final Color riskColor;
  final int score;
  final int checkedCount;

  const ResultCard({
    super.key,
    required this.riskLevel,
    required this.riskColor,
    required this.score,
    required this.checkedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor,
            riskColor.withOpacity(0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              riskLevel,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _miniStat('Score', '$score'),
          const SizedBox(width: 10),
          _miniStat('Flags', '$checkedCount'),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      width: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}