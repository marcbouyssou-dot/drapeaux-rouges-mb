import 'package:flutter/material.dart';

import '../../../../models/clinical_screening/clinical_screening_models.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarDecisionCard extends StatelessWidget {
  const RadarDecisionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.vigilance,
    required this.decisionLevel,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.details,
  });

  final String title;
  final String subtitle;
  final String body;
  final String vigilance;
  final ClinicalDecisionLevel? decisionLevel;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String secondaryActionLabel;
  final VoidCallback onSecondaryAction;
  final Widget details;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(decisionLevel);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(RadarRadius.signature),
        boxShadow: RadarShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadarSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ClinicalBadge(
              label: _badgeLabel(decisionLevel),
              color: accentColor,
            ),
            const SizedBox(height: RadarSpacing.cardGap),
            Text(title, style: RadarTextStyles.decision),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: RadarSpacing.sm),
              Text(subtitle, style: RadarTextStyles.secondary),
            ],
            const SizedBox(height: RadarSpacing.lg),
            Text(body, style: RadarTextStyles.secondary),
            if (vigilance.isNotEmpty) ...[
              const SizedBox(height: RadarSpacing.sm),
              Text(vigilance, style: RadarTextStyles.secondary),
            ],
            const SizedBox(height: RadarSpacing.xl),
            _DecisionPrimaryAction(
              label: primaryActionLabel,
              color: accentColor,
              onTap: onPrimaryAction,
            ),
            const SizedBox(height: RadarSpacing.md),
            _DecisionSecondaryAction(
              label: secondaryActionLabel,
              onTap: onSecondaryAction,
            ),
            const SizedBox(height: RadarSpacing.cardGap),
            _DecisionDetails(details: details),
          ],
        ),
      ),
    );
  }

  String _badgeLabel(ClinicalDecisionLevel? level) {
    return switch (level) {
      ClinicalDecisionLevel.routine => 'Favorable',
      ClinicalDecisionLevel.monitor => 'Vigilance',
      ClinicalDecisionLevel.medicalAdvice => 'Avis médical recommandé',
      ClinicalDecisionLevel.urgentReferral => 'Orientation urgente',
      ClinicalDecisionLevel.emergency => 'Orientation urgente',
      null => 'Synthèse clinique',
    };
  }

  Color _accentColor(ClinicalDecisionLevel? level) {
    return switch (level) {
      ClinicalDecisionLevel.routine => RadarColors.clinicalSuccess,
      ClinicalDecisionLevel.monitor => RadarColors.clinicalWarning,
      ClinicalDecisionLevel.medicalAdvice => RadarColors.clinicalAction,
      ClinicalDecisionLevel.urgentReferral => RadarColors.clinicalDanger,
      ClinicalDecisionLevel.emergency => RadarColors.clinicalDanger,
      null => RadarColors.clinicalAction,
    };
  }
}

class _ClinicalBadge extends StatelessWidget {
  const _ClinicalBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.md,
          vertical: RadarSpacing.xs,
        ),
        child: Text(label, style: RadarTextStyles.badge.copyWith(color: color)),
      ),
    );
  }
}

class _DecisionPrimaryAction extends StatefulWidget {
  const _DecisionPrimaryAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_DecisionPrimaryAction> createState() => _DecisionPrimaryActionState();
}

class _DecisionPrimaryActionState extends State<_DecisionPrimaryAction> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: _pressed ? 0.82 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RadarSpacing.cardGap,
                    ),
                    child: Text(
                      widget.label,
                      style: RadarTextStyles.action.copyWith(
                        color: RadarColors.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionSecondaryAction extends StatelessWidget {
  const _DecisionSecondaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 44,
            width: double.infinity,
            child: Align(
              alignment: Alignment.center,
              child: Text(label, style: RadarTextStyles.action),
            ),
          ),
        ),
      ),
    );
  }
}

class _DecisionDetails extends StatefulWidget {
  const _DecisionDetails({required this.details});

  final Widget details;

  @override
  State<_DecisionDetails> createState() => _DecisionDetailsState();
}

class _DecisionDetailsState extends State<_DecisionDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(RadarRadius.card),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              borderRadius: BorderRadius.circular(RadarRadius.card),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadarSpacing.lg,
                  vertical: RadarSpacing.md,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Voir les détails de l’analyse',
                        style: RadarTextStyles.action,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: RadarColors.blueGrey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      RadarSpacing.lg,
                      0,
                      RadarSpacing.lg,
                      RadarSpacing.lg,
                    ),
                    child: widget.details,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
