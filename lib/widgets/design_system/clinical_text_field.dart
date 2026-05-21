import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';

class ClinicalTextField extends StatelessWidget {
  const ClinicalTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          maxLines: maxLines,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(
              color: AppColors.textSecondary,
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.all(18),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}