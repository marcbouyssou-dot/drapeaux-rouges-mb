import 'package:flutter/material.dart';

import '../../models/evaluation_model.dart';
import '../../models/medical_letter/medical_letter.dart';
import '../../models/medical_letter/medical_letter_history_item.dart';
import '../../models/medical_letter/medical_letter_template.dart';
import '../../models/patient_local.dart';
import '../../models/practitioner_profile.dart';
import '../../services/history_service.dart';
import '../../services/medical_letter_history_service.dart';
import '../../services/medical_letter_pdf_service.dart';
import '../../services/practitioner_profile_service.dart';
import '../../services/rgpd_local_service.dart';
import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_bottom_action_bar.dart';

class MedicalLetterScreen extends StatefulWidget {
  const MedicalLetterScreen({super.key, required this.template});

  final MedicalLetterTemplate template;

  @override
  State<MedicalLetterScreen> createState() => _MedicalLetterScreenState();
}

class _MedicalLetterScreenState extends State<MedicalLetterScreen> {
  final lieuController = TextEditingController();
  final subjectController = TextEditingController();

  PatientLocal? patient;
  PractitionerProfile practitioner = PractitionerProfile.empty();
  EvaluationModel? evaluation;
  DateTime date = DateTime.now();
  bool loading = true;
  bool exporting = false;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    lieuController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    final loadedPatient = await RgpdLocalService.getCurrentPatient();
    final loadedPractitioner = await PractitionerProfileService.getProfile();
    final loadedEvaluation = await latestEvaluationForPatient(loadedPatient);

    if (!mounted) return;

