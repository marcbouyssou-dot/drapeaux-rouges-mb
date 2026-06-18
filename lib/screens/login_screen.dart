import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import 'main_navigation_screen.dart';
import '../services/offline_session_service.dart';

const Color _loginBackgroundBase = Color(0xFF032052);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _loginBackgroundBase,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _loginBackgroundBase,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _loginBackgroundBase,
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
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final isShort = height < 760;

    return Stack(
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _LoginBackgroundPainter()),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, isShort ? 4 : 8, 18, 14),
            child: Column(
              children: [
                _MobileIdentityBlock(dense: isShort),
                SizedBox(height: isShort ? 6 : 10),
                const Expanded(child: _LoginFormCard(compact: true)),
                SizedBox(height: isShort ? AppSpacing.xs : AppSpacing.sm),
                const _LegalFooter(onDark: true, compact: true),
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
  const _MobileIdentityBlock({required this.dense});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _UrpsMark(height: dense ? 140 : 196),
        SizedBox(height: dense ? 0 : 4),
        _InstitutionBlock(compact: true, dense: dense),
        SizedBox(height: dense ? AppSpacing.xs : 10),
        const _IdentityDivider(compact: true),
        SizedBox(height: dense ? AppSpacing.xs : 10),
        _ProductBlock(compact: true, dense: dense),
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
          const _LegalFooter(onDark: true, compact: false),
        ],
      ),
    );
  }
}

class _InstitutionBlock extends StatelessWidget {
  const _InstitutionBlock({required this.compact, this.dense = false});

  final bool compact;
  final bool dense;

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
            fontSize: compact ? (dense ? 42 : 62) : 50,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? 1.2 : 2.2,
            shadows: [
              Shadow(
                color: AppColors.darkBackground.withValues(alpha: 0.32),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? (dense ? 2 : AppSpacing.xs) : AppSpacing.md),
        Text(
          'Masseurs Kinésithérapeutes',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnDark.withValues(alpha: 0.93),
            fontSize: compact ? (dense ? 18 : 24.5) : 26,
            height: 1.08,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: compact ? (dense ? 3 : AppSpacing.xs) : AppSpacing.sm),
        Text(
          'Nouvelle Aquitaine',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF5CA8FF),
            fontSize: compact ? (dense ? 16 : 20.5) : 19,
            fontWeight: FontWeight.w800,
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
      width: compact ? 160 : 190,
      height: compact ? 2 : 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: const Color(0xFF2F80FF),
      ),
    );
  }
}

class _ProductBlock extends StatelessWidget {
  const _ProductBlock({required this.compact, this.dense = false});

  final bool compact;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Outil d’aide au raisonnement clinique',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: compact ? (dense ? 16 : 21) : 25.5,
              height: 1.12,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: AppColors.darkBackground.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 5 : AppSpacing.sm),
        Text(
          'Dépistage • Orientation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFDDE7F3).withValues(alpha: 0.92),
            fontSize: compact ? (dense ? 14 : 16.5) : 15,
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
      child: Image.asset(
        'assets/icons/urps_pictogram_official_transparent.png',
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
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
        final isShort = MediaQuery.sizeOf(context).height < 760;
        final horizontalMargin = isShort ? 8.0 : 22.0;
        final horizontalPadding = isShort ? 18.0 : 24.0;
        final verticalPadding = isShort ? 10.0 : 14.0;
        final contentWidth =
            constraints.maxWidth - (horizontalMargin + horizontalPadding) * 2;

        return Align(
          alignment: Alignment.center,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              isShort ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.80),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBackground.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: SizedBox(
                width: contentWidth.clamp(240.0, 560.0),
                child: content,
              ),
            ),
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
    final emailPasswordGap = compact ? 12.0 : 20.0;
    final passwordForgotGap = compact ? 4.0 : 12.0;
    final forgotButtonGap = compact ? 10.0 : 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('Adresse e-mail'),
        const SizedBox(height: AppSpacing.xs),
        _PremiumTextField(
          hint: 'prenom.nom@mk.fr',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          compact: compact,
        ),
        SizedBox(height: emailPasswordGap),
        const _FieldLabel('Mot de passe'),
        const SizedBox(height: AppSpacing.xs),
        _PremiumTextField(
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
          compact: compact,
        ),
        SizedBox(height: passwordForgotGap),
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
              foregroundColor: const Color(0xFF0B74FF),
              padding: EdgeInsets.zero,
              minimumSize: Size(0, compact ? 26 : 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Mot de passe oublié ?',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        SizedBox(height: forgotButtonGap),
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
            colors: [Color(0xFFF00652), Color(0xFFD4075A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
          onPressed: () async {
            await OfflineSessionService().recordSuccessfulLogin();
            if (!context.mounted) return;
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

class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.onDark, required this.compact});

  final bool onDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? const Color(0xFFA9C4E8) : AppColors.textSecondary;
    final opacity = onDark ? 0.88 : 0.62;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Données sécurisées • RGPD • HDS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: opacity),
            fontSize: compact ? 12 : 11.5,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '© MB — Drapeaux Rouges',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withValues(alpha: opacity * 0.72),
            fontSize: compact ? 11.5 : 11,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        color: Color(0xFF0B74FF),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
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
      height: compact ? 56 : 58,
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
            color: const Color(0xFF0B74FF),
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
          fillColor: const Color(0xFFFBFCFF),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: compact ? AppSpacing.sm : AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: const BorderSide(color: Color(0xFFDDE6F3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: const BorderSide(color: Color(0xFFDDE6F3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
            borderSide: const BorderSide(color: Color(0xFF0B74FF), width: 1.4),
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

    final background = Paint()..color = _loginBackgroundBase;
    canvas.drawRect(rect, background);

    final linePaint = Paint()
      ..color = const Color(0xFF2F80FF).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final leftPath = Path()
      ..moveTo(-size.width * 0.18, size.height * 0.18)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.12,
        size.width * 0.20,
        size.height * 0.33,
        -size.width * 0.05,
        size.height * 0.42,
      );

    final rightPath = Path()
      ..moveTo(size.width * 1.18, size.height * 0.20)
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.16,
        size.width * 0.80,
        size.height * 0.36,
        size.width * 1.04,
        size.height * 0.46,
      );

    final lowerPath = Path()
      ..moveTo(size.width * 0.04, size.height * 0.48)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.38,
        size.width * 0.62,
        size.height * 0.50,
        size.width * 0.98,
        size.height * 0.35,
      );

    canvas.drawPath(leftPath, linePaint);
    canvas.drawPath(rightPath, linePaint);
    canvas.drawPath(
      lowerPath,
      linePaint..color = linePaint.color.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
