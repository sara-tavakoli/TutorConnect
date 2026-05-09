import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../tutors/screens/tutor_feed_screen.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../map/screens/map_screen.dart';
import '../../profile/screens/profile_screen.dart';

//Add the Map tab to the bottom navigation.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    TutorFeedScreen(),
    MapScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final isTutor = auth.user?.isTutor ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey100, width: 1),
          ),
          boxShadow: AppShadows.sm,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon:       Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label:      'Browse',
                  selected:   _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon:       Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                  label:      'Map',
                  selected:   _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon:       Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today_rounded,
                  label:      isTutor ? 'Requests' : 'Bookings',
                  selected:   _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon:       Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label:      'Profile',
                  selected:   _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData   icon;
  final IconData   activeIcon;
  final String     label;
  final bool       selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySurface
              : Colors.transparent,
          borderRadius: AppRadius.fullAll,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected
                  ? AppColors.primary
                  : AppColors.grey400,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.grey400,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}