import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tutor_provider.dart';
import '../widgets/tutor_card.dart';
import '../widgets/subject_filter_chips.dart';
import '../../../core/theme/app_theme.dart';
import 'tutor_detail_screen.dart';

class TutorFeedScreen extends StatelessWidget {
  const TutorFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TutorProvider(),
      child: const _TutorFeedView(),
    );
  }
}

class _TutorFeedView extends StatelessWidget {
  const _TutorFeedView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TutorProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Text('Find a Tutor', style: AppTextStyles.headlineMedium),
              expandedTitleScale: 1.2,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _SearchBar(),
              ),
            ),
          ),

          // ── Subject filter chips ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SubjectFilterChips(
                subjects: provider.allSubjects,
                selected: provider.selectedSubject,
                onSelected: provider.setSubjectFilter,
              ),
            ),
          ),

          // ── Results count ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '${provider.filteredTutors.length} tutors available',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ),

          // ── Tutor list ────────────────────────────────────────────
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.filteredTutors.isEmpty)
            SliverFillRemaining(child: _EmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tutor = provider.filteredTutors[index];
                  return TutorCard(
                    tutor: tutor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TutorDetailScreen(tutor: tutor),
                      ),
                    ),
                  );
                },
                childCount: provider.filteredTutors.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<TutorProvider>();
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.fullAll,
      ),
      child: TextField(
        onChanged: provider.setSearchQuery,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey900),
        decoration: InputDecoration(
          hintText: 'Search by name or subject…',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.grey400, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: false,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppRadius.xxlAll,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No tutors found', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('Try a different subject or search term.',
              style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
