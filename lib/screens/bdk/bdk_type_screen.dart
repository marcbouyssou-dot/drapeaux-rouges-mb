import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.filledTonal(
                    tooltip: 'Retour',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...bdkTypeOptions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _BDKTypeCard(
                      item: item,
                      onTap: () => _openBdk(context, item),
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

  Future<void> _openBdk(BuildContext context, BDKTypeOption item) async {
    if (!item.requiresCustomLabel) {
      _pushBdkDetail(context, item.title);
      return;
    }

    final customLabel = await showDialog<String>(
      context: context,
      builder: (_) => _BDKCustomLabelDialog(item: item),
    );

    if (!context.mounted || customLabel == null) return;

    final trimmedLabel = customLabel.trim();
    final title = trimmedLabel.isEmpty
        ? item.title
        : '${item.title} — $trimmedLabel';

    _pushBdkDetail(context, title, customContext: trimmedLabel);
  }

  void _pushBdkDetail(
    BuildContext context,
    String title, {
    String? customContext,
  }) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            BDKDetailScreen(title: title, customContext: customContext),
      ),
    );
  }
}

class BDKTypeOption {
  const BDKTypeOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.requiresCustomLabel = false,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final bool requiresCustomLabel;
}

const bdkTypeOptions = [
  BDKTypeOption(
    id: 'lombalgie',
    title: 'BDK Lombalgie',
    icon: Icons.back_hand_outlined,
    color: Color(0xFF2563EB),
  ),
  BDKTypeOption(
    id: 'cervicalgie',
    title: 'BDK Cervicalgie',
    icon: Icons.accessibility_new_outlined,
    color: Color(0xFFDB2777),
  ),
  BDKTypeOption(
    id: 'cheville',
    title: 'BDK Cheville',
    icon: Icons.directions_walk_outlined,
    color: Color(0xFF16A34A),
  ),
  BDKTypeOption(
    id: 'respiratoire',
    title: 'BDK Respiratoire',
    icon: Icons.air_outlined,
    color: Color(0xFF7C3AED),
  ),
  BDKTypeOption(
    id: 'personne_agee',
    title: 'BDK Personne âgée',
    icon: Icons.elderly_outlined,
    color: Color(0xFFF97316),
  ),
  BDKTypeOption(
    id: 'autres',
    title: 'BDK Autres',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF0F766E),
    requiresCustomLabel: true,
  ),
];

class _BDKTypeCard extends StatelessWidget {
  const _BDKTypeCard({required this.item, required this.onTap});

  final BDKTypeOption item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: item.color.withValues(alpha: 0.18)),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BDKCustomLabelDialog extends StatefulWidget {
  const _BDKCustomLabelDialog({required this.item});

  final BDKTypeOption item;

  @override
  State<_BDKCustomLabelDialog> createState() => _BDKCustomLabelDialogState();
}

class _BDKCustomLabelDialogState extends State<_BDKCustomLabelDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Précision du BDK'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Ex : épaule, genou, neurologie, post-opératoire...',
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: widget.item.color, width: 1.5),
          ),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Continuer sans précision'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          style: FilledButton.styleFrom(
            backgroundColor: widget.item.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: const Text('Continuer'),
        ),
      ],
    );
  }
}
