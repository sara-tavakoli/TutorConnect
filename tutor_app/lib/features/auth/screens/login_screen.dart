import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey  = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus    = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _animCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Submit 
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth    = context.read<AuthProvider>();
    final success = await auth.signIn(
      email: _email.text,
      password: _password.text,
    );

    if (!success && mounted) {
      _showError(auth.errorMessage ?? 'Login failed.');
    }
    // Navigation is handled by the root router watching AuthProvider.status
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      _showError('Enter your email first, then tap Forgot Password.');
      return;
    }
    final auth    = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_email.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Reset link sent to ${_email.text}'
                : auth.errorMessage ?? 'Failed to send reset link.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Hero illustration ───────────────────────────────
                  _buildHero(),

                  const SizedBox(height: 40),

                  // ── Heading ─────────────────────────────────────────
                  Text('Welcome back', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue learning or teaching.',
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 36),

                  // ── Form ────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email',
                          hint: 'you@university.edu.au',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_passwordFocus),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required.';
                            if (!v.contains('@')) return 'Enter a valid email.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _password,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required.';
                            if (v.length < 6) return 'At least 6 characters.';
                            return null;
                          },
                        ),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(
                              'Forgot password?',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Sign in button
                        AppButton(
                          label: 'Sign In',
                          onPressed: _submit,
                          isLoading: auth.isLoading,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Divider ─────────────────────────────────────────
                  _buildDivider(),

                  const SizedBox(height: 24),

                  // ── Register link ───────────────────────────────────
                  _buildRegisterLink(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: AppRadius.xxlAll,
      ),
      child: Stack(
        children: [
          // Background circles (decorative)
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: 30,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Icon + tagline
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'TutorConnect',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Campus tutoring, made simple.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("Don't have an account?",
              style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const RegisterScreen()),
            ),
            child: Text(
              'Create an account',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}