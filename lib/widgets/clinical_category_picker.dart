import 'package:flutter/material.dart';

class ClinicalCategoryPicker extends StatelessWidget {
  const ClinicalCategoryPicker({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    required this.checkedCount,
  });

  final Map<String, List<Map<String, dynamic>>> categories;
  final String selectedCategory;
  final Function(String) onSelected;
  final int Function(String) checkedCount;

  IconData categoryIcon(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('lomb')) return Icons.accessibility_new_rounded;
    if (lower.contains('entorse')) return Icons.directions_walk_rounded;
    if (lower.contains('resp')) return Icons.air_rounded;
    if (lower.contains('ortho')) return Icons.medical_services_outlined;
    if (lower.contains('cerv')) return Icons.psychology_alt_outlined;
    if (lower.contains('card')) return Icons.favorite_border_rounded;
    if (lower.contains('tvp') || lower.contains('vasc')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('post')) return Icons.healing_rounded;

    return Icons.monitor_heart_outlined;
  }

  Color categoryColor(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('lomb')) return const Color(0xFF2563EB);
    if (lower.contains('entorse')) return const Color(0xFF22C55E);
    if (lower.contains('resp')) return const Color(0xFF7C3AED);
    if (lower.contains('ortho')) return const Color(0xFFF97316);
    if (lower.contains('cerv')) return const Color(0xFFE11D48);
    if (lower.contains('card')) return const Color(0xFFF59E0B);
    if (lower.contains('tvp') || lower.contains('vasc')) {
      return const Color(0xFF0EA5E9);
    }
    if (lower.contains('post')) return const Color(0xFF06B6D4);

    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = categories.keys.toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: 5,
              width: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: categoryNames.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = categoryNames[index];

                  return buildCategoryRow(
                    context: context,
                    category: category,
                    index: index + 1,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Sélectionnez le motif principal pour afficher les drapeaux rouges associés.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryRow({
    required BuildContext context,
    required String category,
    required int index,
  }) {
    final selected = category == selectedCategory;
    final color = categoryColor(category);
    final count = checkedCount(category);

    return Material(
      color: selected ? color.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onSelected(category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : const Color(0xFFE2E8F0),
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(categoryIcon(category), color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Container(
                height: 25,
                width: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? color : const Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? color : const Color(0xFF94A3B8),
                size: selected ? 30 : 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
