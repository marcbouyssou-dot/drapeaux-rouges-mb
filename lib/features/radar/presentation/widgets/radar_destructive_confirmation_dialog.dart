import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

Future<bool> showRadarDestructiveConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Annuler',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return RadarDestructiveConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      );
    },
  );

  return confirmed ?? false;
}

class RadarDestructiveConfirmationDialog extends StatelessWidget {
  const RadarDestructiveConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Annuler',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: RadarColors.surface,
      surfaceTintColor: RadarColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadarRadius.card),
      ),
      title: Text(title, style: RadarTextStyles.question),
      content: Text(message, style: RadarTextStyles.secondary),
      actionsPadding: const EdgeInsets.fromLTRB(
        RadarSpacing.lg,
        0,
        RadarSpacing.lg,
        RadarSpacing.lg,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: RadarColors.clinicalDanger,
            foregroundColor: RadarColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            textStyle: RadarTextStyles.badge,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
