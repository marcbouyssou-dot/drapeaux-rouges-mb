import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';

class ClinicalAutoSummaryCard extends StatelessWidget {
  const ClinicalAutoSummaryCard({
    super.key,
    required this.title,
    required this.text,
    required this.emptyText,
  });

  final String title;
  final String text;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = text.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isEmpty ? emptyText : text,
            style: TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}