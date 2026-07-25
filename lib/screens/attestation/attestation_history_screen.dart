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
import '../../models/attestation/attestation_history_item.dart';
import '../../models/attestation/attestation_template.dart';
import '../../services/attestation_history_service.dart';
import 'attestation_history_detail_screen.dart';

class AttestationHistoryScreen extends StatefulWidget {
  const AttestationHistoryScreen({super.key});

  @override
  State<AttestationHistoryScreen> createState() =>
      _AttestationHistoryScreenState();
}

class _AttestationHistoryScreenState extends State<AttestationHistoryScreen> {
  List<AttestationHistoryItem> attestations = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final loaded = await AttestationHistoryService.getAttestations();

    if (!mounted) return;

    setState(() {
      attestations = loaded;
      loading = false;
    });
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: RadarTheme.lightTheme,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadHistory,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: RadarLayout.workflowWidth,
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
                      title: 'Historique des attestations',
                      subtitle:
                          'Retrouver les attestations générées et régénérer un PDF.',
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: RadarSpacing.xxl),
                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(RadarSpacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (!loading && attestations.isEmpty) buildEmptyState(),
                    if (!loading && attestations.isNotEmpty)
                      ...attestations.map(buildAttestationCard),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        boxShadow: RadarShadows.card,
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_edu_outlined,
            color: RadarColors.primary,
            size: 44,
          ),
          SizedBox(height: RadarSpacing.md),
          Text(
            'Aucune attestation générée pour le moment.',
            textAlign: TextAlign.center,
            style: RadarTextStyles.body,
          ),
        ],
      ),
    );
  }

  Widget buildAttestationCard(AttestationHistoryItem item) {
    final template = attestationTemplateByTypeId(item.typeId);

    return Padding(
      padding: const EdgeInsets.only(bottom: RadarSpacing.lg),
      child: Material(
        color: RadarColors.surface.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(RadarRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(RadarRadius.card),
          onTap: () async {
            final deleted = await Navigator.push<bool>(
              context,
              CupertinoPageRoute(
                builder: (_) =>
                    AttestationHistoryDetailScreen(attestation: item),
              ),
            );

            if (deleted == true) {
              await loadHistory();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(RadarSpacing.lg),
            decoration: BoxDecoration(
              color: RadarColors.surface,
              borderRadius: BorderRadius.circular(RadarRadius.card),
              boxShadow: RadarShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: template.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(RadarRadius.card),
                      ),
                      child: Icon(
                        template.icon,
                        color: template.color,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: RadarSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: RadarTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: RadarSpacing.xs),
                          Text(
                            item.displayPatient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RadarTextStyles.secondary,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: RadarColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: RadarSpacing.md),
                Wrap(
                  spacing: RadarSpacing.sm,
                  runSpacing: RadarSpacing.sm,
                  children: [
                    buildSmallBadge(
                      icon: Icons.event_outlined,
                      text: formatDate(item.generatedAt),
                    ),
                    buildSmallBadge(
                      icon: item.hasSignature
                          ? Icons.draw_outlined
                          : Icons.edit_off_outlined,
                      text: item.signatureStatus,
                    ),
                    buildStatusBadge(template),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSmallBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadarSpacing.md,
        vertical: RadarSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: RadarColors.background,
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RadarColors.textSecondary, size: 13),
          const SizedBox(width: RadarSpacing.xs),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: RadarTextStyles.caption.copyWith(
                color: RadarColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBadge(AttestationTemplate template) {
    final color = template.isActive
        ? RadarColors.clinicalSuccess
        : RadarColors.clinicalWarning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadarSpacing.md,
        vertical: RadarSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadarRadius.pill),
      ),
      child: Text(
        template.statusLabel,
        style: RadarTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}
