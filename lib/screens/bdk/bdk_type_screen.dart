import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../features/radar/presentation/theme/radar_colors.dart';
import '../../features/radar/presentation/theme/radar_layout.dart';
import '../../features/radar/presentation/theme/radar_radius.dart';
import '../../features/radar/presentation/theme/radar_shadows.dart';
import '../../features/radar/presentation/theme/radar_spacing.dart';
import '../../features/radar/presentation/theme/radar_text_styles.dart';
import '../../features/radar/presentation/theme/radar_theme.dart';
import '../../features/radar/presentation/widgets/radar_page_header.dart';
import '../../services/bdk_draft_service.dart';
import '../../services/bdk_session_service.dart';
import '../../services/rgpd_local_service.dart';
import 'bdk_detail_screen.dart';

class BDKTypeScreen extends StatelessWidget {
  const BDKTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: RadarLayout.compactWorkflowWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xl,
                  RadarSpacing.xxl,
                ),
                children: [
                  RadarPageHeader(
                    title: 'Bilan',
                    subtitle:
                        'Créer ou compléter un bilan diagnostique kinésithérapique.',
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: RadarSpacing.xxl),
                  ...bdkTypeOptions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
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
      ),
    );
  }

  Future<void> _openBdk(BuildContext context, BDKTypeOption item) async {
    if (!item.requiresCustomLabel) {
      await _pushBdkDetail(context, item.title);
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

    await _pushBdkDetail(context, title, customContext: trimmedLabel);
  }

  Future<void> _pushBdkDetail(
    BuildContext context,
    String title, {
    String? customContext,
  }) async {
    await _alignBdkOwnerWithCurrentPatient();
    if (!BDKSessionService.hasDraftContent) {
      await BdkDraftService.restoreActiveDraft(
        patientLocalId: BDKSessionService.patientLocalId,
        patientAnonymousId: BDKSessionService.patientAnonymousId,
        title: title,
      );
    }
    if (!context.mounted) return;

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            BDKDetailScreen(title: title, customContext: customContext),
      ),
    );
  }

  Future<void> _alignBdkOwnerWithCurrentPatient() async {
    final currentPatient = await RgpdLocalService.getCurrentPatient();
    final isAligned = BDKSessionService.isAssociatedWithPatient(
      localId: currentPatient?.localId,
      anonymousId: currentPatient?.anonymousId,
    );

    if (!isAligned) {
      BDKSessionService.clear();
    }

    BDKSessionService.associatePatient(
      localId: currentPatient?.localId,
      anonymousId: currentPatient?.anonymousId,
      displayName: RgpdLocalService.patientDisplayName(currentPatient),
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
    color: RadarColors.primary,
  ),
  BDKTypeOption(
    id: 'cervicalgie',
    title: 'BDK Cervicalgie',
    icon: Icons.accessibility_new_outlined,
    color: RadarColors.indigo,
  ),
  BDKTypeOption(
    id: 'cheville',
    title: 'BDK Cheville',
    icon: Icons.directions_walk_outlined,
    color: RadarColors.clinicalSuccess,
  ),
  BDKTypeOption(
    id: 'respiratoire',
    title: 'BDK Respiratoire',
    icon: Icons.air_outlined,
    color: RadarColors.indigo,
  ),
  BDKTypeOption(
    id: 'personne_agee',
    title: 'BDK Personne âgée',
    icon: Icons.elderly_outlined,
    color: RadarColors.clinicalWarning,
  ),
  BDKTypeOption(
    id: 'autres',
    title: 'BDK Autres',
    icon: Icons.more_horiz_rounded,
    color: RadarColors.slate,
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
      color: RadarColors.surface.withValues(alpha: 0),
      borderRadius: BorderRadius.circular(RadarRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        child: Container(
          padding: const EdgeInsets.all(RadarSpacing.lg),
          decoration: BoxDecoration(
            color: RadarColors.surface,
            borderRadius: BorderRadius.circular(RadarRadius.card),
            boxShadow: RadarShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadarRadius.small),
                  border: Border.all(color: item.color.withValues(alpha: 0.18)),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(width: RadarSpacing.md),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RadarTextStyles.question.copyWith(color: item.color),
                ),
              ),
              const SizedBox(width: RadarSpacing.md),
              const Icon(
                Icons.chevron_right_rounded,
                color: RadarColors.textMuted,
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
          fillColor: RadarColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
            borderSide: const BorderSide(color: RadarColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
            borderSide: const BorderSide(color: RadarColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
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
            foregroundColor: RadarColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadarRadius.small),
            ),
          ),
          child: const Text('Continuer'),
        ),
      ],
    );
  }
}
