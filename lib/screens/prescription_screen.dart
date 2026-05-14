import 'package:flutter/material.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController prescriptionController =
      TextEditingController();

  final TextEditingController frequencyController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    prescriptionController.text = '''
Rééducation fonctionnelle adaptée au bilan kinésithérapique.

Objectifs :
- Diminution de la douleur
- Amélioration de la mobilité
- Renforcement fonctionnel
- Prévention des récidives

Surveillance clinique régulière recommandée.
''';
  }

  @override
  void dispose() {
    prescriptionController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget customField({
    required String label,
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
        ),
      ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Coordonnées professionnel'),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marc BOUYSSOU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Masseur-Kinésithérapeute'),
                      Text('RPPS : XXXXXXXX'),
                      Text('Téléphone : XX XX XX XX XX'),
                      Text('Email : contact@email.fr'),
                    ],
                  ),
                ),
              ),

              sectionTitle('Cadre clinique'),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Prescription réalisée dans le cadre de l’accès direct '
                    'en kinésithérapie après évaluation clinique.',
                  ),
                ),
              ),

              sectionTitle('Prescription'),

              customField(
                label: 'Prescription / conduite thérapeutique',
                controller: prescriptionController,
                maxLines: 10,
              ),

              Row(
                children: [
                  Expanded(
                    child: customField(
                      label: 'Fréquence',
                      controller: frequencyController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: customField(
                      label: 'Durée',
                      controller: durationController,
                    ),
                  ),
                ],
              ),

              sectionTitle('Nomenclature'),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aide indicative à la cotation NGAP.\n'
                    'Validation finale laissée au professionnel.',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Export PDF bientôt disponible',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exporter en PDF'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}