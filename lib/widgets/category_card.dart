import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item, bool value) onChanged;

  const CategoryCard({
    super.key,
    required this.category,
    required this.items,
    required this.onChanged,
  });

  IconData get categoryIcon {
    final name = category.toLowerCase();

    if (name.contains('cardio')) return Icons.favorite_rounded;
    if (name.contains('neuro')) return Icons.psychology_rounded;
    if (name.contains('respiratoire')) return Icons.air_rounded;
    if (name.contains('infectieux')) return Icons.coronavirus_rounded;
    if (name.contains('trauma')) return Icons.local_hospital_rounded;
    if (name.contains('digestif')) return Icons.restaurant_rounded;
    if (name.contains('urinaire')) return Icons.water_drop_rounded;
    if (name.contains('pediatrie')) return Icons.child_care_rounded;
    if (name.contains('mentale')) return Icons.psychology_alt_rounded;

    return Icons.medical_services_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final checkedInCategory =
        items.where((item) => item['checked'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  categoryIcon,
                  color: const Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (checkedInCategory > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$checkedInCategory',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
            final bool isCritical = item['severity'] == 'Critique';
            final bool checked = item['checked'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: checked ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: checked
                      ? (isCritical ? Colors.red : Colors.orange)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: CheckboxListTile(
                value: checked,
                activeColor: isCritical ? Colors.red : Colors.orange,
                onChanged: (value) => onChanged(item, value ?? false),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  isCritical ? 'Niveau critique' : 'Niveau modere',
                ),
                secondary: Icon(
                  isCritical
                      ? Icons.warning_rounded
                      : Icons.info_outline_rounded,
                  color: isCritical ? Colors.red : Colors.orange,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}