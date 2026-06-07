import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final orientation = MediaQuery.orientationOf(context);
          final isLandscape = orientation == Orientation.landscape;
          final isWide =
              constraints.maxWidth >= 760 ||
              (isLandscape && constraints.maxWidth >= 640);

          if (isWide) return const _DesktopLoginLayout();

          return const _MobileLoginLayout();
        },
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _LoginBackgroundPainter())),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Column(
              children: [
                _MobileIdentityBlock(),
                SizedBox(height: AppSpacing.sm),
                Expanded(child: _LoginFormCard(compact: true)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _LoginBackgroundPainter()),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140, maxHeight: 720),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    const Expanded(flex: 6, child: _DesktopIdentityPanel()),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.elevated,
                        ),
                        child: const _LoginFormCard(compact: false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileIdentityBlock extends StatelessWidget {
  const _MobileIdentityBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _UrpsMark(height: 137),
        SizedBox(height: 2),
        _InstitutionBlock(compact: true),
        SizedBox(height: AppSpacing.sm),
        _IdentityDivider(compact: true),
        SizedBox(height: AppSpacing.sm),
        _ProductBlock(compact: true),
      ],
    );
  }
}

class _DesktopIdentityPanel extends StatelessWidget {
  const _DesktopIdentityPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, -30),
            child: const Column(
              children: [
                _UrpsMark(height: 250),
                SizedBox(height: AppSpacing.md),
                _InstitutionBlock(compact: false),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _IdentityDivider(compact: false),
          const SizedBox(height: AppSpacing.xl),
          const _ProductBlock(compact: false),
          const Spacer(),
        ],
      ),
    );
  }
}

class _InstitutionBlock extends StatelessWidget {
  const _InstitutionBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'URPS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: compact ? 26 : 49,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? 1.4 : 2.2,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
        Text(
          'Masseurs-Kinésithérapeutes',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnDark.withValues(alpha: 0.92),
            fontSize: compact ? 15.75 : 26.25,
            height: 1.08,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
        Text(
          'Nouvelle-Aquitaine',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: compact ? 13.5 : 19,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: AppColors.darkBackground.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdentityDivider extends StatelessWidget {
  const _IdentityDivider({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 86 : 140,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.textOnDark.withValues(alpha: 0),
            AppColors.textOnDark.withValues(alpha: 0.45),
            AppColors.textOnDark.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _ProductBlock extends StatelessWidget {
  const _ProductBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Outil d’aide au raisonnement',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: compact ? 16 : 25,
            height: 1.12,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 3 : AppSpacing.sm),
        Text(
          'Dépistage • Orientation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFDDE7F3),
            fontSize: compact ? 11 : 15,
            height: compact ? 1.18 : 1.32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UrpsMark extends StatelessWidget {
  const _UrpsMark({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final width = height * 1.08;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/icons/urps_pictogram_official_transparent.png',
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
          Opacity(
            opacity: 0.22,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFEAF6FF),
                    Color(0x00FFFFFF),
                    Color(0xFFFFEDF4),
                  ],
                  stops: [0.02, 0.22, 0.58, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Image.asset(
                'assets/icons/urps_pictogram_official_transparent.png',
                height: height,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                isAntiAlias: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = _LoginForm(compact: compact);

    if (!compact) return content;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.elevated,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(width: constraints.maxWidth - 32, child: content),
          ),
        );
      },
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('ADRESSE E-MAIL'),
        const SizedBox(height: AppSpacing.xs),
        _PremiumTextField(
          hint: 'prenom.nom@mk.fr',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          compact: compact,
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
        const _FieldLabel('MOT DE PASSE'),
        const SizedBox(height: AppSpacing.xs),
        _PremiumTextField(
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
          compact: compact,
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Réinitialisation du mot de passe non disponible pour le moment.',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size(0, compact ? 28 : 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Mot de passe oublié ?',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
        _LoginButton(compact: compact),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 52 : 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.raspberry, AppColors.raspberryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.raspberry.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.textOnDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: const Text(
            'Se connecter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.hint,
    required this.prefixIcon,
    required this.compact,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final String hint;
  final IconData prefixIcon;
  final bool compact;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 50 : 58,
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: compact ? 14 : 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.primary,
            size: compact ? 22 : 24,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  color: AppColors.textMuted,
                  size: compact ? 21 : 23,
                ),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textMuted,
            fontSize: compact ? 14 : 15,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: compact ? AppSpacing.sm : AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF020817),
          AppColors.darkBackground,
          AppColors.primaryDark,
          Color(0xFF073C8C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRect(rect, background);

    final softBlue = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.20);
    final softWhite = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.07);
    final softRed = Paint()
      ..color = AppColors.raspberry.withValues(alpha: 0.10);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.18),
      size.shortestSide * 0.30,
      softWhite,
    );
    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.12),
      size.shortestSide * 0.22,
      softBlue,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.82),
      size.shortestSide * 0.34,
      softRed,
    );

    final dotPaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.055);
    final dotMaxX = size.width * 0.36;
    for (double x = 16; x < dotMaxX; x += 22) {
      for (double y = 70; y < size.height * 0.94; y += 22) {
        if (((x + y) ~/ 22).isEven) {
          canvas.drawCircle(Offset(x, y), 1.05, dotPaint);
        }
      }
    }

    final linePaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final redLinePaint = Paint()
      ..color = AppColors.raspberry.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.58)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.45,
        size.width * 0.54,
        size.height * 0.64,
        size.width * 0.96,
        size.height * 0.42,
      );

    canvas.drawPath(path, linePaint);

    final secondPath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.30)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.22,
        size.width * 0.60,
        size.height * 0.34,
        size.width * 0.92,
        size.height * 0.20,
      );

    canvas.drawPath(secondPath, linePaint);

    final redPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.54)
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.46,
        size.width * 0.78,
        size.height * 0.62,
        size.width * 0.98,
        size.height * 0.48,
      );

    canvas.drawPath(redPath, redLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
