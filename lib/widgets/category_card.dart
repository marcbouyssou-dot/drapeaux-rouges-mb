import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>, bool) onChanged;

  const CategoryCard({
    super.key,
    required this.category,
    required this.items,
    required this.onChanged,
  });

  Color severityColor(String severity) {
    switch (severity) {
      case 'Critique':
        return const Color(0xFFB91C1C);
      case 'Élevé':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF2563EB);
    }
  }

  List<Map<String, dynamic>> itemsBySeverity(String severity) {
    return items
        .where((item) => item['severity'].toString() == severity)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final criticalItems = itemsBySeverity('Critique');
    final highItems = itemsBySeverity('Élevé');
    final otherItems = items
        .where(
          (item) =>
              item['severity'].toString() != 'Critique' &&
              item['severity'].toString() != 'Élevé',
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${items.length} éléments cliniques',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _SeveritySection(
            title: 'Critiques',
            items: criticalItems,
            color: severityColor('Critique'),
            initiallyExpanded: true,
            onChanged: onChanged,
          ),
          _SeveritySection(
            title: 'Élevés',
            items: highItems,
            color: severityColor('Élevé'),
            initiallyExpanded: false,
            onChanged: onChanged,
          ),
          _SeveritySection(
            title: 'Autres signes',
            items: otherItems,
            color: severityColor('Modéré'),
            initiallyExpanded: false,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SeveritySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color color;
  final bool initiallyExpanded;
  final Function(Map<String, dynamic>, bool) onChanged;

  const _SeveritySection({
    required this.title,
    required this.items,
    required this.color,
    required this.initiallyExpanded,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.22),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        iconColor: color,
        collapsedIconColor: color,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${items.length}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        children: items.map((item) {
          final checked = item['checked'] == true;
          final severity = item['severity'].toString();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: checked ? color.withOpacity(0.10) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: checked ? color : const Color(0xFFE2E8F0),
                width: checked ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: checked,
                  activeColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    onChanged(item, value ?? false);
                  },
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}