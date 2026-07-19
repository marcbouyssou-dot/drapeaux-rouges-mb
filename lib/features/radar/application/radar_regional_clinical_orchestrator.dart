import '../../../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../../../models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import '../../../models/clinical_screening/clinical_screening_question_v4.dart';
import 'radar_clinical_engine_adapter.dart';
import 'radar_clinical_pathway_definition.dart';
import 'radar_clinical_pathway_repository.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_stop_policy.dart';

class RadarRegionalClinicalOrchestrator {
  RadarRegionalClinicalOrchestrator({
    RadarClinicalPathwayRepository? repository,
    RadarClinicalStopPolicy? stopPolicy,
    RadarClinicalEngineAdapter? engineAdapter,
    String Function()? sessionIdFactory,
    RadarClinicalOperatingMode operatingMode =
        RadarClinicalOperatingMode.experimental,
  }) : _repository = repository ?? RadarClinicalPathwayRepository(),
       _stopPolicy = stopPolicy ?? const RadarClinicalStopPolicy(),
       _engineAdapter = engineAdapter ?? RadarClinicalEngineAdapter(),
       _sessionIdFactory =
           sessionIdFactory ??
           (() => 'radar-regional-${DateTime.now().microsecondsSinceEpoch}'),
       _operatingMode = operatingMode;

  final RadarClinicalPathwayRepository _repository;
  final RadarClinicalStopPolicy _stopPolicy;
  final RadarClinicalEngineAdapter _engineAdapter;
  final String Function() _sessionIdFactory;
  final RadarClinicalOperatingMode _operatingMode;

  RadarClinicalPathwayDefinition? _pathway;
  List<RadarPathwaySlot> _activeSlots = const [];
  final List<String> _askedQuestionIds = [];
  final List<RadarContextActivationTrace> _contextActivations = [];
  final Set<String> _answered = {};
  Set<RadarContextGate> _gates = {};
  Set<RadarClinicalTrigger> _triggers = {};
  ClinicalAdaptiveSessionV5? _engineSession;
  String? _sessionId;
  bool _engineEscalated = false;
  RadarClinicalSessionTrace? _lastTrace;
  RadarSessionOutcome? _terminalOutcome;

  RadarClinicalSessionTrace? get lastTrace => _lastTrace;
  RadarSessionOutcome? get currentOutcome => _lastTrace?.producedOutcome;
  String? get sessionId => _sessionId;
  bool get engineHasTakenOver => _engineEscalated;
  ClinicalAdaptiveSessionV5? get engineSession => _engineSession;

  ClinicalAdaptiveViewStateV5? get engineViewState {
    final session = _engineSession;
    final sessionId = _sessionId;
    if (session == null || sessionId == null) {
      return null;
    }

    return _engineAdapter.map(sessionId: sessionId, session: session);
  }

  RadarSessionOutcome? startSession({
    required RadarClinicalRegion region,
    Set<RadarContextGate> gates = const {},
    Set<RadarClinicalTrigger> triggers = const {},
    RadarClinicalInitialContext initialContext =
        const RadarClinicalInitialContext(),
  }) {
    final pathway = _repository.pathwayFor(region);
    _pathway = pathway;
    _gates = {...gates, ...initialContext.gates};
    _triggers = {...triggers, ...initialContext.triggers};
    _answered.clear();
    _askedQuestionIds.clear();
    _contextActivations.clear();
    _activeSlots = pathway.activeSlots(_gates, _triggers);
    _engineSession = _engineAdapter.initialSession();
    _sessionId = _sessionIdFactory();
    _engineEscalated = false;
    _terminalOutcome = null;
    _lastTrace = null;
    _recordInitialContextActivations(pathway);

    if (pathway.traumaTriggersImmediateOrientation &&
        _gates.contains(RadarContextGate.trauma)) {
      _terminalOutcome = RadarSessionOutcome.immediateOrientation;
      _lastTrace = _buildTrace(outcome: _terminalOutcome);
      return _terminalOutcome;
    }

    return null;
  }

  String? nextQuestionId() {
    if (_terminalOutcome != null) {
      return null;
    }

    final session = _requireEngineSession();
    if (session.hasTriggeredHardStop) {
      return null;
    }

    if (_engineEscalated) {
      return session.nextQuestion?.id;
    }

    for (final slot in _activeSlots) {
      if (!_answered.contains(slot.questionId)) {
        return slot.questionId;
      }
    }

    return null;
  }

  ClinicalScreeningQuestionV4? nextQuestion() {
    final questionId = nextQuestionId();
    if (questionId == null) {
      return null;
    }

    return _engineAdapter.questionById(questionId);
  }

