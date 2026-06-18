import 'package:flutter/material.dart';

import '../models/access_direct_model.dart';

class AccessDirectService {
  static Color statusColor(AccessDirectModel model) {
    if (!model.isAccessDirectEligible) {
      return const Color(0xFFEF4444);
    }

    if (model.hasMedicalDiagnosis && !model.hasDiagnosisProof) {
      return const Color(0xFFF59E0B);
    }

    if (model.isSessionLimitReached) {
      return const Color(0xFFDC2626);
    }

    if (model.shouldAlertBeforeLimit) {
      return const Color(0xFFF97316);
    }

    return const Color(0xFF16A34A);
  }

  static IconData statusIcon(AccessDirectModel model) {
    if (!model.isAccessDirectEligible) {
      return Icons.warning_amber_rounded;
    }

    if (model.hasMedicalDiagnosis && !model.hasDiagnosisProof) {
      return Icons.file_upload_outlined;
    }

    if (model.isSessionLimitReached) {
      return Icons.block_rounded;
    }

    if (model.shouldAlertBeforeLimit) {
      return Icons.error_outline_rounded;
    }

    return Icons.verified_rounded;
  }

  static String adviceMessage(AccessDirectModel model) {
    if (!model.isAccessDirectEligible) {
      return 'Vérifier les conditions d’exercice coordonné, département expérimental et déclaration ARS avant d’utiliser le mode accès direct.';
    }

    if (model.hasMedicalDiagnosis && !model.hasDiagnosisProof) {
      return 'Un diagnostic préalable est déclaré. Ajouter un justificatif dans le dossier patient.';
    }

    if (!model.hasMedicalDiagnosis && model.isSessionLimitReached) {
      return 'Limite de 8 séances atteinte sans diagnostic médical préalable. Orientation médicale recommandée.';
    }

    if (!model.hasMedicalDiagnosis && model.shouldAlertBeforeLimit) {
      return 'Approche de la limite réglementaire de 8 séances sans diagnostic médical préalable.';
    }

    if (model.hasMedicalDiagnosis) {
      return 'Diagnostic préalable documenté : suivi possible selon les recommandations de bonnes pratiques.';
    }

    return 'Accès direct possible avec limite de 8 séances maximum.';
  }
}
