import 'package:flutter/material.dart';

import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [

            /// FOND PLEIN ÉCRAN
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            /// FILTRE LÉGER
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),

            /// CONTENU
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// LOGO URPS
                        Image.asset(
                          'assets/images/banner_urps_large.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 34),

                        /// IDENTIFIANT
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.person_outline),
                            hintText: "Identifiant",
                            filled: true,
                            fillColor:
                                Colors.white.withValues(alpha: 0.92),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCE5F3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCE5F3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFF0B57E3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// MOT DE PASSE
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock_outline),
                            suffixIcon: const Icon(
                              Icons.visibility_outlined,
                            ),
                            hintText: "Mot de passe",
                            filled: true,
                            fillColor:
                                Colors.white.withValues(alpha: 0.92),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCE5F3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFFDCE5F3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(22),
                              borderSide: const BorderSide(
                                color: Color(0xFF0B57E3),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// BOUTON CONNEXION
                        SizedBox(
                          width: double.infinity,
                          height: 66,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MainNavigationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.lock_open_rounded,
                              size: 24,
                            ),
                            label: const Text(
                              "CONNEXION SÉCURISÉE",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF0B57E3),
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shadowColor:
                                  const Color(0xFF0B57E3)
                                      .withValues(alpha: 0.30),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 42),

                        /// ICÔNE APPLICATION
                        Image.asset(
                          'assets/icons/app_icon.png',
                          width: 110,
                          height: 110,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}