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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Choisir un motif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sélectionnez le motif principal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: categories.keys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = categories.keys.elementAt(index);
                  return buildCategoryRow(context, category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryRow(BuildContext context, String category) {
    final selected = category == selectedCategory;
    final color = categoryColor(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
  Navigator.pop(context);
  onSelected(category);
},
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? color : const Color(0xFFE2E8F0),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcon(category),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? color : const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selected)
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}