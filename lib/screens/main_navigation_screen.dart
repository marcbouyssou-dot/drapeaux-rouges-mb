import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void goToPage(int index) {
    setState(() {
      currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
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
      icon: Icon(icon, size: 22),
      selectedIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(selectedIcon, size: 23),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFF),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.white.withValues(alpha: 0.97),
                indicatorColor: Colors.transparent,
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) {
                    final selected = states.contains(WidgetState.selected);
                    return TextStyle(
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      letterSpacing: -0.25,
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    );
                  },
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) {
                    final selected = states.contains(WidgetState.selected);
                    return IconThemeData(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                height: 76,
                elevation: 0,
                backgroundColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                animationDuration: const Duration(milliseconds: 300),
                onDestinationSelected: goToPage,
                destinations: [
                  buildDestination(
                    icon: Icons.health_and_safety_outlined,
                    selectedIcon: Icons.health_and_safety_rounded,
                    label: 'Évaluation',
                  ),
                  buildDestination(
                    icon: Icons.history_outlined,
                    selectedIcon: Icons.history_rounded,
                    label: 'Historique',
                  ),
                  buildDestination(
                    icon: Icons.tune_outlined,
                    selectedIcon: Icons.tune_rounded,
                    label: 'Réglages',
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