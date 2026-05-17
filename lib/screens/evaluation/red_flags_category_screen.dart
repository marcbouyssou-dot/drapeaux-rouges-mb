import 'package:flutter/material.dart';

class RedFlagsCategoryScreen extends StatefulWidget {
  final String title;
  final List<String> items;
  final Set<String> initiallySelected;

  const RedFlagsCategoryScreen({
    super.key,
    required this.title,
    required this.items,
    required this.initiallySelected,
  });

  @override
  State<RedFlagsCategoryScreen> createState() => _RedFlagsCategoryScreenState();
}

class _RedFlagsCategoryScreenState extends State<RedFlagsCategoryScreen> {
  late Set<String> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = Set<String>.from(widget.initiallySelected);
  }

  void toggleItem(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
    });
  }

  void saveAndClose() {
    Navigator.pop(context, selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectedItems.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(selectedCount),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return buildItemCard(widget.items[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildHeader(int selectedCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEAF2FF),
              foregroundColor: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  selectedCount == 0
                      ? 'Aucun drapeau rouge coché'
                      : '$selectedCount drapeau(x) rouge(s) coché(s)',
                  style: TextStyle(
                    color: selectedCount == 0
                        ? const Color(0xFF64748B)
                        : const Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          buildCounterBadge(selectedCount),
        ],
      ),
    );
  }

  Widget buildCounterBadge(int selectedCount) {
    final active = selectedCount > 0;

    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$selectedCount',
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF64748B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'coché',
            style: TextStyle(
              color: active ? Colors.white70 : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemCard(String item) {
    final isSelected = selectedItems.contains(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => toggleItem(item),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                width: isSelected ? 1.7 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: saveAndClose,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Valider'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}