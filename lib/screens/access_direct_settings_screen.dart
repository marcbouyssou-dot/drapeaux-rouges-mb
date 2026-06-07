import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? diagnosisDocumentName;
  String? diagnosisDocumentBase64;
  String? diagnosisDocumentAddedAt;

  final ImagePicker picker = ImagePicker();

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
      diagnosisDocumentName = model.diagnosisDocumentName;
      diagnosisDocumentBase64 = model.diagnosisDocumentBase64;
      diagnosisDocumentAddedAt = model.diagnosisDocumentAddedAt;
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
      diagnosisDocumentName: diagnosisDocumentName,
      diagnosisDocumentBase64: diagnosisDocumentBase64,
      diagnosisDocumentAddedAt: diagnosisDocumentAddedAt,
      sessionsDone: sessionsDone,
    );
  }

  Future<void> saveSettings() async {
    await AccessDirectLocalService.saveSettings(currentModel);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réglages accès direct enregistrés')),
    );
  }

  Future<void> chooseDocumentSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('Importer depuis la galerie'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    await pickDiagnosisDocument(source);
  }

  Future<void> pickDiagnosisDocument(ImageSource source) async {
    final XFile? document = await picker.pickImage(
      source: source,
      imageQuality: 82,
    );

    if (document == null) return;

    final bytes = await document.readAsBytes();
    final updatedAt = DateTime.now().toIso8601String();

    setState(() {
      diagnosisDocumentPath = document.path;
      diagnosisDocumentName = document.name;
      diagnosisDocumentBase64 = base64Encode(bytes);
      diagnosisDocumentAddedAt = updatedAt;
    });

    await AccessDirectLocalService.saveSettings(currentModel);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Justificatif médical ajouté')),
    );
  }

  Future<void> removeDocument() async {
    setState(() {
      diagnosisDocumentPath = null;
      diagnosisDocumentName = null;
      diagnosisDocumentBase64 = null;
      diagnosisDocumentAddedAt = null;
    });

    await AccessDirectLocalService.saveSettings(currentModel);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Justificatif médical supprimé')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = currentModel;
    final statusColor = AccessDirectService.statusColor(model);
    final statusIcon = AccessDirectService.statusIcon(model);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                children: [
                  buildHeader(context),
                  const SizedBox(height: 12),
                  buildStatusCard(
                    model: model,
                    statusColor: statusColor,
                    statusIcon: statusIcon,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(text: AccessDirectService.adviceMessage(model)),
                  const SizedBox(height: 16),
                  const _SectionTitle('Conditions d’exercice'),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    title: 'Exercice coordonné',
                    subtitle:
                        'MSP, CPTS, centre de santé ou structure coordonnée.',
                    value: isCoordinatedExercise,
                    onChanged: (value) {
                      setState(() {
                        isCoordinatedExercise = value;
                      });
                    },
                  ),
                  _SwitchTile(
                    title: 'Département expérimental',
                    subtitle: 'Lieu d’exercice concerné par l’expérimentation.',
                    value: isExperimentalDepartment,
                    onChanged: (value) {
                      setState(() {
                        isExperimentalDepartment = value;
                      });
                    },
                  ),
                  _SwitchTile(
                    title: 'Déclaration ARS effectuée',
                    subtitle:
                        'Condition administrative déclarée par le praticien.',
                    value: hasArsDeclaration,
                    onChanged: (value) {
                      setState(() {
                        hasArsDeclaration = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  const _SectionTitle('Diagnostic médical préalable'),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    title: 'Diagnostic déjà posé',
                    subtitle:
                        'Si oui : pas de limite automatique à 8 séances dans l’app.',
                    value: hasMedicalDiagnosis,
                    onChanged: (value) {
                      setState(() {
                        hasMedicalDiagnosis = value;
                        if (!value) {
                          diagnosisDocumentPath = null;
                          diagnosisDocumentName = null;
                          diagnosisDocumentBase64 = null;
                          diagnosisDocumentAddedAt = null;
                        }
                      });
                    },
                  ),
                  if (hasMedicalDiagnosis) ...[
                    const SizedBox(height: 8),
                    _DocumentCard(
                      documentPath: diagnosisDocumentPath,
                      documentName: diagnosisDocumentName,
                      documentAddedAt: diagnosisDocumentAddedAt,
                      hasStoredDocument:
                          diagnosisDocumentBase64?.trim().isNotEmpty ?? false,
                      onAdd: chooseDocumentSource,
                      onRemove: removeDocument,
                    ),
                  ],
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: FilledButton.icon(
            onPressed: saveSettings,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 18,
              color: const Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
              ),
            ),
            child: const Icon(
              Icons.medical_information_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Accès direct',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusCard({
    required AccessDirectModel model,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.86)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  model.sessionLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2563EB),
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 13.5,
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
    final activeColor = value
        ? const Color(0xFF2563EB)
        : const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: value ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              value ? Icons.check_rounded : Icons.remove_rounded,
              color: activeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String? documentPath;
  final String? documentName;
  final String? documentAddedAt;
  final bool hasStoredDocument;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DocumentCard({
    required this.documentPath,
    required this.documentName,
    required this.documentAddedAt,
    required this.hasStoredDocument,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasDocument =
        hasStoredDocument || (documentPath?.trim().isNotEmpty ?? false);
    final label = hasDocument
        ? (documentName?.trim().isNotEmpty ?? false)
              ? documentName!.trim()
              : 'Justificatif médical ajouté'
        : 'Aucun justificatif ajouté';
    final addedAt = _formatAddedAt(documentAddedAt);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: hasDocument ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasDocument
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasDocument
                            ? const Color(0xFF166534)
                            : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasDocument
                          ? 'Stocké localement sur cet appareil${addedAt == null ? '' : ' · $addedAt'}'
                          : 'Photo ou import depuis la galerie',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: Icon(
                    hasDocument
                        ? Icons.change_circle_outlined
                        : Icons.add_a_photo_outlined,
                  ),
                  label: Text(hasDocument ? 'Remplacer' : 'Ajouter'),
                ),
              ),
              if (hasDocument) ...[
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Supprimer'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String? _formatAddedAt(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final date = DateTime.tryParse(raw);
    if (date == null) return null;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return 'ajouté le $day/$month/$year';
  }
}
