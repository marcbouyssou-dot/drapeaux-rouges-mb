import 'package:flutter/material.dart';

import '../../../../models/patient_local.dart';
import '../../../../screens/patient_consent_screen.dart';
import '../../../../services/rgpd_local_service.dart';
import 'radar_context_bar.dart';

Future<void> openRadarPatientContext(
  BuildContext context, {
  bool confirmPatientChange = false,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) =>
          PatientConsentScreen(confirmPatientChange: confirmPatientChange),
    ),
  );
}

class RadarPatientContext {
  const RadarPatientContext({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isAssociated,
  });

  const RadarPatientContext.unassociated()
    : primaryLabel = 'Consultation en cours',
      secondaryLabel = 'Patient non associé',
      isAssociated = false;

  factory RadarPatientContext.fromPatient(PatientLocal? patient) {
    if (patient == null) {
      return const RadarPatientContext.unassociated();
    }

    return RadarPatientContext(
      primaryLabel: RgpdLocalService.patientDisplayName(patient),
      secondaryLabel: 'Consultation en cours',
      isAssociated: true,
    );
  }

  final String primaryLabel;
  final String secondaryLabel;
  final bool isAssociated;

  List<String> get displayedValues => [primaryLabel, secondaryLabel];
}

class RadarPatientContextBar extends StatefulWidget {
  const RadarPatientContextBar({
    super.key,
    this.onTap,
    this.confirmPatientChange = false,
  });

  final VoidCallback? onTap;
  final bool confirmPatientChange;

  @override
  State<RadarPatientContextBar> createState() => _RadarPatientContextBarState();
}

class _RadarPatientContextBarState extends State<RadarPatientContextBar> {
  RadarPatientContext _patientContext =
      const RadarPatientContext.unassociated();

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  @override
  Widget build(BuildContext context) {
    return RadarContextBar(
      patientName: _patientContext.primaryLabel,
      status: _patientContext.secondaryLabel,
      onTap: _openContext,
    );
  }

  Future<void> _openContext() async {
    final callback = widget.onTap;
    if (callback != null) {
      callback();
      return;
    }

    await openRadarPatientContext(
      context,
      confirmPatientChange: widget.confirmPatientChange,
    );
    if (!mounted) return;
    await _loadContext();
  }

  Future<void> _loadContext() async {
    try {
      final patient = await RgpdLocalService.getCurrentPatient();
      if (!mounted) return;

      setState(() {
        _patientContext = RadarPatientContext.fromPatient(patient);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _patientContext = const RadarPatientContext.unassociated();
      });
    }
  }
}
