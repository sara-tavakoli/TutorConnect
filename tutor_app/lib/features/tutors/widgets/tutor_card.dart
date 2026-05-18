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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.xlAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xlAll,
          splashColor: AppColors.primarySurface,
          highlightColor: AppColors.primarySurface.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 14),
                Expanded(child: _buildInfo()),
                const SizedBox(width: 8),
                _buildRate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 64, height: 64,
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
        ),
        // Online / active indicator dot
        if (tutor.hasLocation)
          Positioned(
            bottom: 2, right: 2,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Flexible(
            child: Text(tutor.name,
                style: AppTextStyles.titleMedium,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
        if (tutor.university != null) ...[
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.school_outlined, size: 11, color: AppColors.grey400),
            const SizedBox(width: 3),
            Flexible(
              child: Text(tutor.university!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 3),
          Text(tutor.rating.toStringAsFixed(1),
              style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
          const SizedBox(width: 3),
          Text('(${tutor.reviewCount})', style: AppTextStyles.bodySmall),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5, runSpacing: 4,
          children: tutor.subjects.take(3).map((s) => _SubjectChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildRate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: AppRadius.mdAll,
          ),
          child: Text('\$${tutor.hourlyRate.toStringAsFixed(0)}',
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary, fontSize: 13)),
        ),
        const SizedBox(height: 3),
        Text('/hr', style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.primarySurface,
    child: const Icon(Icons.person_rounded,
        color: AppColors.primary, size: 28),
  );
}

class _SubjectChip extends StatelessWidget {
  final String label;
  const _SubjectChip(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.grey100,
      borderRadius: AppRadius.fullAll,
    ),
    child: Text(label,
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600)),
  );
}
