import 'dart:math';
import 'package:flutter/material.dart';

import '../services/patient_session_service.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final naissanceController = TextEditingController();

  bool consentementRgpd = false;
  String? codePatientActif;
  List<Map<String, dynamic>> patients = [];

  @override
  void initState() {
    super.initState();
    chargerPatients();
  }

  Future<void> chargerPatients() async {
    final loadedPatients = await PatientSessionService.getPatients();
    final activePatient = await PatientSessionService.getPatientData();

    setState(() {
      patients = loadedPatients;
      codePatientActif = activePatient['code'];
    });
  }

  String genererCodePatient() {
    const chars = 'ABCDEF0123456789';
    final random = Random.secure();

    final code = List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    return 'MK-$code';
  }

  Future<void> creerDossierPatient() async {
    if (!consentementRgpd) {
      afficherMessage('Le consentement RGPD doit être validé.');
      return;
    }

    if (nomController.text.trim().isEmpty ||
        prenomController.text.trim().isEmpty) {
      afficherMessage('Merci de renseigner au minimum nom et prénom.');
      return;
    }

    final generatedCode = genererCodePatient();

    await PatientSessionService.savePatient(
      code: generatedCode,
      nom: nomController.text.trim(),
      prenom: prenomController.text.trim(),
      naissance: naissanceController.text.trim(),
      consentement: consentementRgpd,
    );

    nomController.clear();
    prenomController.clear();
    naissanceController.clear();

    setState(() {
      consentementRgpd = false;
      codePatientActif = generatedCode;
    });

    await chargerPatients();

    afficherMessage('Patient créé et activé localement.');
  }

  Future<void> activerPatient(String code) async {
    await PatientSessionService.setCurrentPatient(code);
    await chargerPatients();
    afficherMessage('Patient actif modifié.');
  }

  Future<void> supprimerPatient(String code) async {
    await PatientSessionService.deletePatient(code);
    await chargerPatients();
    afficherMessage('Patient supprimé localement.');
  }

  void afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    naissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: chargerPatients,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          const _HeaderPatient(),
          const SizedBox(height: 20),
          const _InfoCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Consentement RGPD',
            text:
                'Les données nominatives restent uniquement en local sur cet appareil. '
                'Elles ne doivent pas être transmises dans les exports. '
                'Les exports utilisent uniquement le code patient pseudonymisé.',
          ),
          const SizedBox(height: 16),
          _buildPatientForm(),
          const SizedBox(height: 24),
          _buildActivePatientCard(),
          const SizedBox(height: 24),
          _buildPatientsList(),
          const SizedBox(height: 20),
          const _InfoCard(
            icon: Icons.warning_amber_rounded,
            title: 'Prudence clinique',
            text:
                'Cette application constitue une aide au raisonnement clinique. '
                'Elle ne pose pas de diagnostic médical et ne remplace pas un avis médical.',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SwitchListTile(
              value: consentementRgpd,
              onChanged: (value) {
                setState(() {
                  consentementRgpd = value;
                });
              },
              title: const Text('Consentement patient recueilli'),
              subtitle: const Text('Obligatoire avant création du dossier local.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: naissanceController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                hintText: 'JJ/MM/AAAA',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: creerDossierPatient,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Créer et activer le patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePatientCard() {
    if (codePatientActif == null) {
      return const _InfoCard(
        icon: Icons.person_off_outlined,
        title: 'Aucun patient actif',
        text:
            'Créez ou sélectionnez un patient avant de réaliser une évaluation.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.green.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient actif',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            codePatientActif!,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    if (patients.isEmpty) {
      return const _InfoCard(
        icon: Icons.folder_open_outlined,
        title: 'Aucun patient enregistré',
        text: 'Les patients créés localement apparaîtront ici.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patients locaux',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...patients.map((patient) {
          final code = patient['code'] ?? '';
          final isActive = code == codePatientActif;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: isActive
                    ? Colors.green.withOpacity(0.45)
                    : Colors.transparent,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isActive ? Colors.green : const Color(0xFFB91C1C),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                '${patient['nom']} ${patient['prenom']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${patient['naissance']} • $code',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'activate') {
                    activerPatient(code);
                  }

                  if (value == 'delete') {
                    supprimerPatient(code);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'activate',
                    child: Text('Activer'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer localement'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _HeaderPatient extends StatelessWidget {
  const _HeaderPatient();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
  colors: [
    Color(0xFF0A84FF),
    Color(0xFF0066FF),
  ],
),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded, color: Colors.white, size: 42),
          SizedBox(height: 16),
          Text(
            'Accès Direct MK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Drapeaux Rouges',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFB91C1C)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}