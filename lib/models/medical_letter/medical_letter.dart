import '../evaluation_model.dart';
import '../patient_local.dart';
import '../practitioner_profile.dart';
import 'medical_letter_template.dart';
import 'medical_letter_type.dart';

class MedicalLetter {
  const MedicalLetter({
    required this.template,
    required this.patient,
    required this.practitioner,
    required this.date,
    required this.lieu,
    this.evaluation,
    this.subject = '',
    this.bodyParagraphsOverride = const [],
  });

  final MedicalLetterTemplate template;
  final PatientLocal? patient;
  final PractitionerProfile practitioner;
  final DateTime date;
  final String lieu;
  final EvaluationModel? evaluation;
  final String subject;
  final List<String> bodyParagraphsOverride;

  String get patientFullName {
    if (patient == null) return 'Patient non identifié';

    final nom = patient!.nom.trim().toUpperCase();
    final prenom = patient!.prenom.trim();
    final value = '$nom $prenom'.trim();

    return value.isEmpty ? 'Patient non identifié' : value;
  }

  String get patientBirthDate {
    return patient?.dateNaissance.trim() ?? '';
  }

  String get patientContactLine {
    final parts = <String>[
      patient?.adresse.trim() ?? '',
      [
        patient?.codePostal.trim() ?? '',
        patient?.ville.trim() ?? '',
      ].where((item) => item.isNotEmpty).join(' '),
    ].where((item) => item.isNotEmpty).toList();

    return parts.join(' · ');
  }

  String get treatingDoctorName {
    final value = patient?.medecinNom.trim() ?? '';
    return value.isEmpty ? 'Médecin traitant non renseigné' : value;
  }

  String get treatingDoctorDetails {
    final patientData = patient;
    if (patientData == null) return '';

    final parts = <String>[];
    if (patientData.medecinRpps.trim().isNotEmpty) {
      parts.add('RPPS : ${patientData.medecinRpps.trim()}');
    }
    if (patientData.medecinAdeli.trim().isNotEmpty) {
      parts.add('ADELI : ${patientData.medecinAdeli.trim()}');
    }
    if (patientData.medecinAdresse.trim().isNotEmpty) {
      parts.add(patientData.medecinAdresse.trim());
    }
    if (patientData.medecinTelephone.trim().isNotEmpty) {
      parts.add('Téléphone : ${patientData.medecinTelephone.trim()}');
    }
    if (patientData.medecinEmail.trim().isNotEmpty) {
      parts.add('Email : ${patientData.medecinEmail.trim()}');
    }

    return parts.join(' · ');
  }

  String get practitionerFullName {
    final value = practitioner.fullName.trim();
    return value.isEmpty ? 'Masseur-kinésithérapeute non renseigné' : value;
  }

  String get practitionerIdentifier {
    final rpps = practitioner.rpps.trim();
    final adeli = practitioner.adeli.trim();

    if (rpps.isNotEmpty && adeli.isNotEmpty) {
      return 'RPPS : $rpps · ADELI : $adeli';
    }
    if (rpps.isNotEmpty) return 'RPPS : $rpps';
    if (adeli.isNotEmpty) return 'ADELI : $adeli';

    return '';
  }

  String get effectiveSubject {
    final value = subject.trim();
    if (value.isNotEmpty) return value;

    switch (template.type) {
      case MedicalLetterType.generalPractitionerInfo:
        return 'Information relative à la prise en charge kinésithérapique';
      case MedicalLetterType.medicalOrientation:
        return 'Orientation médicale proposée après évaluation clinique';
      case MedicalLetterType.specialistOpinion:
        return 'Demande d’avis spécialisé';
    }
  }

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String get effectiveCity {
    final value = lieu.trim();
    return value.isEmpty ? '' : value;
  }

  bool get hasPractitionerSignature {
    return practitioner.signatureBase64.trim().isNotEmpty;
  }

  String get clinicalSummary {
    final summary = evaluation?.clinicalReasoning?.summary.trim() ?? '';
    if (summary.isNotEmpty) return summary;

    final legacySummary = evaluation?.aiSummary.trim() ?? '';
    if (legacySummary.isNotEmpty &&
        legacySummary != 'Synthèse IA non disponible.') {
      return legacySummary;
    }

    return '';
  }

  List<String> get clinicalContextLines {
    final currentEvaluation = evaluation;
    if (currentEvaluation == null) return const [];

    final lines = <String>[
      'Motif : ${currentEvaluation.motif}',
      'Niveau de risque retenu : ${currentEvaluation.riskLevel}',
      'Score : ${currentEvaluation.score} · Drapeaux rouges : ${currentEvaluation.checkedCount}',
      'Orientation proposée : ${currentEvaluation.decisionTitle}',
    ];

    if (clinicalSummary.isNotEmpty) {
      lines.add('Synthèse clinique enregistrée : $clinicalSummary');
    }

    return lines;
  }

  List<String> get bodyParagraphs {
    if (bodyParagraphsOverride.isNotEmpty) return bodyParagraphsOverride;

    switch (template.type) {
      case MedicalLetterType.generalPractitionerInfo:
        return [
          'Madame, Monsieur,',
          'Je vous informe avoir reçu en prise en charge kinésithérapique $patientFullName.',
          if (patientBirthDate.isNotEmpty)
            'Date de naissance renseignée : $patientBirthDate.',
          if (patientContactLine.isNotEmpty)
            'Coordonnées patient disponibles : $patientContactLine.',
          ...clinicalContextLines,
          'Ce courrier vise à partager les éléments utiles au suivi du patient et ne se substitue pas à votre appréciation médicale.',
          'Je reste disponible pour tout complément utile à la coordination de la prise en charge.',
        ];

      case MedicalLetterType.medicalOrientation:
        return [
          'Madame, Monsieur,',
          'À la suite de l’évaluation clinique de $patientFullName, une orientation médicale est proposée au regard des éléments recueillis.',
          if (patientBirthDate.isNotEmpty)
            'Date de naissance renseignée : $patientBirthDate.',
          ...clinicalContextLines,
          'Cette demande d’orientation est formulée par prudence clinique et nécessite une validation médicale adaptée à la situation du patient.',
          'Le présent courrier ne constitue pas un diagnostic et ne remplace pas l’avis médical.',
        ];

      case MedicalLetterType.specialistOpinion:
        return [
          'Madame, Monsieur,',
          'Je sollicite un avis spécialisé concernant $patientFullName afin de compléter l’analyse clinique et d’orienter la suite de la prise en charge.',
          if (patientBirthDate.isNotEmpty)
            'Date de naissance renseignée : $patientBirthDate.',
          ...clinicalContextLines,
          'Les éléments transmis correspondent aux informations disponibles au moment de l’évaluation et doivent être interprétés dans le cadre d’un avis spécialisé.',
          'Le praticien reste responsable de la validation clinique et de la décision finale.',
        ];
    }
  }
}