  RadarClinicalOrchestratorStep answerCurrentQuestion({
    required bool isPositive,
    Set<RadarClinicalTrigger> newTriggers = const {},
    RadarClinicalResponseContext responseContext =
        const RadarClinicalResponseContext(),
  }) {
    final questionId = nextQuestionId();
    if (questionId == null) {
      throw StateError('No Radar regional question is currently available.');
    }

    return answerQuestion(
      questionId,
      isPositive: isPositive,
      newTriggers: newTriggers,
      responseContext: responseContext,
    );
  }

  RadarClinicalOrchestratorStep answerQuestion(
    String questionId, {
    required bool isPositive,
    Set<RadarClinicalTrigger> newTriggers = const {},
    RadarClinicalResponseContext responseContext =
        const RadarClinicalResponseContext(),
  }) {
    final previous = _requireEngineSession();
    final activeBeforeAnswer = _activeQuestionIds();
    final answered = _engineAdapter.answerQuestion(
      session: previous,
      questionId: questionId,
      isPositive: isPositive,
    );
    _engineSession = answered;
    _answered.add(questionId);
    _askedQuestionIds.add(questionId);

    _activateResponseContext(
      questionId: questionId,
      isPositive: isPositive,
      responseContext: responseContext,
      legacyTriggers: newTriggers,
      activeBeforeAnswer: activeBeforeAnswer,
    );

    if (answered.hasTriggeredHardStop) {
      final outcome = evaluateOutcome(
        engineReportedHardStop: true,
        engineReportedAnyRedFlag: answered.positiveFlagIds.isNotEmpty,
        closureConfirmed: _closureConfirmed(),
      );
      return _step(outcome: outcome);
    }

    if (answered.positiveFlagIds.isNotEmpty) {
      _engineEscalated = true;
      final outcome = evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: true,
        closureConfirmed: _closureConfirmed(),
      );
      return _step(outcome: outcome);
    }

    if (!_engineEscalated && nextQuestionId() == null) {
      final outcome = evaluateOutcome(
        engineReportedHardStop: false,
        engineReportedAnyRedFlag: false,
        closureConfirmed: _closureConfirmed(),
      );
      return _step(outcome: outcome);
    }

