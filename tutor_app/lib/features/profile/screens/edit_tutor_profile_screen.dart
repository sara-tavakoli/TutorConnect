import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/subject_tag_input.dart';
import '../widgets/availability_editor.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/tutor_model.dart';
import '../../../services/tutor_service.dart';
import '../../../services/location_service.dart';
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
  double?      _latitude;
  double?      _longitude;
  bool         _isLoading        = false;
  bool         _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _bioCtrl.text  = widget.tutor.bio;
    _rateCtrl.text = widget.tutor.hourlyRate.toStringAsFixed(0);
    _uniCtrl.text  = widget.tutor.university ?? '';
    _yearCtrl.text = widget.tutor.year ?? '';
    _subjects      = List.from(widget.tutor.subjects);
    _availability  = List.from(widget.tutor.availability);
    _latitude      = widget.tutor.latitude;
    _longitude     = widget.tutor.longitude;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();  _rateCtrl.dispose();
    _uniCtrl.dispose();  _yearCtrl.dispose();
    super.dispose();
  }

  // Gets current GPS position and saves it
  Future<void> _setLocation() async {
    setState(() => _isLoadingLocation = true);
    final location = LocationService();
    final position = await location.getCurrentPosition();

    if (position != null) {
      setState(() {
        _latitude  = position.latitude;
        _longitude = position.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location set successfully!',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not get location. Check permissions.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
    setState(() => _isLoadingLocation = false);
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
      latitude:     _latitude,
      longitude:    _longitude,
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
    final hasLocation = _latitude != null && _longitude != null;

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
                maxLength: 300,
                validator: (v) =>
                    v == null || v.trim().isEmpty
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
                  if (v == null || v.isEmpty) return 'Rate is required.';
                  final rate = double.tryParse(v);
                  if (rate == null) return 'Enter a valid number.';
                  if (rate < 5) return 'Rate must be at least \$5.';
                  if (rate > 500) return 'Rate cannot exceed \$500.';
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

              // ── Location section ──────────────────────────
              Text('Campus location',
                  style: AppTextStyles.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Students will see your distance and your pin on the map.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 12),

              // Location status card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.successSurface
                      : AppColors.grey50,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                    color: hasLocation
                        ? AppColors.success
                        : AppColors.grey200,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    hasLocation
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    color: hasLocation
                        ? AppColors.success
                        : AppColors.grey400,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasLocation
                          ? 'Location set — visible on map'
                          : 'No location set yet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: hasLocation
                            ? AppColors.success
                            : AppColors.grey500,
                      ),
                    ),
                  ),
                  if (hasLocation)
                    GestureDetector(
                      onTap: () => setState(() {
                        _latitude  = null;
                        _longitude = null;
                      }),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.grey400, size: 18),
                    ),
                ]),
              ),
              const SizedBox(height: 10),

              // Set location button
              AppButton(
                label: hasLocation
                    ? 'Update my location'
                    : 'Set my location',
                variant: AppButtonVariant.outlined,
                icon: Icons.my_location_rounded,
                isLoading: _isLoadingLocation,
                onPressed: _setLocation,
                height: 44,
              ),

              const SizedBox(height: 24),

              Text('Subjects',
                  style: AppTextStyles.labelLarge),
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