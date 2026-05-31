import 'package:flutter/material.dart';

enum RiskLevel {
  low,
  moderate,
  high,
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.label,
    required this.level,
  });

  final String label;
  final RiskLevel level;

  Color get backgroundColor {
  switch (level) {
    case RiskLevel.low:
      return Colors.green.withValues(alpha: 0.15);
    case RiskLevel.moderate:
      return Colors.orange.withValues(alpha: 0.15);
    case RiskLevel.high:
      return Colors.red.withValues(alpha: 0.15);
  }
}

  Color get textColor {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;

      case RiskLevel.moderate:
        return Colors.orange;

      case RiskLevel.high:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle_outline;

      case RiskLevel.moderate:
        return Icons.warning_amber_rounded;

      case RiskLevel.high:
        return Icons.dangerous_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}