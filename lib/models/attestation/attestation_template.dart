import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'attestation_type.dart';

enum AttestationTemplateStatus { active, prepared }

class AttestationTemplate {
  const AttestationTemplate({
    required this.type,
    required this.title,
    required this.pdfTitle,
    required this.status,
    required this.icon,
    required this.color,
  });

  final AttestationType type;
  final String title;
  final String pdfTitle;
  final AttestationTemplateStatus status;
  final IconData icon;
  final Color color;

  bool get isActive => status == AttestationTemplateStatus.active;

  String get statusLabel {
    switch (status) {
      case AttestationTemplateStatus.active:
        return 'Actif';
      case AttestationTemplateStatus.prepared:
        return 'Préparé';
    }
  }
}

const attestationTemplates = [
  AttestationTemplate(
    type: AttestationType.nearestAvailableMk,
    title: 'MK le plus proche disponible',
    pdfTitle: 'ATTESTATION SUR L’HONNEUR',
    status: AttestationTemplateStatus.active,
    icon: Icons.assignment_turned_in_outlined,
    color: AppColors.primary,
  ),
  AttestationTemplate(
    type: AttestationType.refusedMedicalOrientation,
    title: 'Refus d’orientation médicale proposée',
    pdfTitle: 'ATTESTATION DE REFUS D’ORIENTATION MÉDICALE',
    status: AttestationTemplateStatus.prepared,
    icon: Icons.medical_information_outlined,
    color: AppColors.warningDark,
  ),
  AttestationTemplate(
    type: AttestationType.reinforcedConsent,
    title: 'Consentement éclairé renforcé',
    pdfTitle: 'ATTESTATION DE CONSENTEMENT ÉCLAIRÉ RENFORCÉ',
    status: AttestationTemplateStatus.prepared,
    icon: Icons.verified_user_outlined,
    color: AppColors.teal,
  ),
  AttestationTemplate(
    type: AttestationType.directAccessCare,
    title: 'Prise en charge en accès direct',
    pdfTitle: 'ATTESTATION DE PRISE EN CHARGE EN ACCÈS DIRECT',
    status: AttestationTemplateStatus.prepared,
    icon: Icons.home_repair_service_outlined,
    color: AppColors.raspberry,
  ),
];
