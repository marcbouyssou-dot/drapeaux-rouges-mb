import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../models/patient_local.dart';
import '../services/rgpd_local_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_header.dart';

class PatientConsentScreen extends StatefulWidget {
  const PatientConsentScreen({super.key});

  @override
  State<PatientConsentScreen> createState() => _PatientConsentScreenState();
}

class _PatientConsentScreenState extends State<PatientConsentScreen> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final dateNaissanceController = TextEditingController();

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool consentementCoche = false;
  bool isSaving = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    dateNaissanceController.dispose();
    signatureController.dispose();
    super.dispose();
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
      showMessage('Erreur lors de la sauvegarde de la signature.');
      setState(() {
        isSaving = false;
      });
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

    await RgpdLocalService.savePatient(patient);

    setState(() {
      isSaving = false;
      nomController.clear();
      prenomController.clear();
      dateNaissanceController.clear();
      consentementCoche = false;
      signatureController.clear();
    });

    showMessage('Patient enregistré localement. Export anonyme disponible.');
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showAnonymousExportExample() async {
    final anonymousData = await RgpdLocalService.getAnonymousExportData();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Export anonymisé'),
          content: SingleChildScrollView(
            child: Text(
              const JsonEncoder.withIndent('  ').convert(anonymousData),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
      builder: (_) {
        return AlertDialog(
          title: const Text('Supprimer les données locales ?'),
          content: const Text(
            'Cette action supprimera tous les patients enregistrés localement sur cet appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await RgpdLocalService.deleteAllLocalData();
      showMessage('Toutes les données locales ont été supprimées.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 150),
          children: [
            const AppHeader(),
            const SizedBox(height: 18),

            buildSectionTitle(
              icon: Icons.person_rounded,
              title: 'Identité patient',
            ),
            const SizedBox(height: 16),

            buildTextField(
              controller: nomController,
              label: 'Nom',
            ),
            const SizedBox(height: 12),

            buildTextField(
              controller: prenomController,
              label: 'Prénom',
            ),
            const SizedBox(height: 12),

            buildTextField(
              controller: dateNaissanceController,
              label: 'Date de naissance',
              hint: 'JJ/MM/AAAA',
              suffixIcon: Icons.calendar_today_outlined,
            ),

            const SizedBox(height: 28),

            buildSectionTitle(
              icon: Icons.verified_user_rounded,
              title: 'Consentement RGPD',
            ),
            const SizedBox(height: 12),

            Text(
              'Les données nominatives sont conservées uniquement localement sur cet appareil. '
              'Tout export de données de santé est anonymisé par défaut et ne contient ni nom, '
              'ni prénom, ni date de naissance complète, ni signature.',
              style: AppTextStyles.pageSubtitle.copyWith(
                height: 1.55,
              ),
            ),

            const SizedBox(height: 14),
            buildConsentCard(),

            const SizedBox(height: 26),

            buildSectionTitle(
              icon: Icons.draw_rounded,
              title: 'Signature patient',
            ),
            const SizedBox(height: 12),

            buildSignatureBox(),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                signatureController.clear();
              },
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Effacer la signature'),
            ),

            const SizedBox(height: 20),
            buildSmallActions(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomSaveBar(),
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
          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle,
          ),
        ),
      ],
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
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(
            color: Color(0xFF2563EB),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget buildConsentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: consentementCoche
              ? const Color(0xFF2563EB)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: consentementCoche,
        onChanged: (value) {
          setState(() {
            consentementCoche = value ?? false;
          });
        },
        activeColor: const Color(0xFF2563EB),
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Le patient a été informé et consent à l’utilisation locale de ses données dans l’application.',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget buildSignatureBox() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
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
                  'Signez ici',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 14,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: showAnonymousExportExample,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Export anonyme'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: confirmDeleteAll,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Données locales'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBottomSaveBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: isSaving ? null : savePatient,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            isSaving ? 'Enregistrement...' : 'Enregistrer localement',
          ),
        ),
      ),
    );
  }
}