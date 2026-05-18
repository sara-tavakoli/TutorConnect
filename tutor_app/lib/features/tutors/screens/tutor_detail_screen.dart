import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/tutor_model.dart';
import '../../../models/review_model.dart';
import '../../../services/review_service.dart';
import '../../../services/chat_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/bookings/screens/book_session_sheet.dart';
import '../../../features/bookings/providers/booking_provider.dart';
import '../../../features/reviews/screens/add_review_sheet.dart';
import '../../../features/reviews/widgets/star_rating.dart';
import '../../../features/reviews/widgets/review_card.dart';
import '../../../features/chat/screens/chat_screen.dart';



//The full tutor profile, photo, bio, subjects, availability slots, and the Book button that opens the booking sheet.

class TutorDetailScreen extends StatelessWidget {
  final TutorModel tutor;
  const TutorDetailScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isStudent = auth.user?.isStudent ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          //App bar 
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroPhoto(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + university
                  Text(tutor.name,
                      style: AppTextStyles.headlineLarge),
                  if (tutor.university != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.school_rounded,
                          size: 14,
                          color: AppColors.grey400),
                      const SizedBox(width: 6),
                      Text(
                        '${tutor.university}${tutor.year != null ? ' · ${tutor.year}' : ''}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ]),
                  ],

                  const SizedBox(height: 16),
                  _StatsRow(tutor: tutor),
                  const SizedBox(height: 24),

                  // Bio
                  Text('About',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    tutor.bio.isEmpty
                        ? 'No bio provided yet.'
                        : tutor.bio,
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Subjects
                  Text('Subjects',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: tutor.subjects
                        .map((s) => _SubjectTag(s))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Availability
                  Text('Available slots',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 10),
                  tutor.availability.isEmpty
                      ? Text('No slots listed yet.',
                          style: AppTextStyles.bodyMedium)
                      : Wrap(
                          spacing: 8, runSpacing: 8,
                          children: tutor.availability
                              .map((s) => _SlotChip(s))
                              .toList(),
                        ),

                  const SizedBox(height: 24),

                  //  Reviews section 
                  _ReviewsSection(
                    tutor:     tutor,
                    isStudent: isStudent,
                    currentUserId: auth.user?.uid,
                  ),

                  const SizedBox(height: 24),

                  // Action buttons — students only
                  if (isStudent) ...[
                    ChangeNotifierProvider(
                      create: (_) => BookingProvider(),
                      child: AppButton(
                        label:
                            'Book a session · \$${tutor.hourlyRate.toStringAsFixed(0)}/hr',
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              BookSessionSheet(tutor: tutor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MessageButton(tutor: tutor),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Leave a Review',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.star_rounded,
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            AddReviewSheet(tutor: tutor),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPhoto() {
    return Stack(fit: StackFit.expand, children: [
      tutor.photoUrl != null
          ? CachedNetworkImage(
              imageUrl: tutor.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.primarySurface),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.primarySurface),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white54, size: 80),
            ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ]);
  }
}

//  Reviews section
class _ReviewsSection extends StatelessWidget {
  final TutorModel tutor;
  final bool       isStudent;
  final String?    currentUserId;

  const _ReviewsSection({
    required this.tutor,
    required this.isStudent,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews',
                style: AppTextStyles.titleMedium),
            StarDisplay(
              rating:      tutor.rating,
              reviewCount: tutor.reviewCount,
            ),
          ],
        ),
        const SizedBox(height: 12),

        StreamBuilder<List<ReviewModel>>(
          stream: ReviewService().getReviews(tutor.uid),
          builder: (context, snap) {
            if (snap.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            final reviews = snap.data ?? [];

            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(
                      color: AppColors.grey200),
                ),
                child: Center(
                  child: Text(
                    'No reviews yet — be the first!',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (_, i) => ReviewCard(
                review:    reviews[i],
                canDelete: reviews[i].studentId ==
                    currentUserId,
                onDelete: () =>
                    ReviewService().deleteReview(
                  tutorId:  tutor.uid,
                  reviewId: reviews[i].id,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

//  Supporting widgets 
class _StatsRow extends StatelessWidget {
  final TutorModel tutor;
  const _StatsRow({required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.sm,
      ),
      child: Row(children: [
        _Stat(
          icon: Icons.star_rounded,
          iconColor: AppColors.accent,
          value: tutor.rating.toStringAsFixed(1),
          label: 'Rating',
        ),
        _divider(),
        _Stat(
          icon: Icons.reviews_rounded,
          iconColor: AppColors.primary,
          value: '${tutor.reviewCount}',
          label: 'Reviews',
        ),
        _divider(),
        _Stat(
          icon: Icons.attach_money_rounded,
          iconColor: AppColors.success,
          value: '\$${tutor.hourlyRate.toStringAsFixed(0)}',
          label: 'Per hour',
        ),
      ]),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 36,
      color: AppColors.grey100,
      margin:
          const EdgeInsets.symmetric(horizontal: 16));
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   value;
  final String   label;
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.titleMedium),
      Text(label, style: AppTextStyles.bodySmall),
    ]),
  );
}

class _SubjectTag extends StatelessWidget {
  final String label;
  const _SubjectTag(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: AppRadius.fullAll,
    ),
    child: Text(label,
        style: AppTextStyles.labelLarge
            .copyWith(color: AppColors.primary)),
  );
}

class _SlotChip extends StatelessWidget {
  final String label;
  const _SlotChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: AppRadius.mdAll,
      border: Border.all(color: AppColors.grey200),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.access_time_rounded,
          size: 13, color: AppColors.grey400),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.bodyMedium),
    ]),
  );
}

// ── Message button — opens or creates a chat with this tutor ──────────────────

class _MessageButton extends StatefulWidget {
  final TutorModel tutor;
  const _MessageButton({required this.tutor});

  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton> {
  bool _loading = false;

  Future<void> _openChat() async {
    final auth = context.read<AuthProvider>();
    final me   = auth.user;
    if (me == null) return;

    setState(() => _loading = true);
    try {
      final chatId = await ChatService().getOrCreateChat(
        uid1:   me.uid,
        name1:  me.name,
        uid2:   widget.tutor.uid,
        name2:  widget.tutor.name,
        photo1: me.photoUrl,
        photo2: widget.tutor.photoUrl,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId:         chatId,
            otherUserId:    widget.tutor.uid,
            otherUserName:  widget.tutor.name,
            otherUserPhoto: widget.tutor.photoUrl,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _openChat,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        ),
        icon: _loading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : const Icon(Icons.chat_bubble_outline_rounded, size: 18),
        label: Text(
          _loading ? 'Opening chat…' : 'Message',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}