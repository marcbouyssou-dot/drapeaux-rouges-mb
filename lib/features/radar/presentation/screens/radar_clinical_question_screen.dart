import 'package:flutter/material.dart';

import '../../application/radar_clinical_answer.dart';
import '../../application/radar_clinical_session_controller.dart';
import '../../application/radar_clinical_status.dart';
import '../../application/radar_clinical_view_state.dart';
import '../theme/radar_colors.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';
import '../widgets/radar_context_bar.dart';
import '../widgets/radar_question_option.dart';
import 'radar_clinical_hard_stop_placeholder_screen.dart';
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
            builder: (_) =>
                RadarClinicalHardStopPlaceholderScreen(finalState: nextState),
          ),
        );
    }
  }

  String _answerLabel(RadarClinicalAnswer answer) {
    return switch (answer) {
      RadarClinicalAnswer.yes => 'Oui',
      RadarClinicalAnswer.no => 'Non',
      RadarClinicalAnswer.bilateral => 'Des deux côtés',
      RadarClinicalAnswer.unknown => 'Impossible à préciser',
    };
  }

  @override
  Widget build(BuildContext context) {
    final question = _state.question;

    return Scaffold(
      backgroundColor: RadarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: RadarSpacing.md),
              children: [
                const RadarContextBar(
                  patientName: 'Marie Dupont',
                  status: 'Consultation en cours',
                ),
                const SizedBox(height: RadarSpacing.xl),
                const Text('ÉVALUATION CLINIQUE', style: RadarTextStyles.label),
                const SizedBox(height: RadarSpacing.lg),
                if (question == null)
                  const Text(
                    'La question clinique n’est pas disponible.',
                    style: RadarTextStyles.title,
                  )
                else
                  Text(question.text, style: RadarTextStyles.title),
                const SizedBox(height: RadarSpacing.xl),
                if (question != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: RadarColors.surface,
                      border: Border.all(color: RadarColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        children: [
                          for (final answer in question.availableAnswers) ...[
                            RadarQuestionOption(
                              label: _answerLabel(answer),
                              onTap: () => _answer(answer),
                            ),
                            if (answer != question.availableAnswers.last)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: RadarColors.border,
                              ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: RadarColors.surface,
                      border: Border.all(color: RadarColors.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(RadarSpacing.md),
                      child: Text(
                        'Impossible d’afficher la collecte clinique.',
                        style: RadarTextStyles.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
