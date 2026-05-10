import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/star_rating.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/review_model.dart';
import '../../../models/tutor_model.dart';
import '../../../services/review_service.dart';
import '../../auth/providers/auth_provider.dart';

class AddReviewSheet extends StatefulWidget {
  final TutorModel tutor;
  const AddReviewSheet({super.key, required this.tutor});

  @override
  State<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<AddReviewSheet> {
  double  _rating    = 0;
  final   _commentCtrl = TextEditingController();
  bool    _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a star rating.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth   = context.read<AuthProvider>();
      final review = ReviewModel(
        id:          '',
        tutorId:     widget.tutor.uid,
        studentId:   auth.user!.uid,
        studentName: auth.user!.name,
        rating:      _rating,
        comment:     _commentCtrl.text.trim(),
        createdAt:   DateTime.now(),
      );

      await ReviewService().addReview(review);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Review submitted!',
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
          content: Text('Failed: $e',
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Leave a review',
                style: AppTextStyles.headlineMedium),
            Text('for ${widget.tutor.name}',
                style: AppTextStyles.bodyMedium),

            const SizedBox(height: 28),

            // Star rating
            Text('Your rating',
                style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Center(
              child: StarRating(
                value:     _rating,
                onChanged: (v) => setState(() => _rating = v),
                size:      40,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _rating == 0
                      ? 'Tap to rate'
                      : _ratingLabel(_rating),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _rating == 0
                        ? AppColors.grey400
                        : AppColors.accent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Comment
            Text('Comment (optional)',
                style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines:   3,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey900),
              decoration: InputDecoration(
                hintText:  'Share your experience…',
                hintStyle: AppTextStyles.bodyMedium,
              ),
            ),

            const SizedBox(height: 28),

            AppButton(
              label:     'Submit Review',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r == 1) return 'Poor';
    if (r == 2) return 'Fair';
    if (r == 3) return 'Good';
    if (r == 4) return 'Very Good';
    return 'Excellent!';
  }
}