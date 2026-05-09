import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onHistory;
  final VoidCallback onPdf;
  final VoidCallback onCsv;
  final VoidCallback onReset;

  const ActionButtons({
    super.key,
    required this.onSave,
    required this.onHistory,
    required this.onPdf,
    required this.onCsv,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        actionButton(Icons.save, 'Enregistrer evaluation', onSave),
        const SizedBox(height: 12),
        actionButton(Icons.history, 'Voir historique', onHistory),
        const SizedBox(height: 12),
        actionButton(Icons.picture_as_pdf, 'Exporter PDF', onPdf),
        const SizedBox(height: 12),
        actionButton(Icons.table_chart, 'Exporter CSV', onCsv),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Reinitialiser session'),
          ),
        ),
      ],
    );
  }

  Widget actionButton(IconData icon, String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: action,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(label),
        ),
      ),
    );
  }
}