import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>, bool) onChanged;

  const CategoryCard({
    super.key,
    required this.category,
    required this.items,
    required this.onChanged,
  });

  Color severityColor(String severity) {
    switch (severity) {
      case 'Critique':
        return const Color(0xFFB91C1C);

      case 'Élevé':
        return const Color(0xFFEA580C);

      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),

                  borderRadius: BorderRadius.circular(99),
                ),

                child: Text(
                  '${items.length} items',

                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...items.map((item) {
            final checked = item['checked'] == true;

            final severity =
                item['severity'].toString();

            return AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              margin:
                  const EdgeInsets.only(bottom: 10),

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: checked
                    ? severityColor(severity)
                        .withOpacity(0.08)
                    : const Color(0xFFF8FAFC),

                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color: checked
                      ? severityColor(severity)
                      : const Color(0xFFE2E8F0),

                  width: checked ? 1.6 : 1,
                ),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,

                children: [
                  Transform.scale(
                    scale: 1.08,

                    child: Checkbox(
                      value: checked,

                      activeColor:
                          severityColor(severity),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5),
                      ),

                      onChanged: (value) {
                        onChanged(
                          item,
                          value ?? false,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          item['title'],

                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,

                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: severityColor(
                              severity,
                            ).withOpacity(0.12),

                            borderRadius:
                                BorderRadius.circular(
                              99,
                            ),
                          ),

                          child: Text(
                            severity,

                            style: TextStyle(
                              color: severityColor(
                                severity,
                              ),

                              fontWeight:
                                  FontWeight.w800,

                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}