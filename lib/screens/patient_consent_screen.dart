import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/patient_local.dart';
import '../services/rgpd_local_service.dart';
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
  bool isSigning = false;

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

  PatientLocal? get existingPatient {
    final nom = nomController.text.trim().toLowerCase();
    final prenom = prenomController.text.trim().toLowerCase();
    final naissance = dateNaissanceController.text.trim().toLowerCase();

    if (nom.isEmpty || prenom.isEmpty || naissance.isEmpty) return null;

    for (final patient in patients) {
      if (patient.nom.trim().toLowerCase() == nom &&
          patient.prenom.trim().toLowerCase() == prenom &&
          patient.dateNaissance.trim().toLowerCase() == naissance) {
        return patient;
      }
    }

    return null;
  }

  Future<void> saveOrActivatePatient() async {
    if (nomController.text.trim().isEmpty ||
        prenomController.text.trim().isEmpty ||
        dateNaissanceController.text.trim().isEmpty) {
      showMessage('Merci de renseigner nom, prénom et date de naissance.');
      return;
    }

    final foundPatient = existingPatient;

    if (foundPatient != null) {
      await selectPatient(foundPatient);
      clearForm();
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
    await RgpdLocalService.setCurrentPatientId(patient.localId);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    clearForm();
    await loadPatients();

    showMessage('Patient enregistré et activé.');
  }

  void clearForm() {
    nomController.clear();
    prenomController.clear();
    dateNaissanceController.clear();
    consentementCoche = false;
    signatureController.clear();

    if (mounted) setState(() {});
  }

  Future<void> selectPatient(PatientLocal patient) async {
    await RgpdLocalService.setCurrentPatientId(patient.localId);
    await loadPatients();

    if (!mounted) return;

    showMessage('${patient.nom.toUpperCase()} ${patient.prenom} activé.');
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
    final foundPatient = existingPatient;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPatients,
          child: ListView(
            physics: isSigning
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
            children: [
              const UrpsBanner(isLarge: true),
              const SizedBox(height: 14),
              buildSearchBar(),
              if (currentPatient != null) ...[
                const SizedBox(height: 12),
                buildCurrentPatientBanner(),
              ],
              const SizedBox(height: 14),
              buildPatientForm(foundPatient),
              const SizedBox(height: 22),
              buildPatientsList(visiblePatients),
              const SizedBox(height: 20),
              buildDeleteAllButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomSaveBar(foundPatient),
    );
  }

  Widget buildCurrentPatientBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Patient actif : ${patientName(currentPatient!)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w900,
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
        hintText: 'Rechercher par nom, prénom, date de naissance...',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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

  Widget buildPatientForm(PatientLocal? foundPatient) {
    final patientExists = foundPatient != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          buildTextField(
            controller: nomController,
            label: 'Nom',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: prenomController,
            label: 'Prénom',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: dateNaissanceController,
            label: 'Date de naissance',
            hint: 'JJ/MM/AAAA',
            suffixIcon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.datetime,
          ),
          if (patientExists) ...[
            const SizedBox(height: 12),
            buildExistingPatientNotice(foundPatient),
          ],
          if (!patientExists) ...[
            const SizedBox(height: 14),
            buildConsentCard(),
            const SizedBox(height: 14),
            buildSignatureBox(),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: signatureController.clear,
              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
              label: const Text('Effacer la signature'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEAF2FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildExistingPatientNotice(PatientLocal patient) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_search_rounded,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Patient déjà enregistré : ${patientName(patient)}. Le bouton va l’activer.',
              style: const TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w800,
                height: 1.3,
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
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: (_) => setState(() {}),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
        borderRadius: BorderRadius.circular(18),
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
          'Le patient consent à l’utilisation locale de ses données dans l’application.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget buildSignatureBox() {
    return Listener(
      onPointerDown: (_) {
        setState(() {
          isSigning = true;
        });
      },
      onPointerUp: (_) {
        setState(() {
          isSigning = false;
        });
      },
      onPointerCancel: (_) {
        setState(() {
          isSigning = false;
        });
      },
      child: Container(
        height: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  Widget buildPatientsList(List<PatientLocal> visiblePatients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patients enregistrés',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 10),
        if (patients.isEmpty)
          buildEmptyCard(
            icon: Icons.folder_open_rounded,
            title: 'Aucun patient enregistré',
            text: 'Les patients créés localement apparaîtront ici.',
          )
        else if (visiblePatients.isEmpty)
          buildEmptyCard(
            icon: Icons.search_off_rounded,
            title: 'Aucun résultat',
            text: 'Essayez avec un autre nom, prénom ou une autre date.',
          )
        else
          ...visiblePatients.map(buildPatientTile),
      ],
    );
  }

  Widget buildPatientTile(PatientLocal patient) {
    final active = isCurrentPatient(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFFAF4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: active ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => selectPatient(patient),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: CircleAvatar(
          radius: 20,
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
            PopupMenuItem(value: 'select', child: Text('Activer')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer localement')),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteAllButton() {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: confirmDeleteAll,
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Supprimer tous les patients locaux'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget buildEmptyCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 32),
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
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomSaveBar(PatientLocal? foundPatient) {
    final buttonText =
        foundPatient == null ? 'Enregistrer / Activer' : 'Activer ce patient';

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
          onPressed: isSaving ? null : saveOrActivatePatient,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            isSaving ? 'Enregistrement...' : buttonText,
          ),
        ),
      ),
    );
  }
}