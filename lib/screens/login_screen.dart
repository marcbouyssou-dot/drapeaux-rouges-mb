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
      value: const SystemUiOverlayStyle(
        statusBarColor: RadarColors.brandBackground,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: RadarColors.brandBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        key: const Key('radar-login-screen'),
        backgroundColor: RadarColors.brandBackground,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _RadarLoginBackgroundPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 700;
                  final verticalPadding = compact
                      ? RadarSpacing.md
                      : RadarSpacing.xl;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      RadarSpacing.cardGap,
                      verticalPadding,
                      RadarSpacing.cardGap,
                      RadarSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            verticalPadding -
                            RadarSpacing.lg,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RadarIdentity(compact: compact),
                              SizedBox(
                                height: compact
                                    ? RadarSpacing.lg
                                    : RadarSpacing.xl,
                              ),
                              _buildFormCard(compact: compact),
                              SizedBox(
                                height: compact
                                    ? RadarSpacing.lg
                                    : RadarSpacing.xl,
                              ),
                              Text(
                                'Données locales sécurisées • RGPD',
                                key: const Key('login-security-footer'),
                                style: RadarTextStyles.caption.copyWith(
                                  color: RadarColors.textMutedOnBrand,
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required bool compact}) {
    return Container(
      key: const Key('login-form-card'),
      width: double.infinity,
      padding: EdgeInsets.all(compact ? RadarSpacing.cardGap : RadarSpacing.xl),
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.loginCard),
        boxShadow: RadarShadows.loginCard,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _fieldLabel('Adresse e-mail'),
            const SizedBox(height: RadarSpacing.sm),
            TextFormField(
              key: const Key('login-email-field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              enabled: !_isSubmitting,
              validator: _validateEmail,
              decoration: _fieldDecoration(
                hintText: 'prenom.nom@exemple.fr',
                prefixIcon: Icons.mail_outline_rounded,
              ),
            ),
            const SizedBox(height: RadarSpacing.lg),
            _fieldLabel('Mot de passe'),
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
              decoration: _fieldDecoration(
                hintText: 'Mot de passe',
                prefixIcon: Icons.lock_outline_rounded,
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
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: RadarTextStyles.contextTitle.copyWith(color: RadarColors.primary),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(RadarRadius.loginField),
      borderSide: const BorderSide(color: RadarColors.border),
    );

    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: RadarColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: RadarColors.loginFieldSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RadarSpacing.lg,
        vertical: RadarSpacing.lg,
      ),
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.loginField),
        borderSide: const BorderSide(color: RadarColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.loginField),
        borderSide: const BorderSide(color: RadarColors.clinicalDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadarRadius.loginField),
        borderSide: const BorderSide(
          color: RadarColors.clinicalDanger,
          width: 1.6,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSubmitting
              ? [
                  RadarColors.brandAccent.withValues(alpha: 0.55),
                  RadarColors.brandAccentDark.withValues(alpha: 0.55),
                ]
              : const [RadarColors.brandAccent, RadarColors.brandAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(RadarRadius.loginField),
        boxShadow: _isSubmitting ? const [] : RadarShadows.loginButton,
      ),
      child: ElevatedButton(
        key: const Key('login-submit-button'),
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: RadarColors.textOnBrand,
          disabledForegroundColor: RadarColors.textOnBrand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.loginField),
          ),
          textStyle: RadarTextStyles.body.copyWith(
            color: RadarColors.textOnBrand,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isSubmitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: RadarColors.textOnBrand,
                ),
              )
            : const Text('Se connecter'),
      ),
    );
  }
}

class _RadarIdentity extends StatelessWidget {
  const _RadarIdentity({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          key: const Key('radar-brand-symbol'),
          width: compact ? 82 : 104,
          height: compact ? 82 : 104,
          padding: EdgeInsets.all(compact ? 4 : 5),
          decoration: BoxDecoration(
            color: RadarColors.textOnBrand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(RadarRadius.loginCard),
            border: Border.all(
              color: RadarColors.textOnBrand.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: RadarColors.primary.withValues(alpha: 0.16),
                blurRadius: 28,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadarRadius.signature),
            child: Image.asset(
              'assets/icons/app_icon.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Symbole Radar',
            ),
          ),
        ),
        SizedBox(height: compact ? RadarSpacing.md : RadarSpacing.lg),
        Text(
          'Radar',
          style: RadarTextStyles.screenTitle.copyWith(
            color: RadarColors.textOnBrand,
            fontSize: compact ? 30 : 36,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: RadarSpacing.sm),
        Text(
          'Assistant de raisonnement clinique',
          style: RadarTextStyles.secondary.copyWith(
            color: RadarColors.textOnBrand.withValues(alpha: 0.94),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: RadarSpacing.xs),
        Text(
          'Dépistage • Orientation',
          style: RadarTextStyles.caption.copyWith(
            color: RadarColors.textMutedOnBrand,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RadarLoginBackgroundPainter extends CustomPainter {
  const _RadarLoginBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = RadarColors.primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final upperArc = Path()
      ..moveTo(-size.width * 0.2, size.height * 0.16)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.06,
        size.width * 0.30,
        size.height * 0.28,
        -size.width * 0.04,
        size.height * 0.38,
      );
    final lowerArc = Path()
      ..moveTo(size.width * 1.16, size.height * 0.64)
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.52,
        size.width * 0.72,
        size.height * 0.78,
        size.width * 1.04,
        size.height * 0.88,
      );

    canvas.drawPath(upperArc, linePaint);
    canvas.drawPath(lowerArc, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
