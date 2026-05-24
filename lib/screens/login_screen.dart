import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color bg = Color(0xFFEAF2FB);
  static const Color raspberry = Color(0xFFD81B60);
  static const Color raspberryDark = Color(0xFFC2185B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 600;

          if (isDesktop) {
            return Center(
              child: SizedBox(
                width: 393,
                height: 852,
                child: const _LoginMobileContent(),
              ),
            );
          }

          return const _LoginMobileContent();
        },
      ),
    );
  }
}

class _LoginMobileContent extends StatelessWidget {
  const _LoginMobileContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LoginScreen.bg,
      child: Column(
        children: [
          // HEADER BLEU
          Container(
            width: double.infinity,
            color: const Color(0xFF003F8C),
            child: SafeArea(
              bottom: false,
              child: Image.asset(
                'assets/images/login_header_premium.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // FORMULAIRE
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FieldLabel('ADRESSE E-MAIL'),
                  const SizedBox(height: 10),

                  const _PremiumTextField(
                    hint: 'prenom.nom@mk.fr',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 28),

                  const _FieldLabel('MOT DE PASSE'),
                  const SizedBox(height: 10),

                  const _PremiumTextField(
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    suffixIcon: Icons.visibility_outlined,
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0066C9),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 66,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            LoginScreen.raspberry,
                            LoginScreen.raspberryDark,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: LoginScreen.raspberry
                                .withValues(alpha: 0.28),
                            blurRadius: 26,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacement(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MainNavigationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Colors.transparent,
                          shadowColor:
                              Colors.transparent,
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                        ),
                        child: const Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF0066C9),
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Données de santé protégées · RGPD · HDS\n'
                          'Réservé aux professionnels de santé habilités',
                          style: TextStyle(
                            color: const Color(
                                    0xFF6F8EB9)
                                .withValues(
                                    alpha: 0.78),
                            fontSize: 12,
                            height: 1.3,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        color: const Color(0xFF2E66AA)
            .withValues(alpha: 0.95),
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
    return SizedBox(
      height: 72,
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF28415F),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF0066C9),
            size: 30,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  color: const Color(0xFF8AA0C7),
                  size: 28,
                ),
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFFB7C3D8),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: Color(0xFF0B6BCB),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}