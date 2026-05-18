import 'package:flutter/material.dart';

import '../models/access_direct_model.dart';
import '../services/access_direct_local_service.dart';
import '../services/access_direct_service.dart';

class AccessDirectSettingsScreen extends StatefulWidget {
  const AccessDirectSettingsScreen({super.key});

  @override
  State<AccessDirectSettingsScreen> createState() =>
      _AccessDirectSettingsScreenState();
}

class _AccessDirectSettingsScreenState
    extends State<AccessDirectSettingsScreen> {
  bool isLoading = true;

  bool isCoordinatedExercise = false;
  bool isExperimentalDepartment = false;
  bool hasArsDeclaration = false;
  bool hasMedicalDiagnosis = false;

  int sessionsDone = 0;
  String? diagnosisDocumentPath;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final model = await AccessDirectLocalService.loadSettings();

    if (!mounted) return;

    setState(() {
      isCoordinatedExercise = model.isCoordinatedExercise;
      isExperimentalDepartment = model.isExperimentalDepartment;
      hasArsDeclaration = model.hasArsDeclaration;
      hasMedicalDiagnosis = model.hasMedicalDiagnosis;
      sessionsDone = model.sessionsDone;
      diagnosisDocumentPath = model.diagnosisDocumentPath;
      isLoading = false;
    });
  }

  AccessDirectModel get currentModel {
    return AccessDirectModel(
      isCoordinatedExercise: isCoordinatedExercise,
      isExperimentalDepartment: isExperimentalDepartment,
      hasArsDeclaration: hasArsDeclaration,
      hasMedicalDiagnosis: hasMedicalDiagnosis,
      diagnosisDocumentPath: diagnosisDocumentPath,
      sessionsDone: sessionsDone,
    );
  }

  Future<void> saveSettings() async {
    await AccessDirectLocalService.saveSettings(currentModel);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réglages accès direct enregistrés'),
      ),
    );
  }

  

  void simulateDocumentAdded() {
    setState(() {
      diagnosisDocumentPath = 'justificatif_diagnostic_local_demo.jpg';
    });
  }

  void removeDocument() {
    setState(() {
      diagnosisDocumentPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = currentModel;
    final statusColor = AccessDirectService.statusColor(model);
    final statusIcon = AccessDirectService.statusIcon(model);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Accès direct'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.statusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              model.sessionLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  text: AccessDirectService.adviceMessage(model),
                ),

                const SizedBox(height: 18),

                _SectionTitle('Conditions d’exercice'),

                _SwitchTile(
                  title: 'Exercice coordonné',
                  subtitle: 'MSP, CPTS, centre de santé ou structure coordonnée',
                  value: isCoordinatedExercise,
                  onChanged: (value) {
                    setState(() {
                      isCoordinatedExercise = value;
                    });
                  },
                ),

                _SwitchTile(
                  title: 'Département expérimental',
                  subtitle: 'Le lieu d’exercice est concerné par l’expérimentation',
                  value: isExperimentalDepartment,
                  onChanged: (value) {
                    setState(() {
                      isExperimentalDepartment = value;
                    });
                  },
                ),

                _SwitchTile(
                  title: 'Déclaration ARS effectuée',
                  subtitle: 'Condition administrative déclarée par le praticien',
                  value: hasArsDeclaration,
                  onChanged: (value) {
                    setState(() {
                      hasArsDeclaration = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _SectionTitle('Diagnostic médical préalable'),

                _SwitchTile(
                  title: 'Diagnostic déjà posé',
                  subtitle:
                      'Si oui : pas de limite automatique à 8 séances dans l’app',
                  value: hasMedicalDiagnosis,
                  onChanged: (value) {
                    setState(() {
                      hasMedicalDiagnosis = value;
                      if (!value) {
                        diagnosisDocumentPath = null;
                      }
                    });
                  },
                ),

                if (hasMedicalDiagnosis) ...[
                  const SizedBox(height: 10),
                  _DocumentCard(
                    documentPath: diagnosisDocumentPath,
                    onAdd: simulateDocumentAdded,
                    onRemove: removeDocument,
                  ),
                ],

                const SizedBox(height: 18),

              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: FilledButton.icon(
            onPressed: saveSettings,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer les réglages'),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String text;

  const _InfoCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String? documentPath;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DocumentCard({
    required this.documentPath,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasDocument = documentPath != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasDocument ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasDocument
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasDocument
                ? Icons.check_circle_rounded
                : Icons.add_a_photo_outlined,
            color: hasDocument
                ? const Color(0xFF16A34A)
                : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasDocument
                  ? 'Justificatif ajouté'
                  : 'Ajouter un justificatif photo ou scan',
              style: TextStyle(
                color: hasDocument
                    ? const Color(0xFF166534)
                    : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: hasDocument ? onRemove : onAdd,
            child: Text(hasDocument ? 'Retirer' : 'Ajouter'),
          ),
        ],
      ),
    );
  }
}