import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool compact;

  const AppHeader({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 700;

        final height = compact
            ? (isMobile ? 76.0 : 96.0)
            : (isMobile ? 96.0 : 135.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Image.asset(
              'assets/images/app_header_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }
}