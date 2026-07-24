import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/access_direct_model.dart';
import '../services/access_direct_local_service.dart';
import '../services/access_direct_service.dart';
import '../features/radar/presentation/theme/radar_colors.dart';
import '../features/radar/presentation/theme/radar_layout.dart';
import '../features/radar/presentation/theme/radar_radius.dart';
import '../features/radar/presentation/theme/radar_shadows.dart';
import '../features/radar/presentation/theme/radar_spacing.dart';
import '../features/radar/presentation/theme/radar_text_styles.dart';
import '../features/radar/presentation/theme/radar_theme.dart';

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
    final content = isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(
              RadarSpacing.xl,
              RadarSpacing.xl,
              RadarSpacing.xl,
              120,
            ),
            children: [
              buildHeader(context),
              const SizedBox(height: RadarSpacing.lg),
              buildStatusCard(
                model: model,
                statusColor: statusColor,
                statusIcon: statusIcon,
              ),
              const SizedBox(height: RadarSpacing.lg),
              _InfoCard(text: AccessDirectService.adviceMessage(model)),
              const SizedBox(height: RadarSpacing.xl),
              const _SectionTitle('Conditions d’exercice'),
              const SizedBox(height: RadarSpacing.sm),
              _SwitchTile(
                title: 'Exercice coordonné',
                subtitle: 'MSP, CPTS, centre de santé ou structure coordonnée.',
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
                subtitle: 'Condition administrative déclarée par le praticien.',
                value: hasArsDeclaration,
                onChanged: (value) {
                  setState(() {
                    hasArsDeclaration = value;
                  });
                },
              ),
              const SizedBox(height: RadarSpacing.lg),
              const _SectionTitle('Diagnostic médical préalable'),
              const SizedBox(height: RadarSpacing.sm),
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
                const SizedBox(height: RadarSpacing.sm),
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
          );

    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RadarLayout.workflowWidth,
              ),
              child: content,
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              RadarSpacing.xl,
              RadarSpacing.md,
              RadarSpacing.xl,
              RadarSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: RadarColors.surface.withValues(alpha: 0.98),
              border: const Border(top: BorderSide(color: RadarColors.border)),
              boxShadow: RadarShadows.navigation,
            ),
            child: FilledButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: RadarColors.surface,
              borderRadius: BorderRadius.circular(RadarRadius.small),
              border: Border.all(color: RadarColors.border),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 18,
              color: RadarColors.primary,
            ),
          ),
          const SizedBox(width: RadarSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RadarColors.clinicalWarning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: const Icon(
              Icons.medical_information_outlined,
              color: RadarColors.clinicalWarning,
              size: 26,
            ),
          ),
          const SizedBox(width: RadarSpacing.lg),
          const Expanded(
            child: Text('Accès direct', style: RadarTextStyles.question),
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
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadarRadius.card),
            ),
            child: Icon(statusIcon, color: statusColor, size: 31),
          ),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.statusLabel, style: RadarTextStyles.sectionTitle),
                const SizedBox(height: RadarSpacing.xs),
                Text(model.sessionLabel, style: RadarTextStyles.secondary),
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
        style: RadarTextStyles.badge.copyWith(color: RadarColors.textMuted),
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
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: RadarColors.surfaceMuted,
        borderRadius: BorderRadius.circular(RadarRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: RadarColors.primary,
            size: 23,
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Text(
              text,
              style: RadarTextStyles.secondary.copyWith(
                color: RadarColors.clinicalAction,
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
    final activeColor = value ? RadarColors.primary : RadarColors.blueGrey;

    return Container(
      margin: const EdgeInsets.only(bottom: RadarSpacing.md),
      padding: const EdgeInsets.fromLTRB(
        RadarSpacing.lg,
        RadarSpacing.lg,
        RadarSpacing.md,
        RadarSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(
              value ? Icons.check_rounded : Icons.remove_rounded,
              color: activeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: RadarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RadarTextStyles.contextTitle),
                const SizedBox(height: RadarSpacing.xs),
                Text(subtitle, style: RadarTextStyles.contextSecondary),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: RadarColors.primary,
            onChanged: onChanged,
          ),
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
      padding: const EdgeInsets.all(RadarSpacing.lg),
      decoration: BoxDecoration(
        color: hasDocument ? RadarColors.successSoft : RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
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
                    ? RadarColors.clinicalSuccess
                    : RadarColors.primary,
              ),
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RadarTextStyles.contextTitle.copyWith(
                        color: hasDocument
                            ? RadarColors.clinicalSuccess
                            : RadarColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: RadarSpacing.xs),
                    Text(
                      hasDocument
                          ? 'Stocké localement sur cet appareil${addedAt == null ? '' : ' · $addedAt'}'
                          : 'Photo ou import depuis la galerie',
                      style: RadarTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RadarSpacing.lg),
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
                const SizedBox(width: RadarSpacing.sm),
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
