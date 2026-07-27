import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/radar/presentation/theme/radar_colors.dart';
import '../features/radar/presentation/theme/radar_radius.dart';
import '../features/radar/presentation/theme/radar_shadows.dart';
import '../features/radar/presentation/theme/radar_spacing.dart';
import '../features/radar/presentation/theme/radar_text_styles.dart';
import '../services/offline_session_service.dart';
import 'main_navigation_screen.dart';

typedef LoginAction = Future<void> Function(String email, String password);

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onAuthenticated,
    this.sessionService,
    this.loginAction,
  });

  final FutureOr<void> Function()? onAuthenticated;
  final OfflineSessionService? sessionService;
  final LoginAction? loginAction;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final action = widget.loginAction;
      if (action != null) {
        await action(_emailController.text.trim(), _passwordController.text);
      } else {
        await (widget.sessionService ?? OfflineSessionService())
            .recordSuccessfulLogin();
      }

      if (!mounted) return;
      final onAuthenticated = widget.onAuthenticated;
      if (onAuthenticated != null) {
        await onAuthenticated();
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Connexion impossible. Vérifiez vos informations et réessayez.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Saisissez votre adresse e-mail.';
    final separator = email.indexOf('@');
    if (separator <= 0 || separator == email.length - 1) {
      return 'Saisissez une adresse e-mail valide.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Saisissez votre mot de passe.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: RadarColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(RadarSpacing.xl),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - RadarSpacing.xl * 2,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _RadarIdentity(),
                          const SizedBox(height: RadarSpacing.xxl),
                          _buildFormCard(),
                          const SizedBox(height: RadarSpacing.xl),
                          Text(
                            'Données locales sécurisées',
                            style: RadarTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.card),
        border: Border.all(color: RadarColors.border),
        boxShadow: RadarShadows.card,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Adresse e-mail', style: RadarTextStyles.contextTitle),
            const SizedBox(height: RadarSpacing.sm),
            TextFormField(
              key: const Key('login-email-field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              enabled: !_isSubmitting,
              validator: _validateEmail,
              decoration: const InputDecoration(
                hintText: 'prenom.nom@exemple.fr',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
            ),
            const SizedBox(height: RadarSpacing.lg),
            Text('Mot de passe', style: RadarTextStyles.contextTitle),
            const SizedBox(height: RadarSpacing.sm),
            TextFormField(
              key: const Key('login-password-field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !_isSubmitting,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  key: const Key('login-password-visibility'),
                  tooltip: _obscurePassword
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: RadarSpacing.md),
              Semantics(
                liveRegion: true,
                child: Text(
                  _errorMessage!,
                  key: const Key('login-error-message'),
                  style: RadarTextStyles.secondary.copyWith(
                    color: RadarColors.clinicalDanger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: RadarSpacing.xl),
            FilledButton(
              key: const Key('login-submit-button'),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: RadarColors.surface,
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarIdentity extends StatelessWidget {
  const _RadarIdentity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: RadarColors.surfaceMuted,
            borderRadius: BorderRadius.circular(RadarRadius.signature),
          ),
          child: const Icon(
            Icons.radar_rounded,
            color: RadarColors.primary,
            size: 42,
          ),
        ),
        const SizedBox(height: RadarSpacing.lg),
        Text('Radar', style: RadarTextStyles.screenTitle),
        const SizedBox(height: RadarSpacing.sm),
        Text(
          'Assistant de raisonnement clinique',
          style: RadarTextStyles.secondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
