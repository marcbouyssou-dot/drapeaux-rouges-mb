import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/patient_local.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/urps_banner.dart';

class PatientConsentScreen extends StatefulWidget {
  const PatientConsentScreen({super.key});

  @override
  State<PatientConsentScreen> createState() => _PatientConsentScreenState();
}

class _PatientConsentScreenState extends State<PatientConsentScreen> {
  final searchController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissanceController = TextEditingController();

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  List<PatientLocal> patients = [];
  PatientLocal? currentPatient;

  String searchQuery = '';
  bool consentementCoche = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  @override
  void dispose() {
    searchController.dispose();
    nomController.dispose();
    prenomController.dispose();
    dateNaissanceController.dispose();
    signatureController.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    final loadedPatients =
        await RgpdLocalService.getPatientsSortedAlphabetically();
    final activePatient = await RgpdLocalService.getCurrentPatient();

    if (!mounted) return;

    setState(() {
      patients = loadedPatients;
      currentPatient = activePatient;
    });
  }

  List<PatientLocal> get filteredPatients {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return patients;

    return patients.where((patient) {
      final nom = patient.nom.toLowerCase();
      final prenom = patient.prenom.toLowerCase();
      final naissance = patient.dateNaissance.toLowerCase();
      final anonymousId = patient.anonymousId.toLowerCase();

      return nom.contains(query) ||
          prenom.contains(query) ||
          naissance.contains(query) ||
          anonymousId.contains(query);
    }).toList();
  }

  Future<void> savePatient() async {
    if (nomController.text.trim().isEmpty ||
        prenomController.text.trim().isEmpty ||
        dateNaissanceController.text.trim().isEmpty) {
      showMessage('Merci de renseigner nom, prénom et date de naissance.');
      return;
    }

    if (!consentementCoche) {
      showMessage('Merci de cocher le consentement patient.');
      return;
    }

    if (signatureController.isEmpty) {
      showMessage('Merci de faire signer le patient.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    final Uint8List? signatureBytes = await signatureController.toPngBytes();

    if (signatureBytes == null) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage('Erreur lors de la sauvegarde de la signature.');
      return;
    }

    final patient = PatientLocal(
      localId: RgpdLocalService.createLocalId(),
      anonymousId: RgpdLocalService.createAnonymousId(),
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      dateNaissance: dateNaissanceController.text.trim(),
      consentementValide: true,
      dateConsentement: DateTime.now(),
      signatureBase64: base64Encode(signatureBytes),
    );

    await RgpdLocalService.saveOrUpdatePatient(patient);

    if (!mounted) return;

    setState(() {
      isSaving = false;
      nomController.clear();
      prenomController.clear();
      dateNaissanceController.clear();
      consentementCoche = false;
      signatureController.clear();
    });

    await loadPatients();

    showMessage('Patient enregistré et sélectionné comme patient actif.');
  }

  Future<void> selectPatient(PatientLocal patient) async {
    await RgpdLocalService.setCurrentPatientId(patient.localId);
    await loadPatients();

    if (!mounted) return;

    showMessage('${patient.nom.toUpperCase()} ${patient.prenom} sélectionné.');
  }

  Future<void> deletePatient(PatientLocal patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce patient ?'),
          content: Text(
            'Cette action supprimera ${patient.nom.toUpperCase()} ${patient.prenom} de cet appareil. '
            'Les évaluations déjà enregistrées peuvent rester dans l’historique.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await RgpdLocalService.deletePatient(patient.localId);
    await loadPatients();

    if (!mounted) return;

    showMessage('Patient supprimé localement.');
  }

  Future<void> showAnonymousExportExample() async {
    final anonymousData = await RgpdLocalService.getAnonymousExportData();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Export pseudonymisé patient'),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent('  ').convert(anonymousData),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer tous les patients ?'),
          content: const Text(
            'Cette action supprimera tous les patients enregistrés localement sur cet appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
              ),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await RgpdLocalService.deleteAllLocalData();
    await loadPatients();

    if (!mounted) return;

    showMessage('Tous les patients locaux ont été supprimés.');
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isCurrentPatient(PatientLocal patient) {
    return currentPatient?.localId == patient.localId;
  }

  String patientName(PatientLocal patient) {
    return '${patient.nom.toUpperCase()} ${patient.prenom}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final visiblePatients = filteredPatients;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPatients,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
            children: [
              const UrpsBanner(isLarge: true),
              buildCurrentPatientCard(),
              const SizedBox(height: 18),
              buildSearchBar(),
              const SizedBox(height: 16),
              buildPatientsList(visiblePatients),
              const SizedBox(height: 26),
              buildSectionTitle(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Créer un patient',
              ),
              const SizedBox(height: 16),
              buildPatientForm(),
              const SizedBox(height: 24),
              buildRgpdActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomSaveBar(),
    );
  }

  Widget buildCurrentPatientCard() {
    final hasPatient = currentPatient != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPatient ? const Color(0xFFEFFAF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasPatient ? const Color(0xFFD5F3E1) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color:
                  hasPatient ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              hasPatient ? Icons.person_rounded : Icons.person_off_rounded,
              color:
                  hasPatient ? const Color(0xFF166534) : const Color(0xFFC2410C),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: hasPatient
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient actif',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patientName(currentPatient!),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Né(e) le ${currentPatient!.dateNaissance}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Aucun patient actif. Sélectionnez un patient ou créez un nouveau dossier.',
                    style: TextStyle(
                      color: Color(0xFFC2410C),
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Rechercher par nom, prénom, date ou identifiant...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget buildPatientsList(List<PatientLocal> visiblePatients) {
    if (patients.isEmpty) {
      return buildEmptyCard(
        icon: Icons.folder_open_rounded,
        title: 'Aucun patient enregistré',
        text: 'Les patients créés localement apparaîtront ici.',
      );
    }

    if (visiblePatients.isEmpty) {
      return buildEmptyCard(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        text: 'Essayez avec un autre nom, prénom ou identifiant.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${visiblePatients.length} patient(s)',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        ...visiblePatients.map(buildPatientTile),
      ],
    );
  }

  Widget buildPatientTile(PatientLocal patient) {
    final active = isCurrentPatient(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFFAF4) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: active ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: active ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => selectPatient(patient),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              active ? const Color(0xFF22C55E) : const Color(0xFFEAF2FF),
          child: Icon(
            active ? Icons.check_rounded : Icons.person_rounded,
            color: active ? Colors.white : const Color(0xFF2563EB),
          ),
        ),
        title: Text(
          patientName(patient),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          'Né(e) le ${patient.dateNaissance}',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'select') selectPatient(patient);
            if (value == 'delete') deletePatient(patient);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'select', child: Text('Sélectionner')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer localement')),
          ],
        ),
      ),
    );
  }

