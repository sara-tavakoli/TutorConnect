import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/subject_tag_input.dart';
import '../widgets/availability_editor.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/tutor_model.dart';
import '../../../services/tutor_service.dart';
import '../../auth/providers/auth_provider.dart';

class EditTutorProfileScreen extends StatefulWidget {
  final TutorModel tutor;
  const EditTutorProfileScreen({super.key, required this.tutor});

  @override
  State<EditTutorProfileScreen> createState() =>
      _EditTutorProfileScreenState();
}

class _EditTutorProfileScreenState
    extends State<EditTutorProfileScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _bioCtrl  = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _uniCtrl  = TextEditingController();
  final _yearCtrl = TextEditingController();

  List<String> _subjects     = [];
  List<String> _availability = [];
  bool         _isLoading    = false;

  @override
  void initState() {
    super.initState();
    _bioCtrl.text  = widget.tutor.bio;
    _rateCtrl.text = widget.tutor.hourlyRate.toStringAsFixed(0);
    _uniCtrl.text  = widget.tutor.university ?? '';
    _yearCtrl.text = widget.tutor.year ?? '';
    _subjects      = List.from(widget.tutor.subjects);
    _availability  = List.from(widget.tutor.availability);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();  _rateCtrl.dispose();
    _uniCtrl.dispose();  _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth    = context.read<AuthProvider>();
    final updated = widget.tutor.copyWith(
      bio:          _bioCtrl.text.trim(),
      hourlyRate:   double.tryParse(_rateCtrl.text) ??
                    widget.tutor.hourlyRate,
      university:   _uniCtrl.text.trim().isEmpty
                    ? null : _uniCtrl.text.trim(),
      year:         _yearCtrl.text.trim().isEmpty
                    ? null : _yearCtrl.text.trim(),
      subjects:     _subjects,
      availability: _availability,
      name:         auth.user!.name,
    );

    await TutorService().updateTutor(updated);
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated!',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Edit Profile',
            style: AppTextStyles.titleMedium),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.grey800, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Bio',
                hint: 'Tell students about yourself…',
                controller: _bioCtrl,
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Bio is required.' : null,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Hourly rate (\$)',
                hint: '45',
                controller: _rateCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Rate is required.';
                  if (double.tryParse(v) == null)
                    return 'Enter a valid number.';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'University (optional)',
                hint: 'e.g. Macquarie University',
                controller: _uniCtrl,
                prefixIcon: Icons.school_rounded,
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Year of study (optional)',
                hint: 'e.g. 3rd Year',
                controller: _yearCtrl,
                prefixIcon: Icons.timeline_rounded,
              ),
              const SizedBox(height: 24),

              Text('Subjects', style: AppTextStyles.labelLarge),
              const SizedBox(height: 10),
              SubjectTagInput(
                subjects: _subjects,
                onChanged: (s) => setState(() => _subjects = s),
              ),
              const SizedBox(height: 24),

              Text('Availability slots',
                  style: AppTextStyles.labelLarge),
              const SizedBox(height: 4),
              Text('e.g. Mon 2–3pm, Wed 4–5pm',
                  style: AppTextStyles.bodySmall),
              const SizedBox(height: 10),
              AvailabilityEditor(
                slots: _availability,
                onChanged: (s) =>
                    setState(() => _availability = s),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Save Changes',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
