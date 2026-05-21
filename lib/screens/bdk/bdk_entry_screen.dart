import 'package:flutter/material.dart';

import 'bdk_type_screen.dart';

class BDKEntryScreen extends StatelessWidget {
  const BDKEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
          child: Column(
            children: [
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BDKTypeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 400,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF7),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF16A34A)
                                  .withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF22C55E),
                                    Color(0xFF15803D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF16A34A)
                                        .withValues(alpha: 0.26),
                                    blurRadius: 30,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.assignment_rounded,
                                color: Colors.white,
                                size: 66,
                              ),
                            ),
                            const Text(
                              'BDK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const Text(
                              'Réaliser un bilan diagnostique kinésithérapique',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 17,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: const Text(
                                'Appuyer pour commencer',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _infoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            color: Color(0xFF15803D),
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'BDK structurés avec synthèse clinique et export PDF.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}