    return _step();
  }

  void onQuestionAnswered(
    String questionId, {
    Set<RadarClinicalTrigger> newTriggers = const {},
  }) {
    final activeBeforeAnswer = _activeQuestionIds();
    _answered.add(questionId);
    _askedQuestionIds.add(questionId);
    if (newTriggers.isNotEmpty) {
      _activateContext(
        source: RadarContextActivationSource.clinicalAnswer,
        sourceQuestionId: questionId,
        gates: const {},
        triggers: newTriggers,
        activeBefore: activeBeforeAnswer,
      );
    }
  }

  void onEngineFlagRaised() {
    _engineEscalated = true;
  }

  RadarSessionOutcome evaluateOutcome({
    required bool engineReportedHardStop,
    required bool engineReportedAnyRedFlag,
    required bool closureConfirmed,
  }) {
    final pathway = _requirePathway();
    final state = RadarRegionalSessionState(
      region: pathway.region,
      answeredQuestionIds: _answered,
      activeQuestionIds: _activeSlots.map((s) => s.questionId).toSet(),
      engineReportedHardStop: engineReportedHardStop,
      engineReportedAnyRedFlag: engineReportedAnyRedFlag,
      closureConfirmed: closureConfirmed,
      traumaGateActive: _gates.contains(RadarContextGate.trauma),
    );
    final outcome = _stopPolicy.evaluate(state, pathway);
    _terminalOutcome = outcome == RadarSessionOutcome.delegateToEngine
        ? null
        : outcome;
    _lastTrace = _buildTrace(outcome: outcome);
    return outcome;
  }

  ClinicalAdaptiveSessionV5 _requireEngineSession() {
    final session = _engineSession;
    if (session == null) {
      throw StateError('No Radar regional session has been started.');
    }

    return session;
  }

  RadarClinicalPathwayDefinition _requirePathway() {
    final pathway = _pathway;
    if (pathway == null) {
      throw StateError('No Radar regional session has been started.');
    }

    return pathway;
  }

  bool _closureConfirmed() {
    for (final entry in _requireEngineSession().answeredQuestionIds.entries) {
      if (!entry.value) {
        continue;
      }

      final matchingSlot = _activeSlots.where(
        (slot) => slot.questionId == entry.key,
      );
      if (matchingSlot.any((slot) => slot.role == RadarQuestionRole.closure)) {
        return true;
      }
    }

    return false;
  }

  RadarClinicalOrchestratorStep _step({RadarSessionOutcome? outcome}) {
    final session = _requireEngineSession();
    _lastTrace = _buildTrace(outcome: outcome);
    return RadarClinicalOrchestratorStep(
      nextQuestionId: nextQuestionId(),
      outcome: outcome,
      engineSession: session,
      engineViewState: _engineAdapter.map(
        sessionId: _sessionId!,
        session: session,
      ),
      trace: _lastTrace,
    );
  }

  RadarClinicalSessionTrace _buildTrace({
    required RadarSessionOutcome? outcome,
  }) {
    final pathway = _requirePathway();
    final engineSession = _engineSession;
    final activeIds = _activeSlots.map((slot) => slot.questionId).toSet();
    final allPathwaySlots = {
      for (final slot in pathway.slots) slot.questionId: slot,
    };

    return RadarClinicalSessionTrace(
      matrixVersion: kRadarPathwayMatrixVersion,
      validationStatus: kRadarPathwayClinicalValidationStatus,
      operatingMode: _operatingMode,
      region: pathway.region,
      contextGates: _gates,
      clinicalTriggers: _triggers,
      contextActivations: _contextActivations,
      askedQuestionIds: _askedQuestionIds,
      excludedQuestionRationales: _excludedQuestionRationales(
        catalogIds: _engineAdapter.catalogQuestionIds,
        activeIds: activeIds,
        pathwaySlotsById: allPathwaySlots,
        pathway: pathway,
      ),
      activatedOverflowIds: _overflowIds(),
      producedOutcome: outcome,
      producedEngineDecisionLevel: engineViewState?.finalDecisionLevel,
      engineVersion: kRadarClinicalEngineVersion,
      engineTechnicalSummary: engineSession?.reasoningSummary,
    );
  }

  List<String> _overflowIds() {
    if (!_engineEscalated) {
      return const [];
    }

    final regionalIds = _activeSlots.map((slot) => slot.questionId).toSet();
    return _askedQuestionIds
        .where((id) => !regionalIds.contains(id))
        .toList(growable: false);
  }

  Map<String, String> _excludedQuestionRationales({
    required Set<String> catalogIds,
    required Set<String> activeIds,
    required Map<String, RadarPathwaySlot> pathwaySlotsById,
    required RadarClinicalPathwayDefinition pathway,
  }) {
    return {
      for (final id in catalogIds)
        if (!activeIds.contains(id))
          id:
              pathwaySlotsById[id]?.rationale ??
              'Exclue du pathway ${pathway.region.name} - voir matrice '
                  '$kRadarPathwayMatrixVersion',
    };
  }

  Set<String> _activeQuestionIds() =>
      _activeSlots.map((slot) => slot.questionId).toSet();

  void _recordInitialContextActivations(
    RadarClinicalPathwayDefinition pathway,
  ) {
    final ids = [
      ..._gates.map((gate) => 'gate.${gate.name}'),
      ..._triggers.map((trigger) => 'trigger.${trigger.name}'),
    ];
    if (ids.isEmpty) {
      return;
    }

    final baseline = pathway.activeSlots(const {}, const {});
    final baselineIds = baseline.map((slot) => slot.questionId).toSet();
    final accessible = _activeQuestionIds().difference(baselineIds);
    for (final id in ids) {
      _contextActivations.add(
        RadarContextActivationTrace(
          id: id,
          source: RadarContextActivationSource.initialContext,
          sourceQuestionId: null,
          activatedAfterAnswerCount: 0,
          accessibleQuestionIds: accessible,
        ),
      );
    }
  }

  void _activateResponseContext({
    required String questionId,
    required bool isPositive,
    required RadarClinicalResponseContext responseContext,
    required Set<RadarClinicalTrigger> legacyTriggers,
    required Set<String> activeBeforeAnswer,
  }) {
    if (!isPositive) {
      return;
    }

    final derived = _contextFromPositiveAnswer(questionId);
    final gates = {...responseContext.gates, ...derived.gates};
    final triggers = {
      ...legacyTriggers,
      ...responseContext.triggers,
      ...derived.triggers,
    };

    _activateContext(
      source: RadarContextActivationSource.clinicalAnswer,
      sourceQuestionId: questionId,
      gates: gates,
      triggers: triggers,
      activeBefore: activeBeforeAnswer,
    );
  }

  RadarClinicalResponseContext _contextFromPositiveAnswer(String questionId) {
    return switch (questionId) {
      'v4_fracture_ouverte_001' => const RadarClinicalResponseContext(
        gates: {RadarContextGate.trauma},
      ),
      'v4_fracture_risk_001' => const RadarClinicalResponseContext(
        gates: {RadarContextGate.trauma, RadarContextGate.ageOrBoneFragility},
      ),
      'v4_cardiorespiratory_001' ||
      'v4_embolie_pulmonaire_001' => const RadarClinicalResponseContext(
        triggers: {RadarClinicalTrigger.dyspneaOrMalaise},
      ),
      'v4_aaa_vascular_abdominal_001' => const RadarClinicalResponseContext(
        triggers: {
          RadarClinicalTrigger.lumboabdominalPain,
          RadarClinicalTrigger.cardiovascularRiskFactors,
        },
      ),
      _ => const RadarClinicalResponseContext(),
    };
  }

  void _activateContext({
    required RadarContextActivationSource source,
    required String? sourceQuestionId,
    required Set<RadarContextGate> gates,
    required Set<RadarClinicalTrigger> triggers,
    required Set<String> activeBefore,
  }) {
    final newGates = gates.difference(_gates);
    final newTriggers = triggers.difference(_triggers);
    if (newGates.isEmpty && newTriggers.isEmpty) {
      return;
    }

    _gates = {..._gates, ...newGates};
    _triggers = {..._triggers, ...newTriggers};
    _activeSlots = _requirePathway().activeSlots(_gates, _triggers);
    final newlyAccessible = _activeQuestionIds().difference(activeBefore);
    final answerCount = _askedQuestionIds.length;

    for (final gate in newGates) {
      _contextActivations.add(
        RadarContextActivationTrace(
          id: 'gate.${gate.name}',
          source: source,
          sourceQuestionId: sourceQuestionId,
          activatedAfterAnswerCount: answerCount,
          accessibleQuestionIds: newlyAccessible,
        ),
      );
    }
    for (final trigger in newTriggers) {
      _contextActivations.add(
        RadarContextActivationTrace(
          id: 'trigger.${trigger.name}',
          source: source,
          sourceQuestionId: sourceQuestionId,
          activatedAfterAnswerCount: answerCount,
          accessibleQuestionIds: newlyAccessible,
        ),
      );
    }
  }
}

