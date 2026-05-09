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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor.withOpacity(0.95),
            riskColor.withOpacity(0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 18),
          Text(
            riskLevel,
            style: const TextStyle(
              fontSize: 34,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: miniStat('Score', '$score')),
              const SizedBox(width: 12),
              Expanded(child: miniStat('Drapeaux', '$checkedCount')),
            ],
          ),
        ],
      ),
    );
  }

  Widget miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}