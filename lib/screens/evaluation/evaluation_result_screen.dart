import 'package:flutter/material.dart';

import '../../services/bdk_session_service.dart';
import '../../services/decision_engine_service.dart';
import '../bdk/bdk_type_screen.dart';

class EvaluationResultScreen extends StatelessWidget {
  const EvaluationResultScreen({
    super.key,
    required this.score,
    required this.checkedCount,
    required this.riskLevel,
    required this.riskColor,
    required this.selectedCategory,
    required this.categories,
    required this.patientDisplayName,
    required this.aiSummary,
    required this.checkedFlags,
    required this.decisionMessage,
    required this.onReset,
    required this.onSave,
    required this.onExportPdf,
  });

  final int score;
  final int checkedCount;
  final String riskLevel;
  final Color riskColor;
  final String selectedCategory;
  final Map<String, List<Map<String, dynamic>>> categories;
  final String patientDisplayName;
  final String aiSummary;
  final List<Map<String, dynamic>> checkedFlags;
  final String decisionMessage;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final decisionTitle = DecisionEngineService.decisionTitle(
      score: score,
      selectedCategory: selectedCategory,
      categories: categories,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Résultat'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  riskColor,
                  riskColor.withValues(alpha: 0.84),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.monitor_heart_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 18),
                Text(
                  riskLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$checkedCount drapeau(x) — score $score',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  patientDisplayName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ResultCard(
            icon: Icons.route_rounded,
            title: decisionTitle,
            text: decisionMessage,
            color: riskColor,
          ),
          const SizedBox(height: 16),
          _ResultCard(
            icon: Icons.psychology_alt_outlined,
            title: 'Synthèse clinique',
            text: aiSummary,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 16),
          const _SafetyNote(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            border: const Border(
              top: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onReset();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Sauver'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onExportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    BDKSessionService.loadFromEvaluation(
                      selectedCategory: selectedCategory,
                      score: score,
                      risk: riskLevel,
                      checkedFlagsData: checkedFlags,
                      aiSummary: aiSummary,
                      decisionMessage: decisionMessage,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BDKTypeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Préparer un BDK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Aide au repérage clinique uniquement. Cette application ne remplace pas une évaluation médicale professionnelle.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
      ),
    );
  }
}