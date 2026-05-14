import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'patient/patient_screen.dart';
import 'settings_screen.dart';
import 'prescription_screen.dart';

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
    PatientScreen(),
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
      duration: const Duration(milliseconds: 240),
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
      icon: Icon(
        icon,
        size: 23,
      ),

      selectedIcon: Icon(
        selectedIcon,
        size: 24,
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
            const NeverScrollableScrollPhysics(),

        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        children: screens,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),

        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(30),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.08,
                ),

                blurRadius: 24,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(30),

            child: NavigationBar(
              selectedIndex: currentIndex,

              height: 68,

              elevation: 0,

              labelBehavior:
                  NavigationDestinationLabelBehavior
                      .onlyShowSelected,

              animationDuration:
                  const Duration(
                milliseconds: 300,
              ),

              onDestinationSelected: goToPage,

              destinations: [
                buildDestination(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Patient',
                ),

                buildDestination(
                  icon: Icons.health_and_safety_outlined,
                  selectedIcon:
                      Icons.health_and_safety,
                  label: 'Évaluation',
                ),

                buildDestination(
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: 'Historique',
                ),

                buildDestination(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                buildDestination(
                  icon: Icons.description_outlined,
                  selectedIcon: Icons.description,
                  label: 'Prescription',
              ),
                buildDestination(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Réglages',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}