    setState(() {
      patient = loadedPatient;
      practitioner = loadedPractitioner;
      evaluation = loadedEvaluation;
      loading = false;
    });
  }

  Future<EvaluationModel?> latestEvaluationForPatient(
    PatientLocal? currentPatient,
  ) async {
    if (currentPatient == null) return null;

    final history = await HistoryService.loadHistory();
    final candidates = history
        .map((item) {
          try {
            return EvaluationModel.fromJson(item);
          } catch (_) {
            return null;
          }
        })
        .whereType<EvaluationModel>()
        .where((item) {
          return item.patientLocalId == currentPatient.localId ||
              item.patientAnonymousId == currentPatient.anonymousId;
        })
        .toList();

    candidates.sort((a, b) => b.date.compareTo(a.date));
    if (candidates.isEmpty) return null;

    return candidates.first;
  }

  MedicalLetter buildLetter() {
    return MedicalLetter(
      template: widget.template,
      patient: patient,
      practitioner: practitioner,
      date: date,
      lieu: lieuController.text.trim(),
      subject: subjectController.text.trim(),
      evaluation: evaluation,
    );
  }

  Future<void> exportPdf() async {
    setState(() {
      exporting = true;
    });

    try {
      final letter = buildLetter();
      await MedicalLetterPdfService.exportPdf(letter);
      await MedicalLetterHistoryService.saveLetter(
        MedicalLetterHistoryItem.fromLetter(letter),
      );
      showMessage('Courrier PDF généré et enregistré.');
    } finally {
      if (mounted) {
        setState(() {
          exporting = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        bottomNavigationBar: _LetterBottomActionBar(
          secondaryLabel: 'Retour',
          secondaryIcon: Icons.arrow_back_ios_new_rounded,
          onSecondaryPressed: () => Navigator.pop(context),
          primaryLabel: exporting ? 'Génération...' : 'Générer le PDF',
          primaryIcon: Icons.picture_as_pdf_outlined,
          onPrimaryPressed: () {
            if (!exporting) {
              exportPdf();
            }
          },
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RadarLayout.formWidth,
              ),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        compact ? RadarSpacing.lg : RadarSpacing.xl,
                        RadarSpacing.xl,
                        compact ? RadarSpacing.lg : RadarSpacing.xl,
                        112,
                      ),
                      children: [
                        _HeaderCard(template: widget.template),
                        const SizedBox(height: RadarSpacing.lg),
                        _ContextCard(
                          title: 'Patient utilisé',
                          icon: Icons.person_outline_rounded,
                          color: RadarColors.primary,
                          lines: [
                            _patientName,
                            'Naissance : ${_patientBirthDate.isEmpty ? 'Non renseignée' : _patientBirthDate}',
                            if (_treatingDoctorName.isNotEmpty)
                              'Médecin traitant : $_treatingDoctorName',
                          ],
                        ),
                        const SizedBox(height: RadarSpacing.lg),
                        _ContextCard(
                          title: 'Praticien utilisé',
                          icon: Icons.badge_outlined,
                          color: RadarColors.indigo,
                          lines: [
                            practitioner.professionLabel,
                            practitioner.fullName.isEmpty
                                ? 'Nom non renseigné'
                                : practitioner.fullName,
                            practitioner.hasSignature
                                ? 'Signature praticien disponible'
                                : 'Signature praticien absente',
                          ],
                        ),
                        const SizedBox(height: RadarSpacing.lg),
                        _ContextCard(
                          title: 'Évaluation liée',
                          icon: Icons.assignment_turned_in_outlined,
                          color: RadarColors.clinicalWarning,
                          lines: [
                            if (evaluation == null)
                              'Aucune évaluation liée'
                            else ...[
                              evaluation!.motif,
                              '${evaluation!.riskLevel} · Score ${evaluation!.score}',
                              evaluation!.clinicalReasoning == null
                                  ? 'Raisonnement clinique sauvegardé absent'
                                  : 'Raisonnement clinique sauvegardé disponible',
                            ],
                          ],
                        ),
                        const SizedBox(height: RadarSpacing.lg),
                        _FormCard(
                          lieuController: lieuController,
                          subjectController: subjectController,
                        ),
                        const SizedBox(height: RadarSpacing.lg),
                        _PreviewCard(letter: buildLetter()),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String get _patientName {
    final nom = patient?.nom.trim().toUpperCase() ?? '';
    final prenom = patient?.prenom.trim() ?? '';
    final value = '$nom $prenom'.trim();

    return value.isEmpty ? 'Patient non identifié' : value;
  }

  String get _patientBirthDate => patient?.dateNaissance.trim() ?? '';

  String get _treatingDoctorName => patient?.medecinNom.trim() ?? '';
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.template});

  final MedicalLetterTemplate template;

  @override
  Widget build(BuildContext context) {
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RadarColors.background,
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
            child: Icon(template.icon, color: template.color, size: 26),
          ),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Courriers médicaux',
                  style: TextStyle(
                    color: template.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RadarSpacing.xs),
                Text(
                  template.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: RadarSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RadarTextStyles.caption),
                const SizedBox(height: RadarSpacing.sm),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      line,
                      style: RadarTextStyles.secondary.copyWith(
                        color: RadarColors.textPrimary,
                      ),
                    ),
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

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.lieuController,
    required this.subjectController,
  });

  final TextEditingController lieuController;
  final TextEditingController subjectController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        children: [
          TextField(
            controller: lieuController,
            decoration: _inputDecoration(
              label: 'Lieu',
              hint: 'Ex : Bordeaux',
              icon: Icons.location_on_outlined,
            ),
          ),
          const SizedBox(height: RadarSpacing.lg),
          TextField(
            controller: subjectController,
            decoration: _inputDecoration(
              label: 'Objet du courrier',
              hint: 'Objet prérempli si laissé vide',
              icon: Icons.subject_rounded,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: RadarColors.background,
      contentPadding: const EdgeInsets.all(RadarSpacing.lg),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.card),
        borderSide: const BorderSide(color: RadarColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.card),
        borderSide: const BorderSide(color: RadarColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.card),
        borderSide: const BorderSide(color: RadarColors.primary, width: 1.5),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.letter});

  final MedicalLetter letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prévisualisation',
            style: TextStyle(
              color: RadarColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: RadarSpacing.md),
          Text(
            'Objet : ${letter.effectiveSubject}',
            style: const TextStyle(
              color: RadarColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: RadarSpacing.md),
          ...letter.bodyParagraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: const TextStyle(
                  color: RadarColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterBottomActionBar extends StatelessWidget {
  const _LetterBottomActionBar({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;
  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return RadarBottomActionBar(
      primaryLabel: primaryLabel,
      primaryIcon: primaryIcon,
      onPrimaryPressed: onPrimaryPressed,
      secondaryLabel: secondaryLabel,
      secondaryIcon: secondaryIcon,
      onSecondaryPressed: onSecondaryPressed,
    );
  }
}
