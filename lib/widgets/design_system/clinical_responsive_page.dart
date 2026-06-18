import 'package:flutter/material.dart';

class ClinicalResponsivePage extends StatelessWidget {
  const ClinicalResponsivePage({
    super.key,
    required this.child,
    this.mobileMaxWidth = 430,
    this.desktopMaxWidth = 920,
    this.backgroundColor = const Color(0xFFEFF4FA),
    this.useSafeArea = true,
  });

  final Widget child;
  final double mobileMaxWidth;
  final double desktopMaxWidth;
  final Color backgroundColor;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? desktopMaxWidth : mobileMaxWidth,
            ),
            child: child,
          ),
        );
      },
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(backgroundColor: backgroundColor, body: content);
  }
}
