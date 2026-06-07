import 'package:flutter/material.dart';

import '../../services/risk_score_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class RedFlagsCategoryScreen extends StatefulWidget {
  final String title;
  final List<String> items;
  final Set<String> initiallySelected;
  final Map<String, int> itemScores;
  final int baseScore;
  final int baseCheckedCount;

  const RedFlagsCategoryScreen({
    super.key,
    required this.title,
    required this.items,
    required this.initiallySelected,
    this.itemScores = const {},
    this.baseScore = 0,
    this.baseCheckedCount = 0,
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

  int get categoryScore {
    return selectedItems.fold<int>(
      0,
      (total, item) => total + (widget.itemScores[item] ?? 0),
    );
  }

  int get currentScore => widget.baseScore + categoryScore;

  int get currentCheckedCount => widget.baseCheckedCount + selectedItems.length;

  String get currentRiskLevel =>
      RiskScoreService.riskLevelFromScore(currentScore);

  Color get displayRiskColor {
    final risk = currentRiskLevel.toLowerCase();
    if (risk.contains('critique') || risk.contains('élevé')) {
      return AppColors.danger;
    }
    if (risk.contains('modéré')) return AppColors.warning;
    return AppColors.success;
  }

  double get progress {
    if (widget.items.isEmpty) return 0;
    return (selectedItems.length / widget.items.length).clamp(0, 1);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                buildHeader(selectedCount),
                buildLiveScoreCard(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return buildItemCard(widget.items[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildHeader(int selectedCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, AppSpacing.sm, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceAlt,
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _HeaderChip(
                          label: selectedCount == 0
                              ? 'Aucun coché'
                              : '$selectedCount coché(s)',
                          color: selectedCount == 0
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                        _HeaderChip(
                          label: currentRiskLevel,
                          color: displayRiskColor,
                        ),
                        _HeaderChip(
                          label:
                              '${selectedItems.length}/${widget.items.length}',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              buildCounterBadge(selectedCount),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(displayRiskColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLiveScoreCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, AppSpacing.xs, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [displayRiskColor, displayRiskColor.withValues(alpha: 0.88)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: displayRiskColor.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.textOnDark.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.textOnDark.withValues(alpha: 0.18),
              ),
            ),
            child: Center(
              child: Text(
                '$currentScore',
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentRiskLevel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$currentCheckedCount drapeau(x) au total • $selectedItemsScoreLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textOnDark.withValues(alpha: 0.82),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.monitor_heart_rounded,
            color: AppColors.textOnDark,
            size: 22,
          ),
        ],
      ),
    );
  }

  String get selectedItemsScoreLabel {
    if (categoryScore == 0) return 'score catégorie 0';
    return 'score catégorie +$categoryScore';
  }

  Widget buildCounterBadge(int selectedCount) {
    final active = selectedCount > 0;

    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.borderStrong,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$selectedCount',
            style: TextStyle(
              color: active ? AppColors.textOnDark : AppColors.textSecondary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'coché',
            style: TextStyle(
              color: active
                  ? AppColors.textOnDark.withValues(alpha: 0.72)
                  : AppColors.textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemCard(String item, int index) {
    final isSelected = selectedItems.contains(item);
    final points = widget.itemScores[item] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => toggleItem(item),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.danger.withValues(alpha: 0.07)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected ? AppColors.danger : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? AppShadows.soft : const [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.danger : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.danger
                          : AppColors.borderStrong,
                      width: isSelected ? 1.5 : 1.2,
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.circle_outlined,
                    color: isSelected
                        ? AppColors.textOnDark
                        : AppColors.textMuted,
                    size: isSelected ? 22 : 15,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: AppTypography.overline.copyWith(
                          color: isSelected
                              ? AppColors.danger
                              : AppColors.textMuted,
                          fontSize: 9.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item,
                        style: AppTypography.body.copyWith(
                          height: 1.26,
                          fontSize: 14.5,
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (points > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _SeverityPill(points: points, active: isSelected),
                ],
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: AppShadows.card,
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
            const SizedBox(width: AppSpacing.sm),
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

class _SeverityPill extends StatelessWidget {
  const _SeverityPill({required this.points, required this.active});

  final int points;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? _scoreColor(points)
            : _scoreColor(points).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: _scoreColor(points).withValues(alpha: active ? 1 : 0.42),
        ),
      ),
      child: Text(
        '+$points',
        style: TextStyle(
          color: active ? AppColors.textOnDark : _scoreColor(points),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Color _scoreColor(int points) {
    if (points >= 3) return AppColors.danger;
    if (points == 2) return AppColors.warningDark;
    return AppColors.warning;
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
