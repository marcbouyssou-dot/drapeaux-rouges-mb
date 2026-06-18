import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../services/offline_sync_service.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialOffline = false});

  final bool initialOffline;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  late bool isOffline;
  StreamSubscription<bool>? connectivitySubscription;

  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    ConnectivityService.instance.startListening();
    isOffline = widget.initialOffline || !ConnectivityService.instance.isOnline;
    connectivitySubscription = ConnectivityService.instance.onStatusChanged
        .listen((online) {
          if (!mounted) return;

          setState(() {
            isOffline = !online;
          });

          if (online) {
            OfflineSyncService().syncPendingEvaluations();
          }
        });

    if (!isOffline) {
      OfflineSyncService().syncPendingEvaluations();
    }
  }

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
    connectivitySubscription?.cancel();
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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            children: _pages,
          ),
          if (isOffline)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 16,
              child: const _OfflineBadge(),
            ),
        ],
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
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: -0.25,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                  );
                }),
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

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Mode hors ligne',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text(
                'Hors ligne',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
