import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color bg = Color(0xFFEAF2FB);
  static const Color raspberry = Color(0xFFD81B60);
  static const Color raspberryDark = Color(0xFFC2185B);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: size.width < 600 ? size.width : 430,
          ),
          child: _MobileLoginLayout(screenHeight: size.height),
        ),
      ),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({required this.screenHeight});

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: LoginScreen.bg)),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenHeight * 0.54,
          child: Image.asset(
            'assets/images/login_header_premium.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        Positioned(
          top: screenHeight * 0.445,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _SoftCurveClipper(),
            child: Container(
              height: 120,
              color: LoginScreen.bg,
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              24,
              screenHeight * 0.545,
              24,
              24,
            ),
            child: const _LoginForm(),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('ADRESSE E-MAIL'),
        const SizedBox(height: 10),
        const _PremiumTextField(
          hint: 'prenom.nom@mk.fr',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 26),
        const _FieldLabel('MOT DE PASSE'),
        const SizedBox(height: 10),
        const _PremiumTextField(
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
          suffixIcon: Icons.visibility_outlined,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0066C9),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Mot de passe oublié ?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 66,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LoginScreen.raspberry, LoginScreen.raspberryDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: LoginScreen.raspberry.withValues(alpha: 0.34),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Connexion',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        const SizedBox(height: 44),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF0066C9),
              size: 34,
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'Données de santé protégées · RGPD · HDS\n'
                'Réservé aux professionnels de santé habilités',
                style: TextStyle(
                  color: const Color(0xFF5B82B5).withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SoftCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 26)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 26)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF004A8F).withValues(alpha: 0.78),
        fontSize: 14,
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
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFF28415F),
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF0066C9), size: 28),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: const Color(0xFF7A91B8), size: 24),
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF8AA0BD).withValues(alpha: 0.55),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}