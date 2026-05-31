import 'package:flutter/material.dart';

class DecisionCard extends StatelessWidget {
  final String title;
  final String message;
  final Color color;

  const DecisionCard({
    super.key,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: color,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      message,
                      style: const TextStyle(
                        height: 1.55,
                        color:
                            Color(0xFF334155),
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color:
                    const Color(0xFFE2E8F0),
              ),
            ),
            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Aide au repérage clinique uniquement. Cette application ne remplace pas une évaluation médicale professionnelle.',
                    style: TextStyle(
                      color:
                          Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}