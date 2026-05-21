import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/patient_local.dart';
import '../services/rgpd_local_service.dart';

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
  bool showIdentifiedPatientForm = false;

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
      return patient.nom.toLowerCase().contains(query) ||
          patient.prenom.toLowerCase().contains(query) ||
          patient.dateNaissance.toLowerCase().contains(query) ||
          patient.anonymousId.toLowerCase().contains(query);
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

  Future<void> activateAnonymousMode() async {
    await RgpdLocalService.clearCurrentPatient();
    await loadPatients();

    if (!mounted) return;

    setState(() {
      showIdentifiedPatientForm = false;
    });

    showMessage('Mode patient anonyme activé.');
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

    if (!mounted) return;

    setState(() {
      isSaving = false;
      showIdentifiedPatientForm = false;
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

    setState(() {
      showIdentifiedPatientForm = false;
    });

    showMessage('${patient.nom.toUpperCase()} ${patient.prenom} activé.');
  }

  Future<void> deletePatient(PatientLocal patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce patient ?'),
          content: Text(
            'Cette action supprimera ${patient.nom.toUpperCase()} ${patient.prenom} de cet appareil.',
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
              child: const Text('Supprimer'),
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
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPatients,
          child: ListView(
            physics: isSigning
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 150),
            children: [
              buildEntryCards(),
              if (currentPatient != null) ...[
                const SizedBox(height: 18),
                buildCurrentPatientBanner(),
              ],
              if (currentPatient == null && !showIdentifiedPatientForm) ...[
                const SizedBox(height: 18),
                buildAnonymousBanner(),
              ],
              if (showIdentifiedPatientForm) ...[
                const SizedBox(height: 22),
                buildSearchBar(),
                const SizedBox(height: 18),
                buildPatientForm(foundPatient),
                const SizedBox(height: 26),
                buildPatientsList(visiblePatients),
                const SizedBox(height: 20),
                buildDeleteAllButton(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          showIdentifiedPatientForm ? buildBottomSaveBar(foundPatient) : null,
    );
  }

  Widget buildEntryCards() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth > 900;

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildBigEntryCard(
                title: 'PATIENT IDENTIFIÉ',
                subtitle:
                    'Créer ou activer un patient avec consentement et signature.',
                buttonText: 'Renseigner le patient',
                icon: Icons.person_add_alt_1_rounded,
                backgroundColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFBFDBFE),
                mainColor: const Color(0xFF2563EB),
                onTap: () {
                  setState(() {
                    showIdentifiedPatientForm = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: buildBigEntryCard(
                title: 'PATIENT ANONYME',
                subtitle:
                    'Évaluation rapide sans données personnelles nominatives.',
                buttonText: 'Utiliser le mode anonyme',
                icon: Icons.no_accounts_rounded,
                backgroundColor: const Color(0xFFF8FAFC),
                borderColor: const Color(0xFFE2E8F0),
                mainColor: const Color(0xFF64748B),
                onTap: activateAnonymousMode,
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          buildBigEntryCard(
            title: 'PATIENT IDENTIFIÉ',
            subtitle:
                'Créer ou activer un patient avec consentement et signature.',
            buttonText: 'Renseigner le patient',
            icon: Icons.person_add_alt_1_rounded,
            backgroundColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFBFDBFE),
            mainColor: const Color(0xFF2563EB),
            onTap: () {
              setState(() {
                showIdentifiedPatientForm = true;
              });
            },
          ),
          const SizedBox(height: 18),
          buildBigEntryCard(
            title: 'PATIENT ANONYME',
            subtitle:
                'Évaluation rapide sans données personnelles nominatives.',
            buttonText: 'Utiliser le mode anonyme',
            icon: Icons.no_accounts_rounded,
            backgroundColor: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            mainColor: const Color(0xFF64748B),
            onTap: activateAnonymousMode,
          ),
        ],
      );
    },
  );
}

  Widget buildBigEntryCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color mainColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          height: 360,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      mainColor.withValues(alpha: 0.78),
                      mainColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: mainColor,
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

  Widget buildAnonymousBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aucun patient identifié actif. Les évaluations seront associées à “Patient non renseigné”.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentPatientBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 22,
          ),
          const SizedBox(width: 10),
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
        hintText: 'Rechercher un patient...',
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
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPatientForm(PatientLocal? foundPatient) {
    final patientExists = foundPatient != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          buildTextField(
            controller: nomController,
            label: 'Nom',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: prenomController,
            label: 'Prénom',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: dateNaissanceController,
            label: 'Date de naissance',
            hint: 'JJ/MM/AAAA',
            suffixIcon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.datetime,
          ),
          if (patientExists) ...[
            const SizedBox(height: 14),
            buildExistingPatientNotice(foundPatient),
          ],
          if (!patientExists) ...[
            const SizedBox(height: 16),
            buildConsentCard(),
            const SizedBox(height: 16),
            buildSignatureBox(),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: signatureController.clear,
              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
              label: const Text('Effacer la signature'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFFEAF2FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildExistingPatientNotice(PatientLocal patient) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_search_rounded, color: Color(0xFF16A34A)),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
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
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFFAF4) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: active ? const Color(0xFF86EFAC) : Colors.transparent,
          width: active ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => selectPatient(patient),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 21,
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
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
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
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: isSaving ? null : saveOrActivatePatient,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              isSaving ? 'Enregistrement...' : buttonText,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}