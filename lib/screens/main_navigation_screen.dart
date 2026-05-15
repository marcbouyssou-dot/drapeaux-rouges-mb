import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'patient_consent_screen.dart';
import 'prescription_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int currentIndex = 1;

  final PageController _pageController =
      PageController(initialPage: 1);

  final screens = const [
    PatientConsentScreen(),
    HomeScreen(),
    HistoryScreen(),
    DashboardScreen(),
    PrescriptionScreen(),
    SettingsScreen(),
  ];

  void goToPage(int index) {
    setState(() {
      currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration:
          const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  NavigationDestination buildDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon, size: 23),

      selectedIcon: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),

        padding:
            const EdgeInsets.all(10),

        decoration: BoxDecoration(
          color:
              const Color(0xFF2563EB)
                  .withOpacity(0.10),

          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),

        child: Icon(
          selectedIcon,
          size: 24,
        ),
      ),

      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: PageView(
        controller: _pageController,

        physics:
            const BouncingScrollPhysics(),

        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        children: screens,
      ),

      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          16,
        ),

        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              34,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.10),

                blurRadius: 30,

                offset: const Offset(
                  0,
                  12,
                ),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              34,
            ),

            child: NavigationBarTheme(
              data:
                  NavigationBarThemeData(
                backgroundColor:
                    Colors.white
                        .withOpacity(
                  0.96,
                ),

                indicatorColor:
                    Colors.transparent,

                labelTextStyle:
                    WidgetStateProperty
                        .resolveWith(
                  (states) {
                    final selected =
                        states.contains(
                      WidgetState
                          .selected,
                    );

                    return TextStyle(
                      fontSize: 11,

                      fontWeight:
                          selected
                              ? FontWeight
                                  .w900
                              : FontWeight
                                  .w600,

                      letterSpacing:
                          -0.2,

                      color: selected
                          ? const Color(
                              0xFF2563EB,
                            )
                          : const Color(
                              0xFF64748B,
                            ),
                    );
                  },
                ),

                iconTheme:
                    WidgetStateProperty
                        .resolveWith(
                  (states) {
                    final selected =
                        states.contains(
                      WidgetState
                          .selected,
                    );

                    return IconThemeData(
                      color: selected
                          ? const Color(
                              0xFF2563EB,
                            )
                          : const Color(
                              0xFF64748B,
                            ),
                    );
                  },
                ),
              ),

              child: NavigationBar(
                selectedIndex:
                    currentIndex,

                height: 76,

                elevation: 0,

                backgroundColor:
                    Colors.transparent,

                labelBehavior:
                    NavigationDestinationLabelBehavior
                        .alwaysShow,

                animationDuration:
                    const Duration(
                  milliseconds: 300,
                ),

                onDestinationSelected:
                    goToPage,

                destinations: [
                  buildDestination(
                    icon:
                        Icons.person_outline,
                    selectedIcon:
                        Icons.person,
                    label:
                        'Patient',
                  ),

                  buildDestination(
                    icon: Icons
                        .monitor_heart_outlined,
                    selectedIcon: Icons
                        .monitor_heart,
                    label:
                        'Évaluation',
                  ),

                  buildDestination(
                    icon:
                        Icons.history_outlined,
                    selectedIcon:
                        Icons.history,
                    label:
                        'Historique',
                  ),

                  buildDestination(
                    icon: Icons
                        .dashboard_outlined,
                    selectedIcon:
                        Icons.dashboard,
                    label:
                        'Dashboard',
                  ),

                  buildDestination(
                    icon: Icons
                        .description_outlined,
                    selectedIcon:
                        Icons.description,
                    label:
                        'Prescription',
                  ),

                  buildDestination(
                    icon: Icons
                        .settings_outlined,
                    selectedIcon:
                        Icons.settings,
                    label:
                        'Réglages',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}