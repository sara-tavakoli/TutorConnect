import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Interactive star rating widget — tap to select 1-5 stars
class StarRating extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1.0;
        return GestureDetector(
          onTap: onChanged != null
              ? () => onChanged!(starValue)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              value >= starValue
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: value >= starValue
                  ? AppColors.accent
                  : AppColors.grey300,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Read-only compact star display for cards
class StarDisplay extends StatelessWidget {
  final double rating;
  final int    reviewCount;
  final double size;

  const StarDisplay({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            size: size, color: AppColors.accent),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.labelLarge
              .copyWith(fontSize: size - 2),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount)',
          style: AppTextStyles.bodySmall
              .copyWith(fontSize: size - 3),
        ),
      ],
    );
  }
}