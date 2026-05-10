import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/tutor_model.dart';
import '../../../services/tutor_service.dart';
import '../../../services/storage_service.dart';
import 'edit_tutor_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final user    = auth.user;
    final isTutor = user?.isTutor ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: Text('Profile', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.grey600, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(user: user, isTutor: isTutor),
            const SizedBox(height: 24),

            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isTutor
                    ? AppColors.accentSurface
                    : AppColors.primarySurface,
                borderRadius: AppRadius.fullAll,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  isTutor
                      ? Icons.co_present_rounded
                      : Icons.menu_book_rounded,
                  size: 14,
                  color: isTutor
                      ? AppColors.accent
                      : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isTutor ? 'Tutor account' : 'Student account',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isTutor
                        ? AppColors.accent
                        : AppColors.primary,
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // Email
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.lgAll,
                boxShadow: AppShadows.sm,
              ),
              child: Row(children: [
                const Icon(Icons.mail_outline_rounded,
                    size: 18, color: AppColors.grey400),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: AppTextStyles.labelSmall),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.grey900)),
                  ],
                ),
              ]),
            ),

            const SizedBox(height: 32),

            // Tutor-only section
            if (isTutor && user != null)
              _TutorSection(uid: user.uid),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xlAll),
        title: Text('Sign out?',
            style: AppTextStyles.titleMedium),
        content: Text('You will need to sign in again.',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: Text('Sign out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Tutor section — loads once, doesn't rebuild ───────────────────────────
class _TutorSection extends StatefulWidget {
  final String uid;
  const _TutorSection({required this.uid});

  @override
  State<_TutorSection> createState() => _TutorSectionState();
}

class _TutorSectionState extends State<_TutorSection> {
  TutorModel? _tutor;
  bool        _loading = true;
  String?     _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tutor = await TutorService().getTutorById(widget.uid);
      if (mounted) setState(() { _tutor = tutor; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _tutor == null) {
      return Column(children: [
        Text('Could not load tutor profile.',
            style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() { _loading = true; _error = null; });
            _load();
          },
          child: const Text('Retry'),
        ),
      ]);
    }

    final tutor = _tutor!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadows.sm,
          ),
          child: Row(children: [
            _StatItem(
              value: tutor.subjects.length.toString(),
              label: 'Subjects',
              icon: Icons.menu_book_rounded,
            ),
            Container(width: 1, height: 36,
                color: AppColors.grey100,
                margin: const EdgeInsets.symmetric(horizontal: 16)),
            _StatItem(
              value: tutor.availability.length.toString(),
              label: 'Slots',
              icon: Icons.access_time_rounded,
            ),
            Container(width: 1, height: 36,
                color: AppColors.grey100,
                margin: const EdgeInsets.symmetric(horizontal: 16)),
            _StatItem(
              value: '\$${tutor.hourlyRate.toStringAsFixed(0)}',
              label: 'Per hour',
              icon: Icons.attach_money_rounded,
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // Location status
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tutor.hasLocation
                ? AppColors.successSurface
                : AppColors.grey50,
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: tutor.hasLocation
                  ? AppColors.success
                  : AppColors.grey200,
            ),
          ),
          child: Row(children: [
            Icon(
              tutor.hasLocation
                  ? Icons.location_on_rounded
                  : Icons.location_off_rounded,
              color: tutor.hasLocation
                  ? AppColors.success
                  : AppColors.grey400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              tutor.hasLocation
                  ? 'Your pin is visible on the map'
                  : 'No location set — not visible on map',
              style: AppTextStyles.bodyMedium.copyWith(
                color: tutor.hasLocation
                    ? AppColors.success
                    : AppColors.grey500,
              ),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        AppButton(
          label: 'Edit Tutor Profile',
          variant: AppButtonVariant.outlined,
          icon: Icons.edit_rounded,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditTutorProfileScreen(tutor: tutor),
              ),
            );
            // Reload after returning from edit
            setState(() { _loading = true; _error = null; });
            _load();
          },
        ),
      ],
    );
  }
}

// ── Profile header with photo upload ─────────────────────────────────────
class _ProfileHeader extends StatefulWidget {
  final dynamic user;
  final bool isTutor;
  const _ProfileHeader({required this.user, required this.isTutor});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _uploading = false;

  Future<void> _uploadPhoto() async {
    setState(() => _uploading = true);
    try {
      final storage = StorageService();
      final file    = await storage.pickImage();
      if (file == null) { setState(() => _uploading = false); return; }

      final auth = context.read<AuthProvider>();
      final url  = await storage.uploadProfilePhoto(
          uid: auth.user!.uid, file: file);

      final tutor = await TutorService().getTutorById(auth.user!.uid);
      if (tutor != null) {
        await TutorService().updateTutor(tutor.copyWith(photoUrl: url));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Photo updated!',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Row(children: [
      GestureDetector(
        onTap: widget.isTutor ? _uploadPhoto : null,
        child: Stack(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              borderRadius: AppRadius.xxlAll,
              color: AppColors.primarySurface,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.xxlAll,
              child: user?.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.photoUrl!,
                      fit: BoxFit.cover)
                  : const Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 40),
            ),
          ),
          if (widget.isTutor)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(
                      color: AppColors.white, width: 2),
                ),
                child: _uploading
                    ? const Padding(
                        padding: EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white))
                    : const Icon(Icons.camera_alt_rounded,
                        color: AppColors.white, size: 13),
              ),
            ),
        ]),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user?.name ?? '',
                style: AppTextStyles.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(user?.email ?? '',
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.titleMedium),
      Text(label, style: AppTextStyles.bodySmall),
    ]),
  );
}