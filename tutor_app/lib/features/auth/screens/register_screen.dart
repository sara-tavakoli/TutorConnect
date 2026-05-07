import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey     = GlobalKey<FormState>();
  final _name        = TextEditingController();
  final _email       = TextEditingController();
  final _password    = TextEditingController();
  final _confirmPass = TextEditingController();
  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _passFocus    = FocusNode();
  final _confirmFocus = FocusNode();
  UserRole _selectedRole = UserRole.student;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _name.dispose(); _email.dispose();
    _password.dispose(); _confirmPass.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _passFocus.dispose(); _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      name: _name.text, email: _email.text,
      password: _password.text, role: _selectedRole,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Registration failed.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.grey800, size: 20),
        ),
      ),
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
                  const SizedBox(height: 8),
                  Text('Create account', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text('Join TutorConnect and start your journey.', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 32),
                  Text('I am a…', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  _RoleSelector(
                    selected: _selectedRole,
                    onChanged: (role) => setState(() => _selectedRole = role),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full name', hint: 'Jane Smith',
                          controller: _name,
                          prefixIcon: Icons.person_outline_rounded,
                          focusNode: _nameFocus,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_emailFocus),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Name is required.';
                            if (v.trim().length < 2) return 'Enter your full name.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Email', hint: 'you@university.edu.au',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocus),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required.';
                            if (!v.contains('@')) return 'Enter a valid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Password', hint: '6+ characters',
                          controller: _password, isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          focusNode: _passFocus,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_confirmFocus),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required.';
                            if (v.length < 6) return 'Minimum 6 characters.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Confirm password', hint: 'Repeat your password',
                          controller: _confirmPass, isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          focusNode: _confirmFocus,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm your password.';
                            if (v != _password.text) return 'Passwords do not match.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          label: 'Create Account',
                          onPressed: _submit,
                          isLoading: auth.isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('By registering, you agree to our Terms of Service.',
                        style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _RoleCard(
        role: UserRole.student, selected: selected == UserRole.student,
        icon: Icons.menu_book_rounded, label: 'Student',
        description: 'Find tutors & book sessions',
        onTap: () => onChanged(UserRole.student),
      )),
      const SizedBox(width: 12),
      Expanded(child: _RoleCard(
        role: UserRole.tutor, selected: selected == UserRole.tutor,
        icon: Icons.co_present_rounded, label: 'Tutor',
        description: 'Offer your skills & earn',
        onTap: () => onChanged(UserRole.tutor),
      )),
    ]);
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool selected;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  const _RoleCard({
    required this.role, required this.selected, required this.icon,
    required this.label, required this.description, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : AppColors.grey50,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.grey200,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, size: 18,
                color: selected ? AppColors.white : AppColors.grey500),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.titleMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.grey800)),
          const SizedBox(height: 4),
          Text(description, style: AppTextStyles.bodySmall.copyWith(
              color: selected ? AppColors.primaryDark : AppColors.grey500)),
        ]),
      ),
    );
  }
}
