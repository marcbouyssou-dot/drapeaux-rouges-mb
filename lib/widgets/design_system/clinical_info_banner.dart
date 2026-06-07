import 'package:flutter/material.dart';

class ClinicalInfoBanner extends StatelessWidget {
  const ClinicalInfoBanner({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: compact ? 20 : 24),
          SizedBox(width: compact ? 9 : 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: compact ? 13 : 15,
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
