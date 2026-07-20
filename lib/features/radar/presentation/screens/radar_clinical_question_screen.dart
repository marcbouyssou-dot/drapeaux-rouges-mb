import 'package:flutter/material.dart';

import '../../application/radar_clinical_answer.dart';
import '../../application/radar_clinical_region.dart';
import '../../application/radar_clinical_session_controller.dart';
import '../../application/radar_clinical_status.dart';
import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import 'radar_clinical_hard_stop_screen.dart';
import 'radar_clinical_summary_screen.dart';

class RadarClinicalQuestionScreen extends StatefulWidget {
  const RadarClinicalQuestionScreen({
    super.key,
    required this.controller,
    required this.initialState,
  });

  final RadarClinicalSessionController controller;
  final RadarClinicalViewState initialState;

  @override
  State<RadarClinicalQuestionScreen> createState() =>
      _RadarClinicalQuestionScreenState();
}

class _RadarClinicalQuestionScreenState
    extends State<RadarClinicalQuestionScreen> {
  late RadarClinicalViewState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  void _answer(RadarClinicalAnswer answer) {
    final nextState = widget.controller.answer(answer);

    switch (nextState.status) {
      case RadarClinicalStatus.question:
      case RadarClinicalStatus.unsupportedAnswer:
        setState(() {
          _state = nextState;
        });
      case RadarClinicalStatus.decision:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RadarClinicalSummaryScreen(finalState: nextState),
          ),
        );
      case RadarClinicalStatus.hardStop:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RadarClinicalHardStopScreen(finalState: nextState),
          ),
        );
    }
  }

  String _answerLabel(RadarClinicalAnswer answer) {
    return switch (answer) {
      RadarClinicalAnswer.yes => 'Oui',
      RadarClinicalAnswer.no => 'Non',
      RadarClinicalAnswer.bilateral => 'Des deux côtés',
      RadarClinicalAnswer.unknown => 'Je ne sais pas',
    };
  }

  String _regionLabel(RadarClinicalRegion region) {
    return switch (region) {
      RadarClinicalRegion.lumbar => 'Lombaires',
      RadarClinicalRegion.cervical => 'Cou',
      RadarClinicalRegion.thoracic => 'Thorax',
      RadarClinicalRegion.shoulderUpperLimbProximal => 'Épaule',
      RadarClinicalRegion.upperLimbDistal => 'Coude / main',
      RadarClinicalRegion.hipLowerLimbProximal => 'Hanche',
      RadarClinicalRegion.kneeLeg => 'Genou',
      RadarClinicalRegion.ankleFoot => 'Cheville / pied',
      RadarClinicalRegion.diffuse => 'Diffus',
    };
  }

  @override
  Widget build(BuildContext context) {
    final question = _state.question;
    final currentStep = _state.answeredQuestionIds.length + 1;
    final stepLabel = '${_regionLabel(_state.region)} • Étape $currentStep / 8';

    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RadarSpacing.xl,
                RadarSpacing.xxxl,
                RadarSpacing.xl,
                RadarSpacing.xxl,
              ),
              children: [
                const RadarContextBar(
                  patientName: 'Marie Dupont',
                  status: 'Consultation en cours',
                ),
                const SizedBox(height: RadarSpacing.xl),
                const Text(
                  'Évaluation clinique',
                  style: RadarTextStyles.screenTitle,
                ),
                const SizedBox(height: RadarSpacing.sm),
                Text(stepLabel, style: RadarTextStyles.secondary),
                const SizedBox(height: RadarSpacing.xxl),
                if (question == null)
                  const Text(
                    'La question clinique n’est pas disponible.',
                    style: RadarTextStyles.question,
                  )
                else
                  Text(
                    question.text,
                    style: RadarTextStyles.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: RadarSpacing.xl),
                if (question != null)
                  Column(
                    children: [
                      for (final answer in question.availableAnswers) ...[
                        _RadarAnswerCard(
                          label: _answerLabel(answer),
                          onTap: () => _answer(answer),
                        ),
                        if (answer != question.availableAnswers.last)
                          const SizedBox(height: RadarSpacing.lg),
                      ],
                    ],
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: RadarColors.surface,
                      borderRadius: BorderRadius.circular(RadarRadius.card),
                      boxShadow: RadarShadows.card,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(RadarSpacing.cardGap),
                      child: Text(
                        'Impossible d’afficher la collecte clinique.',
                        style: RadarTextStyles.secondary,
                      ),
                    ),
                  ),
                const SizedBox(height: RadarSpacing.xxl),
                _RadarBackAction(onTap: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarAnswerCard extends StatefulWidget {
  const _RadarAnswerCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_RadarAnswerCard> createState() => _RadarAnswerCardState();
}

class _RadarAnswerCardState extends State<_RadarAnswerCard> {
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
    final borderRadius = BorderRadius.circular(RadarRadius.card);

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
            opacity: _pressed ? 0.78 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: RadarColors.surface,
                borderRadius: borderRadius,
                boxShadow: RadarShadows.card,
              ),
              child: Padding(
                padding: const EdgeInsets.all(RadarSpacing.cardGap),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.label, style: RadarTextStyles.body),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: RadarColors.blueGrey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarBackAction extends StatefulWidget {
  const _RadarBackAction({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_RadarBackAction> createState() => _RadarBackActionState();
}

class _RadarBackActionState extends State<_RadarBackAction> {
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
      label: 'Retour',
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
            opacity: _pressed ? 0.7 : 1,
            child: const SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Retour', style: RadarTextStyles.secondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
