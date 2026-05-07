import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/tutor_model.dart';

class TutorCard extends StatelessWidget {
  final TutorModel tutor;
  final VoidCallback onTap;

  const TutorCard({super.key, required this.tutor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xlAll,
          boxShadow: AppShadows.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 14),
              // Info
              Expanded(child: _buildInfo()),
              // Rate
              _buildRate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        color: AppColors.primarySurface,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: tutor.photoUrl != null
            ? CachedNetworkImage(
                imageUrl: tutor.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _AvatarPlaceholder(),
                errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tutor.name,
            style: AppTextStyles.titleMedium,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        if (tutor.university != null) ...[
          const SizedBox(height: 2),
          Text(tutor.university!,
              style: AppTextStyles.bodySmall,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 8),
        // Rating row
        Row(children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(tutor.rating.toStringAsFixed(1),
              style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
          const SizedBox(width: 4),
          Text('(${tutor.reviewCount})',
              style: AppTextStyles.bodySmall),
        ]),
        const SizedBox(height: 8),
        // Subject chips
        Wrap(
          spacing: 6, runSpacing: 4,
          children: tutor.subjects.take(3).map((s) => _SubjectChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildRate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('\$${tutor.hourlyRate.toStringAsFixed(0)}',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
        Text('/hr', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: const Icon(Icons.person_rounded,
          color: AppColors.primary, size: 28),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  const _SubjectChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
    );
  }
}
