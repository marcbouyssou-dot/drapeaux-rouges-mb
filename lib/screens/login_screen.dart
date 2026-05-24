import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _background = Color(0xFFEAF2FB);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallHeight = size.height < 740;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  _Header(isSmallHeight: isSmallHeight),
                  _LoginForm(isSmallHeight: isSmallHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isSmallHeight});

  final bool isSmallHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isSmallHeight ? 315 : 345,
      child: Image.asset(
        'assets/images/login_header_premium.png',
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.isSmallHeight});

  final bool isSmallHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LoginScreen._background,
      padding: EdgeInsets.fromLTRB(
  24,
  isSmallHeight ? 0 : 4,
  24,
  isSmallHeight ? 18 : 22,
),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _FieldLabel('ADRESSE E-MAIL'),
          const SizedBox(height: 8),

          const _PremiumTextField(
            hint: 'prenom.nom@mk.fr',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          const _FieldLabel('MOT DE PASSE'),
          const SizedBox(height: 8),

          const _PremiumTextField(
            hint: '••••••••',
            obscureText: true,
            suffixIcon: Icons.visibility_outlined,
          ),

          const SizedBox(height: 2),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color(0xFF4A8FCB).withValues(alpha: 0.78),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 25),
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(height: isSmallHeight ? 10 : 14),

          // BOUTON PREMIUM SOBRE
          SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD81B60),
                    Color(0xFFC2185B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD81B60)
                        .withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          const MainNavigationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: isSmallHeight ? 36 : 44),

          Text(
            'Données de santé protégées · RGPD · HDS\n'
            'Réservé aux professionnels de santé habilités',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF7A91B8)
                  .withValues(alpha: 0.48),
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      style: TextStyle(
        color: const Color(0xFF004A8F)
            .withValues(alpha: 0.56),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.05,
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final String hint;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.90),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF28415F),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF8AA0BD)
                .withValues(alpha: 0.48),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  size: 18,
                  color: const Color(0xFF7A91B8)
                      .withValues(alpha: 0.45),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color: const Color(0xFF003478)
                  .withValues(alpha: 0.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide(
              color: const Color(0xFF003478)
                  .withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF0B6BCB),
              width: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}