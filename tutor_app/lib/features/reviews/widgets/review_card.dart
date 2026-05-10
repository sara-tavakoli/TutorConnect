import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/review_model.dart';
import 'star_rating.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool        canDelete;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar placeholder
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.fullAll,
                ),
                child: Center(
                  child: Text(
                    review.studentName[0].toUpperCase(),
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.studentName,
                        style: AppTextStyles.labelLarge),
                    Text(
                      DateFormat('MMM d, yyyy')
                          .format(review.createdAt),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Stars
              StarRating(value: review.rating, size: 16),
              // Delete button
              if (canDelete && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          // Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}