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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final bool isCritical = item['severity'] == 'Critique';

            return CheckboxListTile(
              value: item['checked'],
              activeColor: isCritical ? Colors.red : Colors.orange,
              onChanged: (value) {
                onChanged(item, value ?? false);
              },
              title: Text(item['title']),
              subtitle: Text(
                isCritical ? 'Niveau critique' : 'Niveau modere',
              ),
            );
          }),
        ],
      ),
    );
  }
}