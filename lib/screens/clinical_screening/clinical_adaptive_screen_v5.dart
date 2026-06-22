import 'package:flutter/material.dart';

import '../../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../../models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import '../../models/clinical_screening/clinical_screening_models.dart';
import '../../services/clinical_adaptive_question_engine_v5.dart';
import '../../services/clinical_adaptive_view_state_mapper_v5.dart';

class ClinicalAdaptiveScreenV5 extends StatefulWidget {
  const ClinicalAdaptiveScreenV5({super.key});

  @override
  State<ClinicalAdaptiveScreenV5> createState() =>
      _ClinicalAdaptiveScreenV5State();
}

class _ClinicalAdaptiveScreenV5State extends State<ClinicalAdaptiveScreenV5> {
  final ClinicalAdaptiveQuestionEngineV5 _engine =
      ClinicalAdaptiveQuestionEngineV5();
  final ClinicalAdaptiveViewStateMapperV5 _mapper =
      ClinicalAdaptiveViewStateMapperV5();
  late ClinicalAdaptiveSessionV5 _session;
  late final String _sessionId;

  @override
  void initState() {
    super.initState();
    _session = _engine.initialSession();
    _sessionId = 'adaptive-v5-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    final viewState = _mapper.map(sessionId: _sessionId, session: _session);

    return Scaffold(
      appBar: AppBar(title: const Text('Évaluation clinique')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProgressHeader(viewState: viewState),
              const SizedBox(height: 16),
              _RiskBanner(viewState: viewState),
              const SizedBox(height: 16),
              if (viewState.hardStopId != null) ...[
                _HardStopPanel(viewState: viewState),
                const SizedBox(height: 16),
              ],
              if (viewState.isFinal)
                _FinalStatePanel(viewState: viewState)
              else
                _QuestionPanel(
                  viewState: viewState,
                  onAnswer: _answerCurrentQuestion,
                ),
              const SizedBox(height: 16),
              _ExplanationPanel(viewState: viewState),
              const SizedBox(height: 16),
              _ClinicalDetails(viewState: viewState),
            ],
          ),
        ),
      ),
    );
  }

  void _answerCurrentQuestion(bool isPositive) {
    final questionId = _session.nextQuestion?.id;
    if (questionId == null) {
      return;
    }

    setState(() {
      _session = _engine.answerQuestion(
        session: _session,
        questionId: questionId,
        isPositive: isPositive,
      );
    });
  }
}

class _ProgressHeader extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _ProgressHeader({required this.viewState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(viewState.progressLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: viewState.progressRatio,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _RiskBanner extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _RiskBanner({required this.viewState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _RiskColors.from(viewState.currentRiskLevel, theme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Niveau actuel', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              viewState.currentRiskLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;
  final ValueChanged<bool> onAnswer;

  const _QuestionPanel({required this.viewState, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          viewState.patientQuestionText ?? '',
          key: const Key('adaptive-v5-question-text'),
          style: theme.textTheme.headlineSmall?.copyWith(height: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          'Répondez selon les éléments recueillis pendant l’entretien clinique.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: const Key('adaptive-v5-yes-button'),
                onPressed: viewState.canAnswer ? () => onAnswer(true) : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Oui'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                key: const Key('adaptive-v5-no-button'),
                onPressed: viewState.canAnswer ? () => onAnswer(false) : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Non'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HardStopPanel extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _HardStopPanel({required this.viewState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alerte clinique prioritaire',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              viewState.hardStopTitle ?? 'Alerte clinique',
              key: const Key('adaptive-v5-hard-stop-title'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalStatePanel extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _FinalStatePanel({required this.viewState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('État final', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              viewState.finalDecisionLabel ?? viewState.currentRiskLabel,
              key: const Key('adaptive-v5-final-decision'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (viewState.primaryHypothesisTitle != null) ...[
              const SizedBox(height: 8),
              Text(viewState.primaryHypothesisTitle!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExplanationPanel extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _ExplanationPanel({required this.viewState});

  @override
  Widget build(BuildContext context) {
    return Text(
      viewState.shortExplanation,
      key: const Key('adaptive-v5-short-explanation'),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _ClinicalDetails extends StatelessWidget {
  final ClinicalAdaptiveViewStateV5 viewState;

  const _ClinicalDetails({required this.viewState});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: const Key('adaptive-v5-clinical-details'),
      tilePadding: EdgeInsets.zero,
      title: const Text('Détails cliniques'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SelectableText(
            viewState.technicalSummary,
            key: const Key('adaptive-v5-technical-summary'),
          ),
        ),
      ],
    );
  }
}

class _RiskColors {
  final Color background;
  final Color border;
  final Color foreground;

  const _RiskColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  factory _RiskColors.from(ClinicalDecisionLevel level, ThemeData theme) {
    final scheme = theme.colorScheme;

    switch (level) {
      case ClinicalDecisionLevel.emergency:
        return _RiskColors(
          background: scheme.errorContainer,
          border: scheme.error,
          foreground: scheme.onErrorContainer,
        );
      case ClinicalDecisionLevel.urgentReferral:
        return _RiskColors(
          background: scheme.tertiaryContainer,
          border: scheme.tertiary,
          foreground: scheme.onTertiaryContainer,
        );
      case ClinicalDecisionLevel.medicalAdvice:
      case ClinicalDecisionLevel.monitor:
        return _RiskColors(
          background: scheme.secondaryContainer,
          border: scheme.secondary,
          foreground: scheme.onSecondaryContainer,
        );
      case ClinicalDecisionLevel.routine:
        return _RiskColors(
          background: scheme.surfaceContainerHighest,
          border: scheme.outline,
          foreground: scheme.onSurface,
        );
    }
  }
}
