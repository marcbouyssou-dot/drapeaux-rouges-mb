import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';

class ClinicalPageHeader extends StatelessWidget {
  const ClinicalPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
  });

  final String title;
  final String subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBackButton)
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppShadows.softShadow,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

            if (showBackButton) const SizedBox(height: 18),

            Text(title, style: AppTextStyles.screenTitle),

            const SizedBox(height: 8),

            Text(subtitle, style: AppTextStyles.cardSubtitle),
          ],
        ),
      ),
    );
  }
}
