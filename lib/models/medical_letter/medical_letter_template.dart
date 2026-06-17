import 'package:flutter/material.dart';

import 'medical_letter_type.dart';

class MedicalLetterTemplate {
  const MedicalLetterTemplate({
    required this.type,
    required this.title,
    required this.pdfTitle,
    required this.icon,
    required this.color,
  });

  final MedicalLetterType type;
  final String title;
  final String pdfTitle;
  final IconData icon;
  final Color color;

  String get id => type.id;
}

const medicalLetterTemplates = [
  MedicalLetterTemplate(
    type: MedicalLetterType.generalPractitionerInfo,
    title: 'Information médecin traitant',
    pdfTitle: 'COURRIER D’INFORMATION AU MÉDECIN TRAITANT',
    icon: Icons.local_hospital_outlined,
    color: Color(0xFF2563EB),
  ),
  MedicalLetterTemplate(
    type: MedicalLetterType.medicalOrientation,
    title: 'Orientation médicale',
    pdfTitle: 'COURRIER D’ORIENTATION MÉDICALE',
    icon: Icons.medical_information_outlined,
    color: Color(0xFFDC2626),
  ),
  MedicalLetterTemplate(
    type: MedicalLetterType.specialistOpinion,
    title: 'Avis spécialisé',
    pdfTitle: 'DEMANDE D’AVIS SPÉCIALISÉ',
    icon: Icons.manage_search_outlined,
    color: Color(0xFF0F766E),
  ),
];

MedicalLetterTemplate medicalLetterTemplateByTypeId(String typeId) {
  return medicalLetterTemplates.firstWhere(
    (template) => template.type.id == typeId,
    orElse: () => medicalLetterTemplates.first,
  );
}