class RadarClinicalOrchestratorStep {
  final String? nextQuestionId;
  final RadarSessionOutcome? outcome;
  final ClinicalAdaptiveSessionV5 engineSession;
  final ClinicalAdaptiveViewStateV5 engineViewState;
  final RadarClinicalSessionTrace? trace;

  const RadarClinicalOrchestratorStep({
    required this.nextQuestionId,
    required this.outcome,
    required this.engineSession,
    required this.engineViewState,
    required this.trace,
  });
}

class RadarClinicalSessionTrace {
  final String matrixVersion;
  final String validationStatus;
  final RadarClinicalOperatingMode operatingMode;
  final RadarClinicalRegion region;
  final Set<RadarContextGate> contextGates;
  final Set<RadarClinicalTrigger> clinicalTriggers;
  final List<RadarContextActivationTrace> contextActivations;
  final List<String> askedQuestionIds;
  final Map<String, String> excludedQuestionRationales;
  final List<String> activatedOverflowIds;
  final RadarSessionOutcome? producedOutcome;
  final Object? producedEngineDecisionLevel;
  final String engineVersion;
  final String? engineTechnicalSummary;

  RadarClinicalSessionTrace({
    required this.matrixVersion,
    required this.validationStatus,
    required this.operatingMode,
    required this.region,
    required Set<RadarContextGate> contextGates,
    required Set<RadarClinicalTrigger> clinicalTriggers,
    required List<RadarContextActivationTrace> contextActivations,
    required List<String> askedQuestionIds,
    required Map<String, String> excludedQuestionRationales,
    required List<String> activatedOverflowIds,
    required this.producedOutcome,
    required this.producedEngineDecisionLevel,
    required this.engineVersion,
    required this.engineTechnicalSummary,
  }) : contextGates = Set.unmodifiable(contextGates),
       clinicalTriggers = Set.unmodifiable(clinicalTriggers),
       contextActivations = List.unmodifiable(contextActivations),
       askedQuestionIds = List.unmodifiable(askedQuestionIds),
       excludedQuestionRationales = Map.unmodifiable(
         excludedQuestionRationales,
       ),
       activatedOverflowIds = List.unmodifiable(activatedOverflowIds);
}
