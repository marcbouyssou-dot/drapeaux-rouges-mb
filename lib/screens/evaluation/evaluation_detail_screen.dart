import 'package:flutter/material.dart';

import '../../services/history_service.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_text_styles.dart';

class EvaluationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> evaluation;

  const EvaluationDetailScreen({
    super.key,
    required this.evaluation,
  });

  String get evaluationId {
    return evaluation['evaluationId']?.toString() ?? '';
  }

  String get patientName {
    return evaluation['patientDisplayName']?.toString() ??
        evaluation['patientCode']?.toString() ??
        'Patient non renseigné';
  }

  String get motif {
    return evaluation['motif']?.toString() ?? 'Motif non renseigné';
  }

  String get riskLevel {
    return evaluation['riskLevel']?.toString() ??
        evaluation['risk']?.toString() ??
        'Risque inconnu';
  }

  int get score {
    final value = evaluation['score'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int get checkedCount {
    final value = evaluation['checkedCount'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get decisionTitle {
    return evaluation['decisionTitle']?.toString() ?? 'Décision non renseignée';
  }

  String get decisionMessage {
    return evaluation['decisionMessage']?.toString() ??
        'Aucun message de décision enregistré.';
  }

  String get aiSummary {
    return evaluation['aiSummary']?.toString() ??
        'Synthèse non enregistrée pour ce bilan.';
  }

  List<Map<String, dynamic>> get checkedFlags {
    final raw = evaluation['checkedFlags'];

    if (raw is! List) return [];

    return raw.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Color get riskColor {
    final lower = riskLevel.toLowerCase();

    if (lower.contains('critique')) return const Color(0xFFDC2626);
    if (lower.contains('élevé') || lower.contains('eleve')) {
      return const Color(0xFFF97316);
    }
    if (lower.contains('modéré') || lower.contains('modere')) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFF22C55E);
  }

  String formatDate(dynamic value) {
    final raw = value?.toString() ?? '';

    if (raw.isEmpty) return 'Date inconnue';

    final date = DateTime.tryParse(raw);

    if (date == null) return raw;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  Map<String, List<Map<String, dynamic>>> buildPdfCategories() {
    final result = <String, List<Map<String, dynamic>>>{};

    for (final flag in checkedFlags) {
      final category = flag['category']?.toString() ?? motif;

      result.putIfAbsent(category, () => []);

      result[category]!.add({
        'title': flag['title']?.toString() ?? 'Drapeau rouge',
        'severity': flag['severity']?.toString() ?? 'Non renseigné',
        'checked': true,
        'tags': flag['tags'] ?? [],
      });
    }

    return result;
  }

  Future<void> exportPdf(BuildContext context) async {
    await PdfService.exportPdf(
      categories: buildPdfCategories(),
      score: score,
      checkedCount: checkedCount,
      riskLevel: riskLevel,
      patientCode: patientName,
      motif: motif,
      decisionTitle: decisionTitle,
      decisionMessage: decisionMessage,
      aiSummary: aiSummary,
    );
  }

  Future<void> confirmDelete(BuildContext context) async {
    if (evaluationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de supprimer ce bilan : identifiant manquant.'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Supprimer ce bilan ?'),
          content: const Text(
            'Cette action supprimera uniquement ce bilan de l’historique local. '
            'Le patient ne sera pas supprimé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
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

    await HistoryService.deleteEvaluation(evaluationId);

    if (!context.mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            buildHeader(context),
            const SizedBox(height: 18),
            buildRiskCard(),
            const SizedBox(height: 18),
            buildDecisionCard(),
            const SizedBox(height: 18),
            buildFlagsSection(),
            const SizedBox(height: 18),
            buildActionButtons(context),
            const SizedBox(height: 18),
            buildLegalNote(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Détail du bilan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            patientName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDate(evaluation['date']),
            style: TextStyle(
              color: Colors.white.withOpacity(0.76),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRiskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            riskColor,
            riskColor.withOpacity(0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riskLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  motif,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          buildMiniStat('Score', '$score'),
          const SizedBox(width: 8),
          buildMiniStat('DR', '$checkedCount'),
        ],
      ),
    );
  }

  Widget buildMiniStat(String label, String value) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDecisionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: riskColor.withOpacity(0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.route_rounded,
              color: riskColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  decisionTitle,
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  decisionMessage,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlagsSection() {
    if (checkedFlags.isEmpty) {
      return buildEmptyFlags();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drapeaux rouges cochés',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 12),
        ...checkedFlags.map(buildFlagTile),
      ],
    );
  }

  Widget buildEmptyFlags() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF22C55E),
            size: 30,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Aucun drapeau rouge coché dans ce bilan.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlagTile(Map<String, dynamic> flag) {
    final title = flag['title']?.toString() ?? 'Drapeau rouge';
    final severity = flag['severity']?.toString() ?? 'Non renseigné';
    final category = flag['category']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flag_rounded,
            color: riskColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null) ...[
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  severity,
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => exportPdf(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Exporter PDF'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLegalNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aide au repérage clinique uniquement. Cette application ne remplace pas une évaluation médicale professionnelle.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}