  Widget buildPatientForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          buildTextField(controller: nomController, label: 'Nom'),
          const SizedBox(height: 12),
          buildTextField(controller: prenomController, label: 'Prénom'),
          const SizedBox(height: 12),
          buildTextField(
            controller: dateNaissanceController,
            label: 'Date de naissance',
            hint: 'JJ/MM/AAAA',
            suffixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 18),
          buildConsentCard(),
          const SizedBox(height: 18),
          buildSignatureBox(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: TextButton.icon(
              onPressed: signatureController.clear,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Effacer la signature'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEAF2FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget buildConsentCard() {
    return Container(
      decoration: BoxDecoration(
        color: consentementCoche ? const Color(0xFFEFFAF4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: consentementCoche
              ? const Color(0xFF22C55E)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: CheckboxListTile(
        value: consentementCoche,
        onChanged: (value) {
          setState(() {
            consentementCoche = value ?? false;
          });
        },
        activeColor: const Color(0xFF22C55E),
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Le patient a été informé et consent à l’utilisation locale de ses données dans l’application.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget buildSignatureBox() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Signature(
              controller: signatureController,
              backgroundColor: Colors.white,
            ),
            const Center(
              child: IgnorePointer(
                child: Text(
                  'Signature patient',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRgpdActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: secondaryActionButton(
              icon: Icons.ios_share_rounded,
              label: 'Export anonyme',
              color: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFFEAF2FF),
              onPressed: showAnonymousExportExample,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: secondaryActionButton(
              icon: Icons.delete_forever_outlined,
              label: 'Tout supprimer',
              color: const Color(0xFFEF4444),
              backgroundColor: const Color(0xFFFFF1F2),
              onPressed: confirmDeleteAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget secondaryActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title, style: AppTextStyles.sectionTitle),
        ),
      ],
    );
  }

  Widget buildEmptyCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomSaveBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: FilledButton.icon(
          onPressed: isSaving ? null : savePatient,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            isSaving ? 'Enregistrement...' : 'Enregistrer et activer',
          ),
        ),
      ),
    );
  }
}