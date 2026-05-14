import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../models/prescription_model.dart';
import '../services/prescription_service.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController professionalController =
      TextEditingController();

  final TextEditingController patientController =
      TextEditingController();

  final TextEditingController clinicalContextController =
      TextEditingController();

  final TextEditingController prescriptionController =
      TextEditingController();

  final TextEditingController frequencyController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  final TextEditingController nomenclatureController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    professionalController.text =
        'Marc BOUYSSOU\nMasseur-Kinésithérapeute\nRPPS / ADELI : à compléter\nTéléphone : à compléter\nEmail : à compléter';

    patientController.text =
        'Nom : à compléter\nPrénom : à compléter\nDate de naissance : à compléter';

    clinicalContextController.text =
        'Prescription réalisée dans le cadre de l’accès direct en kinésithérapie après évaluation clinique.\n\nAbsence de signe d’urgence nécessitant une réorientation immédiate à ce stade.';

    prescriptionController.text =
        'Rééducation fonctionnelle adaptée au bilan kinésithérapique.\n\nObjectifs :\n- Diminution de la douleur\n- Amélioration de la mobilité\n- Renforcement fonctionnel\n- Reprise progressive des activités\n- Prévention des récidives\n\nSurveillance clinique régulière recommandée.';

    frequencyController.text = 'Exemple : 2 séances par semaine';

    durationController.text = 'Exemple : 6 semaines';

    nomenclatureController.text =
        'Aide indicative à la nomenclature / cotation selon le contexte clinique.\n\nLa validation finale reste sous la responsabilité du professionnel.';
  }

  @override
  void dispose() {
    professionalController.dispose();
    patientController.dispose();
    clinicalContextController.dispose();
    prescriptionController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    nomenclatureController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget editableCard({
    required String title,
    required TextEditingController controller,
    int maxLines = 4,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
          style: const TextStyle(
            fontSize: 16,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  void showComingSoonMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF bientôt disponible'),
      ),
    );
  }
PrescriptionModel buildPrescription() {
  return PrescriptionModel(
    professional: professionalController.text,
    patient: patientController.text,
    clinicalContext: clinicalContextController.text,
    prescription: prescriptionController.text,
    frequency: frequencyController.text,
    duration: durationController.text,
    nomenclature: nomenclatureController.text,
    createdAt: DateTime.now(),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription MK'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Coordonnées professionnel'),
              editableCard(
                title: 'Professionnel',
                controller: professionalController,
                maxLines: 5,
              ),

              sectionTitle('Patient'),
              editableCard(
                title: 'Identité patient locale',
                controller: patientController,
                maxLines: 4,
              ),

              sectionTitle('Cadre accès direct'),
              editableCard(
                title: 'Cadre clinique',
                controller: clinicalContextController,
                maxLines: 5,
              ),

              sectionTitle('Prescription pré-remplie'),
              editableCard(
                title: 'Prescription / conduite thérapeutique',
                controller: prescriptionController,
                maxLines: 12,
              ),

              sectionTitle('Fréquence et durée'),
              editableCard(
                title: 'Fréquence',
                controller: frequencyController,
                maxLines: 2,
              ),
              editableCard(
                title: 'Durée / nombre de séances',
                controller: durationController,
                maxLines: 2,
              ),

              sectionTitle('Nomenclature'),
              editableCard(
                title: 'Aide nomenclature',
                controller: nomenclatureController,
                maxLines: 5,
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prescription = buildPrescription();

                    await PrescriptionService.savePrescription(prescription);

                    debugPrint(prescription.toMap().toString());

                    showComingSoonMessage();
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    'Exporter en PDF',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}