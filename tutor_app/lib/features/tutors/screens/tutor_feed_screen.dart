import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tutor_provider.dart';
import '../widgets/tutor_card.dart';
import '../widgets/subject_filter_chips.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../features/map/screens/map_screen.dart';
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Provider is already streaming; a brief delay gives visual feedback
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 96,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapScreen()),
                    ),
                    icon: const Icon(Icons.map_rounded, size: 26),
                    label: const Text('Map view'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: AppColors.primarySurface,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.fullAll),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      textStyle: AppTextStyles.labelSmall
                          .copyWith(letterSpacing: 0),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.fromLTRB(24, 0, 24, 8),
                title: Text('Find a Tutor',
                    style: AppTextStyles.headlineMedium),
                expandedTitleScale: 1.2,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SearchBar(),
                ),
              ),
            ),

            // Subject filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: provider.isLoading
                    ? const SizedBox(height: 36)
                    : SubjectFilterChips(
                        subjects:   provider.allSubjects,
                        selected:   provider.selectedSubject,
                        onSelected: provider.setSubjectFilter,
                      ),
              ),
            ),

            // Sort + results row
            if (!provider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${provider.filteredTutors.length} tutor${provider.filteredTutors.length == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Spacer(),
                      _SortButton(
                        current:  provider.sort,
                        onSelect: provider.setSort,
                      ),
                    ],
                  ),
                ),
              ),

            // Map discovery banner
            if (!provider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MapScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Explore tutors near you on the map',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.primary, size: 14),
                      ]),
                    ),
                  ),
                ),
              ),

            // Loading skeletons
            if (provider.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const SkeletonCard(),
                  childCount: 4,
                ),
              )

            // Empty state
            else if (provider.filteredTutors.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon:    Icons.search_off_rounded,
                  title:   'No tutors found',
                  message: 'Try a different subject or search term.',
                  buttonLabel: provider.selectedSubject != 'All'
                      ? 'Clear filter'
                      : null,
                  onButtonTap: provider.clearFilters,
                ),
              )

            // Tutor list
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
                          builder: (_) =>
                              TutorDetailScreen(tutor: tutor),
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
      ),
    );
  }
}

// ── Sort button ───────────────────────────────────────────────────────────────
class _SortButton extends StatelessWidget {
  final TutorSort current;
  final ValueChanged<TutorSort> onSelect;

  const _SortButton({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isActive = current != TutorSort.recommended;
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: AppRadius.fullAll,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.grey200,
          ),
          boxShadow: isActive ? AppShadows.primary : AppShadows.sm,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sort_rounded, size: 14,
              color: isActive ? AppColors.white : AppColors.grey600),
          const SizedBox(width: 5),
          Text(current.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.white : AppColors.grey600,
                letterSpacing: 0,
              )),
        ]),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(current: current, onSelect: onSelect),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final TutorSort current;
  final ValueChanged<TutorSort> onSelect;

  const _SortSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: AppRadius.fullAll,
              )),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Sort tutors by',
                  style: AppTextStyles.titleMedium),
            ),
          ),
          const SizedBox(height: 12),
          ...TutorSort.values.map((sort) {
            final selected = sort == current;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primarySurface
                      : AppColors.grey50,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(_sortIcon(sort), size: 18,
                    color: selected
                        ? AppColors.primary
                        : AppColors.grey400),
              ),
              title: Text(sort.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.grey800,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  )),
              trailing: selected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20)
                  : null,
              onTap: () {
                onSelect(sort);
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _sortIcon(TutorSort sort) {
    switch (sort) {
      case TutorSort.recommended: return Icons.auto_awesome_rounded;
      case TutorSort.ratingDesc:  return Icons.star_rounded;
      case TutorSort.priceLow:    return Icons.arrow_downward_rounded;
      case TutorSort.priceHigh:   return Icons.arrow_upward_rounded;
    }
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
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
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.grey900),
        decoration: InputDecoration(
          hintText: 'Search by name or subject…',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.grey400, size: 20),
          border:        InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10),
          filled: false,
        ),
      ),
    );
  }
}
